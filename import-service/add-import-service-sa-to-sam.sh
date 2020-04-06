#! /bin/bash

# Pulls the Sam policy of SAs allowed to get user pets and updates the list to include import service.

CURR_DIR=$1
ENV=$2
SAM_TOKEN=$3
IMPORT_SERVICE_SA=$4
IMPORT_SERVICE_TOKEN=$5

# register import service as a new account with sam.
REG_STATUS=$(curl -o /dev/null -w '%{http_code}' -H "content-type: application/json" -H "Authorization: bearer $IMPORT_SERVICE_TOKEN" -X POST "https://sam.dsde-$ENV.broadinstitute.org/register/user/v2/self")

if [[ ${REG_STATUS} -ne 201 ]] && [[ ${REG_STATUS} -ne 409 ]]; then
    echo "Failed to register import service. Response code ${REG_STATUS}. Exiting..."
    exit 1
fi

curl -f -H "content-type: application/json" -H "Authorization: bearer $SAM_TOKEN" "https://sam.dsde-$ENV.broadinstitute.org/api/resource/cloud-extension/google/policies/fc-service-accounts" > current_policy.json

$CURR_DIR/add_to_sam_policy_members.py "$IMPORT_SERVICE_SA" current_policy.json new_policy.json

UPDATE_STATUS=$(curl -o /dev/null -w '%{http_code}' -H "content-type: application/json" -X PUT -H "Authorization: bearer $SAM_TOKEN" -d @new_policy.json "https://sam.dsde-$ENV.broadinstitute.org/api/resource/cloud-extension/google/policies/fc-service-accounts")

if [[ ${UPDATE_STATUS} -ne 201 ]] && [[ ${UPDATE_STATUS} -ne 204 ]] && [[ ${UPDATE_STATUS} -ne 409 ]]; then
  echo "Failed to update policy to allow Sam to access pet keys. Response code ${UPDATE_STATUS}. Exiting..."
  exit 1
fi
