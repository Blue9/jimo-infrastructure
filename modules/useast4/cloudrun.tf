resource "google_cloud_run_service" "jimoserver" {
  name     = "jimo-cloudrun"
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
          value = var.image == "" ? null : "postgresql://${google_sql_user.db_user.name}:${google_sql_user.db_user.password}@${google_sql_database_instance.primary.private_ip_address}/${google_sql_database.main.name}"
        }

        resources {
          # 1000 millicores (1 core) and 1024 Mebibytes (~1024MB)
          # https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-resource-requests-and-limits
          limits = {
            cpu    = "1000m"
            memory = "1024Mi"
          }
        }
      }
      container_concurrency = 40

      timeout_seconds = 30
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = 1
        "autoscaling.knative.dev/maxScale"        = 10
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.primary.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "client.knative.dev/user-image"           = var.image == "" ? null : var.image
      }
    }
  }
}

resource "google_cloud_run_service" "background_tasks" {
  name     = "jimo-background-tasks"
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
        image = var.background_tasks_image == "" ? "gcr.io/cloudrun/hello" : var.background_tasks_image

        # Open port 80
        ports {
          name           = "http1"
          container_port = 80
        }

        # Get the connection name dynamically from the DB
        env {
          name  = var.background_tasks_image == "" ? null : "DATABASE_URL"
          value = var.background_tasks_image == "" ? null : "postgresql://${google_sql_user.db_user.name}:${google_sql_user.db_user.password}@${google_sql_database_instance.primary.private_ip_address}/${google_sql_database.main.name}"
        }

        resources {
          # 1000 millicores (1 core) and 1024 Mebibytes (~1024MB)
          # https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-resource-requests-and-limits
          limits = {
            cpu    = "1000m"
            memory = "1024Mi"
          }
        }
      }
      container_concurrency = 40

      timeout_seconds = 30
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = 1
        "autoscaling.knative.dev/maxScale"        = 10
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.primary.connection_name
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "client.knative.dev/user-image"           = var.background_tasks_image == "" ? null : var.background_tasks_image
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
