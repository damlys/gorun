module "test_monitor" {
  source = "../../terraform-submodules/k8s-monitor"

  kibana_domain = "kibana.gogke-test-7.damlys.pl"
}
