provider "vault" {
    address         = "http://127.0.0.1:8200"
}

# Enable KV store for Dev-A
resource "vault_mount" "kv-devA" {
  path        = "dev-A"
  type        = "kv"
  description = "KV store for team Dev-A"
}

# Enable KV store for Dev-B
resource "vault_mount" "kv-devB" {
  path        = "dev-B"
  type        = "kv"
  description = "KV store for team Dev-B"
}

# Vault policy for admin
resource "vault_policy" "admin_policy" {
  name      = "admin-policy"
  policy    = file("admin-policy.hcl")
}

# Vault policy for provisioner (Terraform)
resource "vault_policy" "provisioner_policy" {
  name      = "provisioner-policy"
  policy    = file("provisioner-policy.hcl")
}

# Vault policy for team Dev-A
resource "vault_policy" "devA_policy" {
  name      = "devA-policy"
  policy = <<EOT
path "dev-A/*" {
capabilities = ["create", "update"]
}
EOT
}

# Vault policy for team Dev-B
resource "vault_policy" "devB_policy" {
  name      = "devB-policy"
  policy = <<EOT
path "dev-B/*" {
capabilities = ["create", "update"]
}
EOT
}
