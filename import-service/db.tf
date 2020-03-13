resource "random_id" "mysql-user-password" {
  byte_length   = 16
}

resource "random_id" "mysql-root-password" {
  byte_length   = 16
}

module "mysql" {
  source        = "github.com/broadinstitute/terraform-shared.git//terraform-modules/cloudsql-mysql"

  providers = {
    google.target =  google.target,
    google.dns =  google.target
  }
  project       = module.import-service-project.project_name
  cloudsql_name = "import-service-db"
  cloudsql_database_name = "isvc"
  cloudsql_database_user_name = "isvc"
  cloudsql_database_user_password = random_id.mysql-user-password.hex
  cloudsql_database_root_password = random_id.mysql-root-password.hex
}
