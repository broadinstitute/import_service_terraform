#! /bin/bash

ENV=$1
SAM_TOKEN=$2
IMPORT_SERVICE_SA=$3

# Pulls the Sam policy of SAs allowed to get user pets and updates the list to include import service.

curl -H "content-type: application/json" -H "Authorization: bearer $SAM_TOKEN" "https://sam.dsde-$ENV.broadinstitute.org/api/resource/cloud-extension/google/policies/fc-service-accounts" > current_policy.json

jq ".memberEmails[.memberEmails| length] += \"$IMPORT_SERVICE_SA\"" current_policy.json > new_policy.json

curl -H "content-type: application/json" -X PUT -H "Authorization: bearer $SAM_TOKEN" -d @new_policy.json "https://sam.dsde-$ENV.broadinstitute.org/api/resource/cloud-extension/google/policies/fc-service-accounts"
