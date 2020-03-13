resource "vault_generic_secret" "app-database-credentials" {
  path = "${var.vault_root}/${local.vault_path}/mysql/user"

  data_json = <<EOT
{
  "username": "var.mysql_user",
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
