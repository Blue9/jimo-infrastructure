resource "google_artifact_registry_repository" "artifact_repo" {
  provider = google-beta

  location      = var.region_code
  repository_id = var.artifact_repo
  description   = "server builds"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "background_service_repo" {
  provider = google-beta

  location      = var.region_code
  repository_id = "jimo-background-service"
  description   = "background service builds"
  format        = "DOCKER"
}
