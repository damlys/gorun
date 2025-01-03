output "elasticsearch_username" {
  value = module.test_elk_stack.elasticsearch_username
}

output "elasticsearch_password" {
  value     = module.test_elk_stack.elasticsearch_password
  sensitive = true
}
