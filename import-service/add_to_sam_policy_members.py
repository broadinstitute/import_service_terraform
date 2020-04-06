#!/usr/bin/env python

import argparse
import json

parser = argparse.ArgumentParser(description="""Adds import service SA to Sam policy JSON""")
parser.add_argument("import_service_sa", help="Import service SA email")
parser.add_argument("current_policy", type=argparse.FileType('r'), help="Current policy JSON file")
parser.add_argument("output_policy", type=argparse.FileType('w'), help="Output policy JSON file")
args = parser.parse_args()

policy = json.load(args.current_policy)
if args.import_service_sa not in policy["memberEmails"]:
    policy["memberEmails"] += [args.import_service_sa]

json.dump(policy, args.output_policy)
