resource "google_sql_database_instance" "master_db" {
  name             = "master-instance"
  database_version = "POSTGRES_12"
  region           = var.region_code

  settings {
    # We should maybe change this before launch.
    # https://cloud.google.com/sql/docs/mysql/instance-settings#settings-2ndgen
    tier = "db-f1-micro"

    # Only allow connections within the VPC
    ip_configuration {
      ipv4_enabled = false
      private_network = "projects/${var.project}/global/networks/default"
      require_ssl = false
    }

    # Tuesday at 11am UTC = 5am EST
    maintenance_window {
      day = 2
      hour = 11
      update_track = "stable"
    }

    # Back up DB to central region and store 10 backups.
    backup_configuration {
      enabled = true
      location = "us-central1"
      backup_retention_settings {
        retention_unit = "COUNT"
        retained_backups = 10
      }
    }
  }
}