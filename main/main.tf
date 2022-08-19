provider "google" {
  credentials = file("creds.json")
  project     = var.var_project
}

provider "google-beta" {
  credentials = file("creds.json")
  project     = var.var_project
}

terraform {
  backend "gcs" {
    # Can't use variables here so have to hardcode the bucket
    credentials = "./creds.json"
    bucket      = "goodplaces-app-tfstate"
    prefix      = "terraform/state"
  }
}

# Can add additional regions and shared variables later
module "useast4" {
  source                      = "../modules/useast4"
  project                     = var.var_project
  image                       = var.var_image_location
  db_username                 = var.db_username
  db_password                 = var.db_password
  default_postgres_password   = var.default_postgres_password
  artifact_repo               = var.artifact_repo
  allow_origin                = var.allow_origin
}
