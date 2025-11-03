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
