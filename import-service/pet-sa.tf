# Allow the import service account access to get pets.

data "google_service_account_access_token" "sam_access_token" {
  provider               = google
  target_service_account = var.sam_sa_email
  scopes                 = ["https://www.googleapis.com/auth/userinfo.profile",
                            "https://www.googleapis.com/auth/userinfo.email"]
  lifetime               = "300s"
}

resource "null_resource" "import_service_can_get_pets" {
  provisioner "local-exec" {
    command = "./add-import-service-sa-to-sam.sh ${var.env} ${data.google_service_account_access_token.sam_access_token.access_token} ${local.import_service_sa_email}"
  }
}
