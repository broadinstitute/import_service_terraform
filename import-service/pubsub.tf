resource "google_pubsub_topic" "import-service-pubsub-topic" {
  project = module.import-service-project.project_name
  name = "import-service-notify-${var.env}"
}

resource "random_uuid" "pubsub-secret-token" {}

resource "google_pubsub_subscription" "import-service-pubsub-subscription" {
  project = module.import-service-project.project_name
  name  = "import-service-notify-push"
  topic = google_pubsub_topic.import-service-pubsub-topic.name

  ack_deadline_seconds = 600

  expiration_policy {
    ttl = ""
  }

  push_config {
    push_endpoint = "https://${google_app_engine_application.gae_import_service.app_id}.appspot.com/_ah/push-handlers/receive_messages?token=${random_uuid.pubsub-secret-token.result}"

    oidc_token {
      service_account_email = local.import_service_sa_email
      audience = "importservice.${var.audience_domain}"
    }
  }
}

# import service can publish to its own topic
resource "google_pubsub_topic_iam_member" "importservice_can_publish" {
  project = module.import-service-project.project_name
  topic = google_pubsub_topic.import-service-pubsub-topic.name
  role = "roles/pubsub.publisher"
  member = "serviceAccount:${local.import_service_sa_email}"
}

# rawls can publish to import service's topic
resource "google_pubsub_topic_iam_member" "rawls_can_publish" {
  project = module.import-service-project.project_name
  topic = google_pubsub_topic.import-service-pubsub-topic.name
  role = "roles/pubsub.publisher"
  member = "serviceAccount:${var.rawls_sa_email}"
}

# import service can publish to rawls' topic
resource "google_pubsub_topic_iam_member" "importservice_publish_to_rawls" {
  project = var.terra_google_project
  topic = local.rawls_import_pubsub_topic
  role = "roles/pubsub.publisher"
  member = "serviceAccount:${local.import_service_sa_email}"
}

# cWDS can publish to that topic, too
resource "google_pubsub_topic_iam_member" "cwds_publish_to_rawls" {
  project = var.terra_google_project
  topic = local.rawls_import_pubsub_topic
  role = "roles/pubsub.publisher"
  member = "serviceAccount:${local.cwds_service_account}"
}