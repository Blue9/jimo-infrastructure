resource "google_secret_manager_secret" "ssh_key" {
  secret_id = "ssh-key"

  replication {
    user_managed {
      replicas {
        location = "us-central1"
      }
      replicas {
        location = "us-east4"
      }
    }
  }
}
