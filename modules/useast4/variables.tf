variable "project" {
  type = string
}

variable "image" {
  type = string
}

variable "region_code" {
  # Should be updated before prod. Just used the image that was uploaded as test.
  default = "us-east-4"
}