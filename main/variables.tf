variable "var_project" {
  default = "project-name"
}

# Should be updated before prod. Just used the image that was uploaded as test.
variable "var_image_location" {
  default = "us-central1-docker.pkg.dev/goodplaces-app/jimo-server-build-test/server-test:latest"
}