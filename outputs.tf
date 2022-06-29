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

output "key_ring" {
  description = "A reference (ID) to the KMS Key Ring."
  value       = google_kms_key_ring.key_ring.id
}

output "symmetric_keys" {
  description = "Map of references (IDs) to KMS Symmetric Encryption-Decryption Keys."
  value = {
    for symmetric_key in google_kms_crypto_key.symmetric_keys :
    symmetric_key.name => symmetric_key.id
  }
}

output "asymmetric_keys" {
  description = "Map of references (IDs) to KMS Asymmetric Encryption-Decryption Keys."
  value = {
    for asymmetric_key in google_kms_crypto_key.asymmetric_keys :
    asymmetric_key.name => asymmetric_key.id
  }
}

output "signature_keys" {
  description = "Map of references (IDs) to KMS Asymmetric Signature Keys."
  value = {
    for signature_key in google_kms_crypto_key.signature_keys :
    signature_key.name => signature_key.id
  }
}
