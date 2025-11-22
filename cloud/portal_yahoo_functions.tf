resource "google_cloudfunctions_function" "tickets_function" {
  name        = "tickets"
  description = "Ask assistant for help"
  region      = "europe-west1"
  entry_point = "tickets"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.tickets_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    HISTORIZER_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/history"
  }
  depends_on = [
    google_storage_bucket_object.tickets_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "tickets_function_dist" {
  type        = "zip"
  source_dir  = "./functions/tickets"
  output_path = "function/tickets_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "tickets_source" {
  name   = "tickets-source.${data.archive_file.tickets_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.tickets_function_dist.output_path
}


resource "google_cloudfunctions_function" "ticket_details_function" {
  name        = "ticket_details"
  description = "Ask assistant for help"
  region      = "europe-west1"
  entry_point = "ticket_details"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.ticket_details_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    TELEGRAM_CHAT_ID = "5081253547"
    CHAT_HISTORY_BUCKET = google_storage_bucket.chat_history.name
    YAHOO_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/yahoo"
    BB_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/bb"
    HISTORIZER_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/history"
    GET_METRIC_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/get_metric"
  }
  depends_on = [
    google_storage_bucket_object.ticket_details_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "ticket_details_function_dist" {
  type        = "zip"
  source_dir  = "./functions/ticket_details"
  output_path = "function/ticket_details_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "ticket_details_source" {
  name   = "ticket_details-source.${data.archive_file.ticket_details_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.ticket_details_function_dist.output_path
}



resource "google_cloudfunctions_function" "yahoo_function" {
  name        = "yahoo"
  description = "Ask assistant for help"
  region      = "europe-west1"
  entry_point = "yahoo"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.yahoo_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    TELEGRAM_CHAT_ID = "5081253547"
    HISTORIZER_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/history"
  }
  depends_on = [
    google_storage_bucket_object.yahoo_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "yahoo_function_dist" {
  type        = "zip"
  source_dir  = "./functions/yahoo"
  output_path = "function/yahoo_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "yahoo_source" {
  name   = "yahoo-source.${data.archive_file.yahoo_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.yahoo_function_dist.output_path
}


resource "google_cloudfunctions2_function" "bb_function" {
  name        = "bb"
  description = "OpenBB financial data function"
  location    = "europe-west1"

  build_config {
    runtime     = "python311"
    entry_point = "bb"
    
    source {
      storage_source {
        bucket = google_storage_bucket.src_bucket.name
        object = google_storage_bucket_object.bb_source.name
      }
    }
    
    docker_repository = "projects/${data.google_project.project.project_id}/locations/europe-west1/repositories/gcf-artifacts"
  }

  service_config {
    max_instance_count = 10
    available_memory   = "1Gi"
    available_cpu      = "1"
    timeout_seconds    = 120
    ingress_settings   = "ALLOW_ALL"
    
    environment_variables = {
      GOOGLE_FUNCTION_SOURCE = "main.py"
      GCLOUD_PROJECT = data.google_project.project.project_id
      GCLOUD_PROJECT_NUMBER = data.google_project.project.number
      HISTORIZER_URL = "https://europe-west1-colab-invest-helper.cloudfunctions.net/history"
    }
    
    service_account_email = google_service_account.default_compute.email
  }

  depends_on = [
    google_storage_bucket_object.bb_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "bb_function_dist" {
  type        = "zip"
  source_dir  = "./functions/bb"
  output_path = "function/bb_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "bb_source" {
  name   = "bb-source.${data.archive_file.bb_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.bb_function_dist.output_path
}


resource "google_cloudfunctions_function" "history_function" {
  name        = "history"
  description = "Ask assistant for help"
  region      = "europe-west1"
  entry_point = "history"

  runtime = "python311"

  source_archive_bucket = google_storage_bucket.src_bucket.name
  source_archive_object = google_storage_bucket_object.history_source.name

  trigger_http = true
  service_account_email = google_service_account.default_compute.email

  environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
    GCLOUD_PROJECT = data.google_project.project.project_id
    GCLOUD_PROJECT_NUMBER = data.google_project.project.number
    CHAT_HISTORY_BUCKET = google_storage_bucket.chat_history.name
  }
  depends_on = [
    google_storage_bucket_object.history_source,
    google_service_account.default_compute
  ]
}

data "archive_file" "history_function_dist" {
  type        = "zip"
  source_dir  = "./functions/history"
  output_path = "function/history_dist${local.always_trigger}.zip"
  depends_on = [local.always_trigger]
}

resource "google_storage_bucket_object" "history_source" {
  name   = "history-source.${data.archive_file.history_function_dist.output_md5}.zip"
  bucket = google_storage_bucket.src_bucket.name
  source = data.archive_file.history_function_dist.output_path
}
