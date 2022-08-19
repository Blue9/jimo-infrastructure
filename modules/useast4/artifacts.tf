resource "google_artifact_registry_repository" "artifact_repo" {
  provider = google-beta

  location      = var.region_code
  repository_id = var.artifact_repo
  description   = "server builds"
  format        = "DOCKER"
}
