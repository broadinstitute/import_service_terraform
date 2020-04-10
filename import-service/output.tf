output "ATTENTION" {
  value = <<EOF
THIS PROFILE REQUIRES MANUAL STEPS!
To run the manual steps run these scripts in the import-service directory:
./setup_gae_firewall.py ${module.import-service-project.project_name} ${var.env}
./add-import-service-sa-to-sam.sh ${var.env} ${data.google_service_account_access_token.sam_access_token.access_token} ${local.import_service_sa_email} ${data.google_service_account_access_token.import_service_token.access_token}
EOF
}
