resource "google_cloudfunctions_function_iam_member" "tickets_function_invoker_permission" {
  project        = google_cloudfunctions_function.tickets_function.project
  region         = google_cloudfunctions_function.tickets_function.region
  cloud_function = google_cloudfunctions_function.tickets_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "ticket_details_function_invoker_permission" {
  project        = google_cloudfunctions_function.ticket_details_function.project
  region         = google_cloudfunctions_function.ticket_details_function.region
  cloud_function = google_cloudfunctions_function.ticket_details_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "yahoo_function_invoker_permission" {
  project        = google_cloudfunctions_function.yahoo_function.project
  region         = google_cloudfunctions_function.yahoo_function.region
  cloud_function = google_cloudfunctions_function.yahoo_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloud_run_service_iam_member" "bb_invoker" {
  project  = google_cloudfunctions2_function.bb_function.project
  location = google_cloudfunctions2_function.bb_function.location
  service  = google_cloudfunctions2_function.bb_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_secret_manager_secret_iam_member" "allow_bb_function_access" {
  secret_id = "fmp-api-key" # Created manually
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_cloudfunctions2_function.bb_function.service_config[0].service_account_email}"
}

resource "google_cloudfunctions_function_iam_member" "history_function_invoker_permission" {
  project        = google_cloudfunctions_function.history_function.project
  region         = google_cloudfunctions_function.history_function.region
  cloud_function = google_cloudfunctions_function.history_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "history_function_storage_access" {
  bucket = google_storage_bucket.chat_history.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_cloudfunctions_function.history_function.service_account_email}"
}
