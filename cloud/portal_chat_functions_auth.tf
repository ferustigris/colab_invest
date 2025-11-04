resource "google_secret_manager_secret_iam_member" "allow_ask_chat_function_access" {
  secret_id = "chatgpt-api-key" # Created manually
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_cloudfunctions_function.ask_chat_function.service_account_email}"
}

resource "google_cloudfunctions_function_iam_member" "ask_chat_function_invoker_permission" {
  project        = google_cloudfunctions_function.ask_chat_function.project
  region         = google_cloudfunctions_function.ask_chat_function.region
  cloud_function = google_cloudfunctions_function.ask_chat_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


resource "google_secret_manager_secret_iam_member" "allow_ask_sales_chat_function_access" {
  secret_id = "chatgpt-api-key" # Created manually
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_cloudfunctions_function.ask_sales_chat_function.service_account_email}"
}

resource "google_cloudfunctions_function_iam_member" "ask_sales_chat_function_invoker_permission" {
  project        = google_cloudfunctions_function.ask_sales_chat_function.project
  region         = google_cloudfunctions_function.ask_sales_chat_function.region
  cloud_function = google_cloudfunctions_function.ask_sales_chat_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


resource "google_secret_manager_secret_iam_member" "allow_nvr_support_chat_function_access" {
  secret_id = "chatgpt-api-key" # Created manually
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_cloudfunctions_function.ask_nvr_support_chat_function.service_account_email}"
}

resource "google_cloudfunctions_function_iam_member" "ask_nvr_support_chat_function_invoker_permission" {
  project        = google_cloudfunctions_function.ask_nvr_support_chat_function.project
  region         = google_cloudfunctions_function.ask_nvr_support_chat_function.region
  cloud_function = google_cloudfunctions_function.ask_nvr_support_chat_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


resource "google_secret_manager_secret_iam_member" "allow_send_to_telegram_bot_function_access" {
  secret_id = "colab-invest-telegram-token" # Created manually
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_cloudfunctions_function.send_to_telegram_bot.service_account_email}"
}

resource "google_cloudfunctions_function_iam_member" "send_to_telegram_bot_function_invoker_permission" {
  project        = google_cloudfunctions_function.send_to_telegram_bot.project
  region         = google_cloudfunctions_function.send_to_telegram_bot.region
  cloud_function = google_cloudfunctions_function.send_to_telegram_bot.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


resource "google_cloudfunctions_function_iam_member" "telegram_bot_handler_function_invoker_permission" {
  project        = google_cloudfunctions_function.telegram_bot_handler.project
  region         = google_cloudfunctions_function.telegram_bot_handler.region
  cloud_function = google_cloudfunctions_function.telegram_bot_handler.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "chat_history_function_invoker_permission" {
  project        = google_cloudfunctions_function.chat_history_function.project
  region         = google_cloudfunctions_function.chat_history_function.region
  cloud_function = google_cloudfunctions_function.chat_history_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "chat_history_function_storage_access" {
  bucket = google_storage_bucket.chat_history.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_cloudfunctions_function.chat_history_function.service_account_email}"
}
