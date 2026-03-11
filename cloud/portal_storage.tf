locals {
  portal_web_files = fileset("${path.module}/../portal_ux/web", "**")
}

resource "null_resource" "firebase_hosting_deploy" {
  depends_on = [google_project_service.firebase_hosting]

  triggers = {
    # Re-deploy hosting when any source web file or pubspec changes.
    web_hashes    = sha1(join("", [for f in local.portal_web_files : filebase64sha256("${path.module}/../portal_ux/web/${f}")]))
    pubspec_hash  = filebase64sha256("${path.module}/../portal_ux/pubspec.yaml")
    firebase_hash = filebase64sha256("${path.module}/../portal_ux/firebase.json")
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/../portal_ux && flutter build web --release && npx -y firebase-tools deploy --only hosting --project ${var.project}"
  }
}

resource "google_storage_bucket" "chat_history" {
  name          = "${var.project}-chat-history"
  location      = var.region
}
