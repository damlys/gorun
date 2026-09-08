provider "google" {
}

data "google_billing_account" "this" {
  billing_account = "011D45-32FBBB-49E61D"
  open            = true
}
