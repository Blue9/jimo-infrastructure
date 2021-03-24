provider "google" {
  credentials = file("creds.json")
  project     = var.var_project
}

# Can add additional regions and shared variables later
module "useast4" {
  source  = "../modules/useast4"
  project = var.var_project
  image = var.var_image_location
}