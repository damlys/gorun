resource "google_monitoring_uptime_check_config" "this" {
  project      = var.google_project.project_id
  display_name = var.request_host

  period  = "600s"
  timeout = "5s"

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.google_project.project_id
      host       = var.request_host
    }
  }
  http_check {
    request_method = var.request_method
    path           = var.request_path
    use_ssl        = true
    validate_ssl   = true
  }
  content_matchers {
    matcher = "CONTAINS_STRING"
    content = var.response_content
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_monitoring_notification_channel" "email" {
  for_each = var.notification_emails

  project      = var.google_project.project_id
  display_name = each.value
  type         = "email"
  labels = {
    email_address = each.value
  }
}

resource "google_monitoring_alert_policy" "this" {
  project      = var.google_project.project_id
  display_name = "${var.request_host} availability"
  enabled      = true

  combiner = "OR"
  conditions {
    display_name = "${var.request_host} is down"

    condition_threshold {
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.this.uptime_check_id}\""
      aggregations {
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        alignment_period     = "1200s"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.*"]
      }
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      duration        = "0s"

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [for k, v in google_monitoring_notification_channel.email : v.id]
}
