provider "google" {
  credentials = file("./creds/hashitalk-vault-demo-267318-3e009934f5b5.json")
  project     = "hashitalk-vault-demo-267318"
  region      = "northamerica-northeast1"
}