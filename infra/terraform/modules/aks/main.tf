resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-hybrid-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "hybrid-${var.environment}"
  tags                = var.tags

  default_node_pool {
    name                = "system"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.aks_subnet_id
    enable_auto_scaling = true
    min_count           = var.min_nodes
    max_count           = var.max_nodes

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }


  azure_policy_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  count                 = var.enable_spot_pool ? 1 : 0
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.node_vm_size
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1
  enable_auto_scaling   = true
  min_count             = 0
  max_count             = 3
  vnet_subnet_id        = var.aks_subnet_id

  node_taints = ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  tags        = var.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}




