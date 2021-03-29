resource "google_sql_database" "main" {
  name     = "main"
  instance = google_sql_database_instance.master_db.name
}

resource "google_sql_database_instance" "master_db" {
  name             = "master-instance"
  database_version = "POSTGRES_13"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  region           = var.region_code

  settings {
    # We should maybe change this before launch.
    # https://cloud.google.com/sql/docs/mysql/instance-settings#settings-2ndgen
    tier = "db-f1-micro"

    # Unfortunately it looks like we have to enable public IP so cloud build can connect
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.self_link
    }

    # Tuesday at 9am UTC = 5am ET
    maintenance_window {
      day          = 2
      hour         = 9
      update_track = "stable"
    }

    # Back up DB to central region and store 10 backups.
    backup_configuration {
      enabled  = true
      location = "us-central1"
      backup_retention_settings {
        retention_unit   = "COUNT"
        retained_backups = 10
      }
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = var.db_username
  instance = google_sql_database_instance.master_db.name
  password = var.db_password
}
