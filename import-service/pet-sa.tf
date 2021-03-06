# Allow the import service account access to get pets.

data "google_service_account_access_token" "sam_access_token" {
  provider               = google
  target_service_account = var.sam_sa_email
  scopes                 = ["https://www.googleapis.com/auth/userinfo.profile",
                            "https://www.googleapis.com/auth/userinfo.email"]
  lifetime               = "300s"
}

# FIXME This could simply run as a script but neither python nor jq are installed on Atlantis Terraform VMs :(
# So we add it as a manual step in the ATTENTION output in output.tf.
#resource "null_resource" "import_service_can_get_pets" {
#  provisioner "local-exec" {
#    command = "${path.module}/add-import-service-sa-to-sam.sh ${path.module} ${var.env} ${data.google_service_account_access_token.sam_access_token.access_token} ${local.import_service_sa_email} ${data.google_service_account_access_token.import_service_token.access_token}"
#  }
#}
