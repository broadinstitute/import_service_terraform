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
+ register import service SA with terra and sam to allow it access to pet keys
