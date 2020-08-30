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
  count           = length(var.symmetric_keys)
  name            = "sym-${var.symmetric_keys[count.index].key_name}-${var.name_suffix}"
  key_ring        = google_kms_key_ring.key_ring.self_link
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = var.symmetric_keys[count.index].rotation_period
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION" # see https://cloud.google.com/kms/docs/reference/rest/v1/CryptoKeyVersionAlgorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}

resource "google_kms_crypto_key" "asymmetric_keys" {
  # see https://cloud.google.com/kms/docs/encrypt-decrypt-rsa
  count    = length(var.asymmetric_keys)
  name     = "asym-${var.asymmetric_keys[count.index].key_name}-${var.name_suffix}"
  key_ring = google_kms_key_ring.key_ring.self_link
  purpose  = "ASYMMETRIC_DECRYPT"
  version_template {
    algorithm        = var.asymmetric_keys[count.index].algorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}

resource "google_kms_crypto_key" "signature_keys" {
  # see https://cloud.google.com/kms/docs/create-validate-signatures
  count    = length(var.signature_keys)
  name     = "sig-${var.signature_keys[count.index].key_name}-${var.name_suffix}"
  key_ring = google_kms_key_ring.key_ring.self_link
  purpose  = "ASYMMETRIC_SIGN"
  version_template {
    algorithm        = var.signature_keys[count.index].algorithm
    protection_level = "SOFTWARE"
  }
  lifecycle { prevent_destroy = true }
}
