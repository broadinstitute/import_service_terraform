#!/usr/bin/env python3

# This Python 3.5+ script is a workaround for Terraform's inability to reliably create Google App Engine firewall rules.
# This is bugged here, and may be fixed: https://github.com/terraform-providers/terraform-provider-google/issues/5681

# sourced from https://docs.google.com/document/d/1AzTX93P35r2alE4-pviPWf-1LRBWVAF-BwrYKVVpzWo/edit
broad_range_cidrs = [ "69.173.64.0/19",
            "69.173.96.0/20",
            "69.173.112.0/21",
            "69.173.120.0/22",
            "69.173.124.0/23",
            "69.173.126.0/24",
            "69.173.127.0/25",
            "69.173.127.128/26",
            "69.173.127.192/27",
            "69.173.127.240/28" ]


import argparse
import sys
import subprocess
import json


parser = argparse.ArgumentParser(description="""Adds Broad Google App Engine firewall rules to the project given.
Will use your currently logged in gcloud credentials to do so.""")
parser.add_argument("project", help="Google project in which to add the App Engine firewall rules.")
args = parser.parse_args()


def check_error(res, msg):
    if res.returncode != 0:
        print(msg + ':\n')
        print(res.stdout)
        sys.exit(res.returncode)


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

print(f"\nSetting Broad firewall rules on project {args.project}.")

print("Setting default firewall rule to DENY")
cmd = f"gcloud --project {args.project} app firewall-rules update default --action deny".split()
res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')
check_error(res, "Error updating default firewall rule, exiting")

for (idx, ip_range) in enumerate(broad_range_cidrs):
    print(f"Setting firewall rule ALLOW {ip_range} at priority {1000 + idx}")
    cmd = f"gcloud --project {args.project} app firewall-rules create {1000 + idx} --action ALLOW --source-range {ip_range}".split()
    res = subprocess.run(cmd, stderr=subprocess.STDOUT, stdout=subprocess.PIPE, encoding='utf-8')

    check_error(res, f"Error adding firewall rule for IP range {ip_range}, exiting")
