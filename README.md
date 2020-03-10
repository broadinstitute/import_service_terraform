# import_service_terraform
Terraform for import service


TODOs:

+ create project terra-importservice-env
+ create import service SA
+ give import SA pubsub admin and token creator permissions in terra-importservice-env
+ give terra-importservice-env GAE SA token creator permissions on import service SA
+ database
+ pubsub topic and subscription
+ create bucket for translated imports
+ firewall around GAE


manual (unless terraform can run arbitrary sh):
- add import service SA to sam cloud-extension/fc-service-accounts policy [here](https://github.com/broadinstitute/firecloud-develop/blob/dev/run-context/live/scripts/migrations/sam_google_extensions_security.sh#L26)
- example of terraform calling sh [here](https://github.com/broadinstitute/terraform-terra/blob/master/profiles/terra-ui/terraform/terra-ui/deploy.tf)
