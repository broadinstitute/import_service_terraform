resource "vault_generic_secret" "app-database-credentials" {
  path = "${var.vault_root}/${local.vault_path}/mysql/user"

  data_json = <<EOT
{
  "username": "${var.mysql_user}",
  "password": "${random_id.mysql-user-password.hex}"
}
EOT
}

resource "vault_generic_secret" "root-database-credentials" {
  path = "${var.vault_root}/${local.vault_path}/mysql/root_user"

  data_json = <<EOT
{
  "username": "root",
  "password": "${random_id.mysql-root-password.hex}"
}
EOT
}

resource "vault_generic_secret" "pubsub-token" {
  path = "${var.vault_root}/${local.vault_path}/pubsub"

  data_json = <<EOT
{
  "secret_token": "${random_uuid.pubsub-secret-token.result}"
}
EOT
}

resource "vault_generic_secret" "app-database-instance-name" {
  path = "${var.vault_root}/${local.vault_path}/mysql/instance_details"

  data_json = <<EOT
  {
  "instance_name": "${module.mysql.cloudsql-instance-name}"
}
EOT
}

resource "vault_generic_secret" "sa_key_deployer" {
  path = "${var.vault_root}/${local.vault_path}/deployer.json"
  data_json = base64decode(google_service_account_key.sa_key_deployer.private_key)
}

# TODO: uncomment when ready to handle the import-service SA outside of terraform-modules
# ** this SA key only exists in qa and dev ** since the key is only needed for BEEs
# resource "vault_generic_secret" "sa_key_import-service" {
#   count = var.env == "qa" || var.env == "dev" ? 1 : 0
#   path = "${var.vault_root}/${local.vault_path}/import-service-account.json"
#   data_json = base64decode(google_service_account_key.sa_key_import-service.private_key)
# }
