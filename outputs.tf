output "usage_IAM_roles" {
  description = "Basic IAM role(s) that are generally necessary for using the resources in this module. See https://cloud.google.com/iam/docs/understanding-roles."
  value = [
    "roles/cloudkms.cryptoKeyEncrypter",
    "roles/cloudkms.cryptoKeyDecrypter",
    # "roles/cloudkms.cryptokeyencrypterdecrypter", <-- do not use this as it is often unsupported by most resource types
    "roles/cloudkms.publicKeyViewer",
    "roles/cloudkms.signer",
    "roles/cloudkms.signerVerifier",
  ]
}

output "key_ring_link" {
  description = "A reference (self_link) to the KMS Key Ring."
  value       = google_kms_key_ring.key_ring.self_link
}

output "symmetric_key_self_links" {
  description = "Map of references (self_links) to KMS Symmetric Encryption-Decryption Keys."
  value = {
    for symmetric_key in google_kms_crypto_key.symmetric_keys :
    symmetric_key.name => symmetric_key.self_link
  }
}

output "asymmetric_key_self_links" {
  description = "Map of references (self_links) to KMS Asymmetric Encryption-Decryption Keys."
  value = {
    for asymmetric_key in google_kms_crypto_key.asymmetric_keys :
    asymmetric_key.name => asymmetric_key.self_link
  }
}

output "signature_key_self_links" {
  description = "Map of references (self_links) to KMS Asymmetric Signature Keys."
  value = {
    for signature_key in google_kms_crypto_key.signature_keys :
    signature_key.name => signature_key.self_link
  }
}
