resource "google_cloud_tasks_queue" "background_tasks_queue" {
  name = "background-tasks-queue"
  location = "us-central1"
}
