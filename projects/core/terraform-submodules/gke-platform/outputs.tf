output "google_container_cluster" {
  value = google_container_cluster.this
}

output "dns_NS_record" {
  value = {
    name = google_dns_managed_zone.ingress_internet.dns_name
    type = "NS"
    data = google_dns_managed_zone.ingress_internet.name_servers
  }
}

output "dnssec_DS_record" {
  value = {
    name = google_dns_managed_zone.ingress_internet.dns_name
    type = "DS"
    data = try(data.google_dns_keys.ingress_internet.key_signing_keys[0].ds_record, "")
  }
  sensitive = true
}
