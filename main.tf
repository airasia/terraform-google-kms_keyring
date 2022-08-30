terraform {
  required_version = ">= 0.13.1" # see https://releases.hashicorp.com/terraform/
}

data "google_client_config" "google_client" {}

resource "google_project_service" "kms_api" {
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "key_ring" {
  name       = "ring-${var.key_ring_name}-${var.name_suffix}"
  location   = var.kms_location == "" ? data.google_client_config.google_client.region : var.kms_location
  depends_on = [google_project_service.kms_api]
}

resource "google_kms_crypto_key" "symmetric_keys" {
  # see https://cloud.google.com/kms/docs/encrypt-decrypt
  for_each        = { for obj in var.symmetric_keys : obj.key_name => obj }
  name            = "sym-${each.value.key_name}-${var.name_suffix}"
  key_ring        = google_kms_key_ring.key_ring.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = each.value.rotation_period
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION" # see https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}

resource "google_kms_crypto_key" "asymmetric_keys" {
  # see https://cloud.google.com/kms/docs/encrypt-decrypt-rsa
  for_each = { for obj in var.asymmetric_keys : obj.key_name => obj }
  name     = "asym-${each.value.key_name}-${var.name_suffix}"
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = "ASYMMETRIC_DECRYPT"
  version_template {
    algorithm        = each.value.algorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}

resource "google_kms_crypto_key" "signature_keys" {
  # see https://cloud.google.com/kms/docs/create-validate-signatures
  for_each = { for obj in var.signature_keys : obj.key_name => obj }
  name     = "sig-${each.value.key_name}-${var.name_suffix}"
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = "ASYMMETRIC_SIGN"
  version_template {
    algorithm        = each.value.algorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}
