output "dns_NS_record" {
  value = {
    name = google_dns_managed_zone.ingress_internet.dns_name
    type = "NS"
    data = google_dns_managed_zone.ingress_internet.name_servers
  }
}
