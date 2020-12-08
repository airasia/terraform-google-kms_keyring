# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "name_suffix" {
  description = "An arbitrary suffix that will be added to the end of the resource name(s). For example: an environment name, a business-case name, a numeric id, etc."
  type        = string
  validation {
    condition     = length(var.name_suffix) <= 14
    error_message = "A max of 14 character(s) are allowed."
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------

variable "key_ring_name" {
  description = "A name for the KMS Key Ring."
  type        = string
  default     = "set-1"
}

variable "kms_location" {
  description = "The location for the KMS Key Ring. A full list of valid locations can be found by running 'gcloud kms locations list' from the terminal. Defaults to the google provider's region if nothing is specified here."
  type        = string
  default     = ""
}

variable "symmetric_keys" {
  description = "A list of objects defining properties of symmetric encryption-decryption keys. Specify \"rotation_period\" in number of seconds including the trailing 's'. For example \"7776000s\" = \"90 days\"."
  type = list(object({
    key_name        = string
    rotation_period = string
  }))
  default = []
}

variable "asymmetric_keys" {
  description = "A list of objects defining properties of asymmetric encryption-decryption keys. Recommended \"algorithm\" = \"RSA_DECRYPT_OAEP_3072_SHA256\" - see https://cloud.google.com/kms/docs/algorithms#algorithm_recommendations."
  type = list(object({
    key_name  = string
    algorithm = string
  }))
  default = []
}

variable "signature_keys" {
  description = "A list of objects defining properties of asymmetric signature keys. Recommended \"algorithm\" = \"EC_SIGN_P256_SHA256\" - see https://cloud.google.com/kms/docs/algorithms#algorithm_recommendations."
  type = list(object({
    key_name  = string
    algorithm = string
  }))
  default = []
}
