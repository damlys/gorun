provider "google" {
}

data "google_billing_account" "this" {
  billing_account = "01873E-ED36A0-27C009"
  open            = true
}
