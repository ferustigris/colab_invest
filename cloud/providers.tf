provider "google" {
  project = var.project
  region  = var.region
}

data "google_project" "project" {
  project_id = var.project
}

terraform {
  backend "gcs" {
    bucket  = "colab-invest-helper-terraform-state"
    prefix  = "terraform/state/colab-invet-helper"
  }
}

terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.7.1"
    }
  }
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}