variable "ctr_cloud_init_file" { default = "./cloudinit.yaml" }

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "${var.prefix}-vmss"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  sku                             = "Standard_F2"
  instances                       = 2
  admin_username                  = "ubuntu"
  admin_password                  = "ronaldo123!"
  disable_password_authentication = false
  depends_on = [
    azurerm_subnet.internal
  ]

  custom_data = base64encode(file(pathexpand(var.ctr_cloud_init_file)))


  network_interface {
    name    = "${var.prefix}-vmms-network"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("${var.master_ssh_public_key_file}")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}