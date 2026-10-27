locals {
  name = "${var.name_prefix}-${var.environment}"
  tags = merge({ environment = var.environment, managed_by = "terraform", project = "kubernetes-platform" }, var.tags)
}
resource "azurerm_resource_group" "platform" {
  name = "${local.name}-rg"
  location = var.location
  tags = local.tags
}
resource "azurerm_virtual_network" "platform" {
  name = "${local.name}-vnet"
  location = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  address_space = ["10.20.0.0/16"]
  tags = local.tags
}
resource "azurerm_subnet" "aks" {
  name = "${local.name}-aks-subnet"
  resource_group_name = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.platform.name
  address_prefixes = ["10.20.0.0/20"]
}
resource "azurerm_container_registry" "platform" {
  name = replace("${var.name_prefix}${var.environment}${substr(sha1(var.subscription_id), 0, 6)}", "-", "")
  resource_group_name = azurerm_resource_group.platform.name
  location = azurerm_resource_group.platform.location
  sku = "Basic"
  admin_enabled = false
  tags = local.tags
}
resource "azurerm_kubernetes_cluster" "platform" {
  name = "${local.name}-aks"
  location = azurerm_resource_group.platform.location
  resource_group_name = azurerm_resource_group.platform.name
  dns_prefix = "${local.name}-aks"
  sku_tier = "Free"
  local_account_disabled = true
  default_node_pool {
    name = "system"
    vm_size = var.aks_node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
    auto_scaling_enabled = true
    min_count = var.aks_min_node_count
    max_count = var.aks_max_node_count
    os_disk_size_gb = 64
    type = "VirtualMachineScaleSets"
  }
  identity { type = "SystemAssigned" }
  azure_active_directory_role_based_access_control { azure_rbac_enabled = true }
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
    service_cidr = "10.21.0.0/16"
    dns_service_ip = "10.21.0.10"
  }
  tags = local.tags
}
resource "azurerm_role_assignment" "aks_pull_acr" {
  scope = azurerm_container_registry.platform.id
  role_definition_name = "AcrPull"
  principal_id = azurerm_kubernetes_cluster.platform.kubelet_identity[0].object_id
  principal_type = "ServicePrincipal"
}
