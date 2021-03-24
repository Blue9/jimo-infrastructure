resource "google_cloud_run_service" "jimoserver" {
  # Should be updated before prod
  name     = "jimo-cloudrun-test1"
  location = var.region_code

  traffic {
    percent = 100
  }

  template {
    spec {
      containers {
        # Use the image variable defined in main/variables.tf
        image = var.image

        # Open port 80
        ports {
          name           = "APIGateway port"
          container_port = 80
        }

        # Get the connection name dynamically from the DB
        env {
          name  = "DATABASE_URL"
          value = "postgresql://postgres@${google_sql_database_instance.master_db.private_ip_address}/postgres?host=/cloudsql/${google_sql_database_instance.master_db.connection_name}"
        }

        resources {
          # 1000 millicores (1 core) and 256 Mebibytes (~256MB)
          # https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-resource-requests-and-limits
          limits = {
            cpu    = "1000m"
            memory = "256Mi"
          }
        }
      }
      # No idea what this value should be. Needs testing.
      container_concurrency = 200

      # No idea what this value should be. Needs testing.
      timeout_seconds = 10
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"      = 1
        "autoscaling.knative.dev/maxScale"      = 10
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.master_db.connection_name
      }
    }
  }
}