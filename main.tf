resource "azurerm_resource_group" "module" {
  name     = "${local.module_name}-rg"
  location = "${var.location}"

  tags {
    environment = "dev"
    version     = "v0.0.1"
  }
}

resource "azurerm_network_interface" "module" {
  name                = "${local.module_name}-nic${count.index}"
  location            = "${azurerm_resource_group.module.location}"
  resource_group_name = "${azurerm_resource_group.module.name}"
  count               = "${var.count}"

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }

  tags {
    environment = "dev"
  }
}

resource "azurerm_virtual_machine" "module" {
  name                             = "${local.module_name}-vm${count.index}"
  location                         = "${azurerm_resource_group.module.location}"
  resource_group_name              = "${azurerm_resource_group.module.name}"
  network_interface_ids            = ["${element(azurerm_network_interface.module.*.id, count.index)}"]
  count                            = "${var.count}"
  vm_size                          = "${var.size}"
  delete_os_disk_on_termination    = "${var.delete_os_disk_on_termination}"
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${element(split(":",var.os), 0)}"
    offer     = "${element(split(":",var.os), 1)}"
    sku       = "${element(split(":",var.os), 2)}"
    version   = "${element(split(":",var.os), 3)}"
  }

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    name              = "${local.module_name}-vm${count.index}-os"
    managed_disk_type = "${var.disk_os_sku}"
  }

  os_profile {
    computer_name  = "${local.module_name}vm${count.index}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    environment = "dev"
  }
}
