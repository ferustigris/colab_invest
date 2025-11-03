resource "google_storage_bucket" "colab-invest-helper-terraform-state" {
  name     = "${var.project}-terraform-state"
  location = var.region
}

resource "google_storage_bucket" "src_bucket" {
  name     = "${var.project}-src-bucket"
  location = var.region
}
