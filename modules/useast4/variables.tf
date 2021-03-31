variable "project" {
  type = string
}

variable "image" {
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
  type = string
}

variable "region_code" {
  # Should be updated before prod. Just used the image that was uploaded as test.
  default = "us-east4"
}
