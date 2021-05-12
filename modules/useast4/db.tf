resource "google_sql_database" "main" {
  name     = "main"
  instance = google_sql_database_instance.primary.name
}

resource "google_sql_database_instance" "primary" {
  name             = "primary"
  database_version = "POSTGRES_13"
  depends_on       = [google_service_networking_connection.private_vpc_connection]
  region           = var.region_code

  settings {
    # https://cloud.google.com/sql/docs/mysql/instance-settings#settings-2ndgen
    tier = "db-custom-1-3840"

    # Unfortunately it looks like we have to enable public IP so cloud build can connect
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.vpc.self_link
      require_ssl     = false
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    # This is a better value for SSDs (default is 4)
    database_flags {
      name  = "random_page_cost"
      value = "1.1"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
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
  instance = google_sql_database_instance.primary.name
  password = var.db_password
}

resource "google_sql_user" "default_user" {
  name     = "postgres"
  instance = google_sql_database_instance.primary.name
  password = var.db_password
}

