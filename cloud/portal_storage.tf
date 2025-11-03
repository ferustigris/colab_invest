resource "google_storage_bucket" "flutter_web" {
  
  name          = "${var.project}-web"
  location      = var.region

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "public" {
  bucket = google_storage_bucket.flutter_web.name
  role   = "roles/storage.objectViewer"
  members = ["allUsers"]
}


resource "google_storage_bucket_object" "flutter_assets" {
  name   = "${each.value}"
  bucket = google_storage_bucket.flutter_web.name
  source = "${path.module}/../portal_ux/build/web/${each.value}"
  content_type = lookup(
    {
      "index.html"     = "text/html"
      "main.dart.js"   = "application/javascript"
      "flutter.js"     = "application/javascript"
      "favicon.png"    = "image/png"
      "manifest.json"  = "application/json"
    },
    each.value,
    "application/octet-stream"
  )
  for_each = fileset("${path.module}/../portal_ux/build/web", "**")
  depends_on = [null_resource.flutter_assets_trigger]
}
resource "null_resource" "flutter_assets_trigger" {
  for_each = fileset("${path.module}/../portal_ux/build/web", "**")

  triggers = {
    file_hash = filebase64sha256("${path.module}/../portal_ux/build/web/${each.value}")
  }
}

resource "google_storage_bucket" "chat_history" {
  name          = "${var.project}-chat-history"
  location      = var.region
}
