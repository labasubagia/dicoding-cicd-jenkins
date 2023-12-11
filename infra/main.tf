resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-node-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "default" {
  name         = "vm"
  machine_type = "e2-small"
  zone         = "us-east1-b"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  metadata_startup_script = file("./startup.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.default.id
    access_config {

    }
  }
}


# port ssh
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# port jenkins
resource "google_compute_firewall" "jenkins" {
  name    = "jenkins-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["9000", "49000"]
  }
  source_ranges = ["0.0.0.0/0"]
}


# port grafana
resource "google_compute_firewall" "grafana" {
  name    = "grafana-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["3031"]
  }
  source_ranges = ["0.0.0.0/0"]
}


# port prometheus
resource "google_compute_firewall" "prometheus" {
  name    = "prometheus-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["9091"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# port for apps
resource "google_compute_firewall" "app" {
  name    = "app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8501"]
  }
  source_ranges = ["0.0.0.0/0"]
}
