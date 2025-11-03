#### Chat ####

resource "google_cloudfunctions_function" "ask_chat_function" {
  name        = "ask-chat"
  description = "Ask assistant for help"
  region      = "europe-west1"
  entry_point = "ask_chat"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.ask_chat_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    HISTORIZER_URL = "https://europe-west1-video-processing-458313.cloudfunctions.net/chat-history"
    SALES_BOT_URL = "https://europe-west1-video-processing-458313.cloudfunctions.net/ask-sales-chat"
    NVR_SUPPORT_URL = "https://europe-west1-video-processing-458313.cloudfunctions.net/ask-nvr-support-chat"
    HUMAN_SUPPORT_URL = "https://europe-west1-video-processing-458313.cloudfunctions.net/send_to_telegram_bot"
    TELEGRAM_CHAT_ID = "5081253547"
  }
  depends_on = [
    google_storage_bucket_object.ask_chat_source,
    google_service_account.default_compute
  ]
}

resource "google_cloudfunctions_function" "ask_sales_chat_function" {
  name        = "ask-sales-chat"
  description = "Ask sales assistant for help"
  region      = "europe-west1"
  entry_point = "ask_sales_chat"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.ask_sales_chat_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
  }
  depends_on = [
    google_storage_bucket_object.ask_sales_chat_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "ask_sales_chat_function_dist" {
  type        = "zip"
  source_dir  = "./functions/ask_sales_chat"
  output_path = "function/ask_sales_chat_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "ask_sales_chat_source" {
  name   = "ask_sales_chat-source.${data.archive_file.ask_sales_chat_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.ask_sales_chat_function_dist.output_path
}

resource "google_cloudfunctions_function" "ask_nvr_support_chat_function" {
  name        = "ask-nvr-support-chat"
  description = "Ask nvr support assistant for help"
  region      = "europe-west1"
  entry_point = "ask_nvr_support_chat"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.ask_nvr_support_chat_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
  }
  depends_on = [
    google_storage_bucket_object.ask_nvr_support_chat_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "ask_nvr_support_chat_function_dist" {
  type        = "zip"
  source_dir  = "./functions/ask_nvr_support_chat"
  output_path = "function/ask_nvr_support_chat_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "ask_nvr_support_chat_source" {
  name   = "ask_nvr_support_chat-source.${data.archive_file.ask_nvr_support_chat_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.ask_nvr_support_chat_function_dist.output_path
}

data "archive_file" "ask_chat_function_dist" {
  type        = "zip"
  source_dir  = "./functions/ask_chat"
  output_path = "function/ask_chat_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "ask_chat_source" {
  name   = "ask_chat-source.${data.archive_file.ask_chat_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.ask_chat_function_dist.output_path
}

resource "google_cloudfunctions_function" "chat_history_function" {
  name        = "chat-history"
  description = "Save/get history of chat"
  region      = "europe-west1"
  entry_point = "chat_history"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.chat_history_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    CHAT_HISTORY_BUCKET = google_storage_bucket.chat_history.name
  }
  depends_on = [
    google_storage_bucket_object.chat_history_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "chat_history_function_dist" {
  type        = "zip"
  source_dir  = "./functions/chat_history"
  output_path = "function/chat_history_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "chat_history_source" {
  name   = "chat_history-source.${data.archive_file.chat_history_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.chat_history_function_dist.output_path
}

#### telegram bot ####

resource "google_cloudfunctions_function" "send_to_telegram_bot" {
  name        = "send_to_telegram_bot"
  description = "send_to_telegram_bot"
  region      = "europe-west1"
  entry_point = "send_to_telegram_bot"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.send_to_telegram_bot_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
  }
  depends_on = [
    google_storage_bucket_object.send_to_telegram_bot_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "send_to_telegram_bot_dist" {
  type        = "zip"
  source_dir  = "./functions/send_to_telegram_bot"
  output_path = "function/send_to_telegram_bot_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "send_to_telegram_bot_source" {
  name   = "send_to_telegram_bot-source.${data.archive_file.send_to_telegram_bot_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.send_to_telegram_bot_dist.output_path
}

resource "google_cloudfunctions_function" "telegram_bot_handler" {
  name        = "telegram_bot_handler"
  description = "telegram_bot_handler"
  region      = "europe-west1"
  entry_point = "telegram_bot_handler"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.telegram_bot_handler_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    HISTORIZER_URL = "https://europe-west1-video-processing-458313.cloudfunctions.net/chat-history"
  }
  depends_on = [
    google_storage_bucket_object.telegram_bot_handler_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "telegram_bot_handler_dist" {
  type        = "zip"
  source_dir  = "./functions/telegram_bot_handler"
  output_path = "function/telegram_bot_handler_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "telegram_bot_handler_source" {
  name   = "telegram_bot_handler-source.${data.archive_file.telegram_bot_handler_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.telegram_bot_handler_dist.output_path
}
