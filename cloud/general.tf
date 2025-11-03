resource "google_artifact_registry_repository" "python_repo" {
  provider           = google
  location           = var.region
  repository_id      = "simple"
  description        = "Private Python repo for functions"
  format             = "PYTHON"
  mode               = "STANDARD_REPOSITORY"
  
  depends_on = [google_project_service.artifact_registry]
}
