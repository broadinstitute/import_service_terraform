resource "google_pubsub_topic" "import-service-pubsub-topic" {
  name = "import-service-notify"
}

resource "random_uuid" "pubsub-secret-token" {}

resource "google_pubsub_subscription" "import-service-pubsub-subscription" {
  name  = "import-service-notify-push"
  topic = google_pubsub_topic.import-service-pubsub-topic.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = "http://import-service-dot-broad-dsde-dev.appspot.com/_ah/push-handlers/receive_messages?token=${random_uuid.pubsub-secret-token.result}"

    oidc_token = {
      "service_account_email" = "import-service@${module.import-service-project.project_name}.iam.gserviceaccount.com"
      "audience" = "importservice.${var.audience_domain}"
    }

    attributes = {
      x-goog-version = "v1"
    }

  }
}
