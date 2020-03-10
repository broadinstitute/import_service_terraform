module "import-service" {
  source  = "github.com/broadinstitute/import_service_terraform.git//import-service?ref=wip"
  project = "${var.google_project}"
}
