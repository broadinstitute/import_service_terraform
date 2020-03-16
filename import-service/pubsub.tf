resource "google_pubsub_topic" "import-service-pubsub-topic" {
  project = module.import-service-project.project_name
  name = "import-service-notify"
}

resource "random_uuid" "pubsub-secret-token" {}

resource "google_pubsub_subscription" "import-service-pubsub-subscription" {
  project = module.import-service-project.project_name
  name  = "import-service-notify-push"
  topic = google_pubsub_topic.import-service-pubsub-topic.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = "https://${google_app_engine_application.gae_import_service.default_hostname}/_ah/push-handlers/receive_messages?token=${random_uuid.pubsub-secret-token.result}"

    oidc_token {
      service_account_email = "import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
      audience = "importservice.${var.audience_domain}"
    }
  }
}

# import service can publish to its own topic
resource "google_pubsub_topic_iam_member" "rawls_can_publish" {
  project = module.import-service-project.project_name
  topic = google_pubsub_topic.import-service-pubsub-topic.name
  role = "roles/pubsub.publisher"
  member = "serviceAccount:import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
}

# rawls can publish to import service's topic
resource "google_pubsub_topic_iam_member" "rawls_can_publish" {
  project = module.import-service-project.project_name
  topic = google_pubsub_topic.import-service-pubsub-topic.name
  role = "roles/pubsub.publisher"
  member = "serviceAccount:import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
}

# import service can publish to rawls' topic
resource "google_pubsub_topic_iam_member" "importservice_publish_to_rawls" {
  project = var.rawls_google_project
  topic = var.rawls_import_pubsub_topic
  role = "roles/pubsub.publisher"
  member = "serviceAccount:import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
}
