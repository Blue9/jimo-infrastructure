resource "google_compute_network" "vpc" {
  name = "default-vpc"
}

# Reserve internal address range for peering
resource "google_compute_global_address" "private_ip_block" {
  name          = "default-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.vpc.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

# Allow Cloud run to connect
resource "google_vpc_access_connector" "vpc_connector" {
  name          = "vpc-connector"
  region        = var.region_code
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.vpc.name
}
