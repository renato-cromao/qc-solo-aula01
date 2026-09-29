output "public_ip_address" {
  description = "Endereço IPv4 público da VM."
  value       = azurerm_public_ip.vm.ip_address
}
