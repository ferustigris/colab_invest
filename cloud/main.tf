resource "google_project_service" "cloud_functions" {
  project = var.project
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloud_run" {
  project = var.project
  service = "run.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  project = var.project
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "secret_manager" {
  project = var.project
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "storage" {
  project = var.project
  service = "storage.googleapis.com"
}

resource "google_project_service" "cloud_build" {
  project = var.project
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"
}

resource "google_service_account" "default_compute" {
  account_id   = "compute-default"
  display_name = "Compute Engine default service account"
  description  = "Default service account for Compute Engine and Cloud Functions"
  project      = var.project
  depends_on   = [google_project_service.compute]
}

locals {
  always_trigger = timestamp()
}
