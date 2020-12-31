Terraform module for KMS Key Rings and KMS Keys in GCP

# Upgrade guide v2.0.0 to v2.1.0

This upgrade addresses [The problem of "shifting all items" in an array](https://github.com/airasia/terraform-google-external_access/wiki/The-problem-of-%22shifting-all-items%22-in-an-array).

1. Ensure you have run `terraform plan` & `terraform apply` with `kms_keyring` module `v2.0.0` first.

2. Now change `kms_keyring` module version to `v2.1.0`.

3. Run `terraform plan`
   1. Expect the plan to fail saying "***Error: Instance cannot be destroyed***".
   2. This error is expected.
   3. For this upgrade process to move through, you would need to set `lifecycle { prevent_destroy = false }` before proceeding.
      1. Locate this module's source code in `.terraform/modules` directory and change the values all 3 `lifecycle { prevent_destroy = true }` lines from `true` to `false`.
      2. This step is only to let the `terraform plan` pass so that we can ***see*** the changes proposed by terrform.
      3. By knowing the changes proposed by terraform, we will use `terraform state mv` to move the state positions so that we won't actually need to run `terraform apply` at all.
      4. Thus, the KMS keys & keyrings in GCP will not be destroyed/recreated following this guideline.
    4. After setting the above to `false`, run `terraform plan` again.
      1. This time the plan will pass gracefully showing an equal number of `google_kms_crypto_key` resources will be destroyed and recreated under new named indexes.
      2. We want to avoid any kind of destruction and/or recreation.

4. Move the terraform state positions:
   1. Notice the following that the plan says:
      1. Your **existing** symmetric_keys (let's say `SymmX`) will be destroyed and **new** symmetric_keys (let's say `SymmY`) will be created.
      2. Your **existing** asymmetric_keys (let's say `AsymmX`) will be destroyed and **new** asymmetric_keys (let's say `AsymmY`) will be created.
      3. Your **existing** signature_keys (let's say `SignX`) will be destroyed and **new** signature_keys (let's say `SignY`) will be created.
   2. P.S. if you happen to have multiple keys, then the plan will show these destructions and recreations multiple times - you will need to move the states for EACH of the respective resources one-by-one.
   3. Pay attention to the array indexes:
      1. The `*X` resources (the ones to be destroyed) start with array index `[0]` - although it may not show the `[0]` in the plan.
      2. The `*Y` resources (the ones to be created) will show array indexes with new named indexes.
   4. Use `terraform state mv` to manually move the states of each of `*X` to `*Y`
      1. Refer to https://www.terraform.io/docs/commands/state/mv.html to learn more about how to move Terraform state positions
      2. Once a resource is moved, it will say Successfully moved 1 object(s).
      3. Repeat until all relevant states are moved to their desired positions.

As per the named indexes produced by the `terraform plan` above, a sample script for moving the states could look like this:
```terraform
terraform state mv \
  "module.kms_keyring.google_kms_crypto_key.symmetric_keys[0]" \
  "module.kms_keyring.google_kms_crypto_key.symmetric_keys[\"SymmY\"]"

terraform state mv \
  "module.kms_keyring.google_kms_crypto_key.asymmetric_keys[0]" \
  "module.kms_keyring.google_kms_crypto_key.asymmetric_keys[\"AsymmY\"]"

terraform state mv \
  "module.kms_keyring.google_kms_crypto_key.signature_keys[0]" \
  "module.kms_keyring.google_kms_crypto_key.signature_keys[\"SignY\"]"
```

Upon succesful execution, it will produce an output like this:
```sh
Move "module.kms_keyring.google_kms_crypto_key.symmetric_keys[0]" to "module.kms_keyring.google_kms_crypto_key.symmetric_keys[\"SymmY\"]"
Successfully moved 1 object(s).

Move "module.kms_keyring.google_kms_crypto_key.asymmetric_keys[0]" to "module.kms_keyring.google_kms_crypto_key.asymmetric_keys[\"AsymmY\"]"
Successfully moved 1 object(s).

Move "module.kms_keyring.google_kms_crypto_key.signature_keys[0]" to "module.kms_keyring.google_kms_crypto_key.signature_keys[\"SignY\"]"
Successfully moved 1 object(s).
```

5. Now run `terraform plan` again
   1. The plan should now show that no changes required
   2. This confirms that you have successfully moved all your resources' states to their new position as required by `v2.1.0`.
   3. You should never have to run `terraform apply` for this upgrade exercise.

5. DONE
