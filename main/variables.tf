variable "var_project" {
  default = "goodplaces-app"
}

# If null, use the hello world image (this is useful on the first run when we
# don't have any images)
variable "var_image_location" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "artifact_repo" {
  default = "jimo-server-repo"
}
