terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = "igneous-ethos-461009-m3"
  region  = "us-central1"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
