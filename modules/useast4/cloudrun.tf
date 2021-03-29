resource "google_cloud_run_service" "jimoserver" {
  # Should be updated before prod
  name     = "jimo-cloudrun-test1"
  location = var.region_code

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  template {
    spec {
      containers {
        # Use the image variable if defined, otherwise default to hello world
        image = var.image == "" ? "gcr.io/cloudrun/hello" : var.image

        # Open port 80
        ports {
          name           = "http1"
          container_port = 80
        }

        # Get the connection name dynamically from the DB
        env {
          name  = var.image == "" ? null : "DATABASE_URL"
          value = var.image == "" ? null : "postgresql://${google_sql_user.db_user.name}:${google_sql_user.db_user.password}@${google_sql_database_instance.master_db.private_ip_address}/${google_sql_database.main.name}?host=/cloudsql/${google_sql_database_instance.master_db.connection_name}"
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
      container_concurrency = 80

      # No idea what this value should be. Needs testing.
      timeout_seconds = 30
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = 1
        "autoscaling.knative.dev/maxScale"        = 10
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.master_db.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "client.knative.dev/user-image"           = var.image == "" ? null : var.image

        # There are auto-added by Cloud Build, might as well just keep them here
        "run.googleapis.com/client-name"    = "gcloud"
        "run.googleapis.com/client-version" = "333.0.0"
        "run.googleapis.com/sandbox"        = "gvisor"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.jimoserver.location
  project     = google_cloud_run_service.jimoserver.project
  service     = google_cloud_run_service.jimoserver.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
