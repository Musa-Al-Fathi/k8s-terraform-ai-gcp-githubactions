output "resource_group_name" { value = azurerm_resource_group.platform.name }
output "aks_name" { value = azurerm_kubernetes_cluster.platform.name }
output "acr_name" { value = azurerm_container_registry.platform.name }
output "acr_login_server" { value = azurerm_container_registry.platform.login_server }
output "get_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.platform.name} --name ${azurerm_kubernetes_cluster.platform.name}"
}
