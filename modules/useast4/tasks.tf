resource "google_cloud_tasks_queue" "background_tasks_queue" {
  name     = "background-tasks-queue"
  location = "us-central1"

  rate_limits {
    max_dispatches_per_second = 10
    max_concurrent_dispatches = 100
  }

  retry_config {
    max_attempts       = 10
    max_retry_duration = "0s"
    min_backoff        = "0.100s"
    max_backoff        = "120s"
    max_doublings      = 16
  }
}
