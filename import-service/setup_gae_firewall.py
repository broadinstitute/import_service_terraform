#!/usr/bin/env python3

# This Python 3.5+ script is a workaround for Terraform's inability to reliably create Google App Engine firewall rules.
# This is bugged here, and may be fixed: https://github.com/terraform-providers/terraform-provider-google/issues/5681

# sourced from https://dsp-security.broadinstitute.org/platform-security-categories/google-cloud-platform/securing-the-network
broad_range_cidrs = [ "69.173.112.0/21",
                      "69.173.127.232/29",
                      "69.173.127.128/26",
                      "69.173.127.0/25",
                      "69.173.127.240/28",
                      "69.173.127.224/30",
                      "69.173.127.230/31",
                      "69.173.120.0/22",
                      "69.173.127.228/32",
                      "69.173.126.0/24",
                      "69.173.96.0/20",
                      "69.173.64.0/19",
                      "69.173.127.192/27",
                      "69.173.124.0/23" ]

# Pub/Sub doesn't publish their IP ranges, I found this on SO and verified experimentally:
# https://stackoverflow.com/a/51323548/2941784
PUBSUB_IP_RANGE = "2002:a00::/24"


import argparse
import sys
import subprocess
import json


parser = argparse.ArgumentParser(description="""Adds Broad Google App Engine firewall rules to the project given.
Also adds Orch and back-Rawls instances in the corresponding environment.
Will use your currently logged in gcloud credentials to do so.""")
parser.add_argument("project", help="Google project in which to add the App Engine firewall rules.")
parser.add_argument("env", help="Env shorthand, i.e. dev/alpha/staging/prod")
args = parser.parse_args()


def check_error(res, msg):
    if res.returncode != 0:
        print(msg + ':\n')
        print(res.stdout)
        sys.exit(res.returncode)


###
# Look up the Rawls and Orch IPs. We'll use these to generate the new firewall rules.
# We do this first so that any errors here don't break the script with the firewall rules mid-change.
###

def get_gae_public_ips(gcloud_instances_list):
    """Parses out the monstrous gcloud output into a dict of instance name -> IP.
    For reference, gcloud returns a list of these: https://cloud.google.com/compute/docs/reference/rest/v1/instances"""
    all_instance_nics = {inst["name"]:inst["networkInterfaces"] for inst in gcloud_instances_list}
    return {inst:ac["natIP"]
            for inst in all_instance_nics
            for nic in all_instance_nics[inst]
            for ac in nic["accessConfigs"]
            if nic["kind"]=="compute#networkInterface" and ac["kind"]=="compute#accessConfig"}


print(f"Getting public IPs for back-rawls instances...")

# List all the back-rawls instances so we can get their IPs. There should be only one.
cmd = f'gcloud --project broad-dsde-{args.env} compute instances list'.split() + [f'--filter=name:gce-rawls-{args.env}* AND status:RUNNING AND tags.items=backend', '--format=json']
res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
check_error(res, "Error finding back-rawls, exiting")

back_rawlses = json.loads(res.stdout)
if len(back_rawlses) != 1:
    print(f"Found {len(back_rawlses)} back-rawlses, expecting 1")
    sys.exit(1)

rawls_inst_ips = get_gae_public_ips(back_rawlses)

print(f"Getting public IPs for orchestration instances...")

# List all the orch instances. There will be many.
cmd = f'gcloud --project broad-dsde-{args.env} compute instances list'.split() + [f'--filter=name:gce-firecloud-orchestration-{args.env}* AND status:RUNNING', '--format=json']
res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
check_error(res, "Error finding orch instances, exiting")

orchestrations = json.loads(res.stdout)

orch_inst_ips = get_gae_public_ips(orchestrations)


###
# Nuke all the firewall rules.
###
print(f"Listing all existing firewall rules on project {args.project} so we can delete them.")

cmd = f"gcloud --project {args.project} app firewall-rules list --format=json".split()
res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')

check_error(res, "Error listing firewall rules, exiting")

print(f"Deleting all existing firewall rules on project {args.project}.")
for rule in json.loads(res.stdout):
    if rule["priority"] != 2147483647: # skip the default rule, you can't delete it
        print(f"Deleting rule {rule['action']} {rule['sourceRange']}")
        cmd = f"gcloud --project {args.project} app firewall-rules delete {rule['priority']} --quiet".split()
        res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
        check_error(res, "Error deleting firewall rule, exiting")


def add_gae_firewall_rule(prio, range, description):
    """Adds one firewall rule."""
    print(f"Setting firewall rule ALLOW {range} {description} at priority {prio}")
    cmd = f"gcloud --project {args.project} app firewall-rules create {prio} --action ALLOW --source-range {range} --description".split() + [description]
    res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
    check_error(res, f"Error adding firewall rule for {range} {description}, exiting")


###
# Then re-add Broad firewall rules.
###
print(f"\nSetting Broad firewall rules on project {args.project}.")

print("Setting default firewall rule to DENY")
cmd = f"gcloud --project {args.project} app firewall-rules update default --action deny".split()
res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
check_error(res, "Error updating default firewall rule, exiting")

for (idx, ip_range) in enumerate(broad_range_cidrs):
    add_gae_firewall_rule(1000 + idx, ip_range, "Broad internal network")

ip_count = len(broad_range_cidrs)

###
# Add rule to let Pub/Sub traffic through.
###
print(f"\nSetting Pub/Sub firewall rule.")
add_gae_firewall_rule(1000 + ip_count, PUBSUB_IP_RANGE, "GCP Pub/Sub")

ip_count += 1


###
# Add back-Rawls rules.
###
print(f"\nAdding firewall rule for back-rawls.")

for (idx, rawls_inst) in enumerate(rawls_inst_ips):
    add_gae_firewall_rule(1000 + ip_count + idx, rawls_inst_ips[rawls_inst], rawls_inst)

ip_count += len(rawls_inst_ips)


###
# Add Orchestration rules.
###
print(f"\nAdding firewall rules for Orch instances.")
for (idx, orch_inst) in enumerate(orch_inst_ips):
    add_gae_firewall_rule(1000 + ip_count + idx, orch_inst_ips[orch_inst], orch_inst)


