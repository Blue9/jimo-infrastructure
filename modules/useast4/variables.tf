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

variable "default_postgres_password" {
  type      = string
  sensitive = true
}

variable "artifact_repo" {
  type = string
}

variable "region_code" {
  default = "us-east4"
}
