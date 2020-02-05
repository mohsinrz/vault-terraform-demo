resource "google_container_cluster" "demo-cluster" {
  provider = "google-beta"
  name     = "demo-cluster"
  project  = var.project
  location = "${var.region}-a"

  initial_node_count = 1
  network            = "projects/${var.project}/global/networks/default"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  enable_binary_authorization = true

  node_config {
    machine_type = "n1-standard-2"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}