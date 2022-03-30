provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# create public IPs
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-tfip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-master"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

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


  connection {
    host        = azurerm_public_ip.pip.ip_address
    user        = "ubuntu"
    type        = "ssh"
    private_key = file("${var.master_ssh_private_key_file}")
  }


  provisioner "remote-exec" {
    inline = [
      "sudo ufw disable",
      "sudo apt-get update",
      "sudo mkdir /jmeter-master",
      "sudo chown -R ubuntu /jmeter-master",
      "sudo apt install apt-transport-https ca-certificates curl software-properties-common -y",
      "sudo mkdir /opt/jdk",
      "sudo chown -R ubuntu /opt/jdk",
      "cd /opt/jdk",
      "curl https://jmeter-multicloud.s3.amazonaws.com/jdk-8u202-linux-x64.tar.gz> java8.tgz",
      "sudo tar -zxf java8.tgz",
      "sudo update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_202/bin/java 100",
      "sudo curl -L https://github.com/docker/compose/releases/download/v2.3.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo mkdir /usr/local/bin/docker-compose",
      "sudo chown -R ubuntu /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt install docker-ce -y",
      "cd /jmeter-master/",
      "curl ${var.jmeter3_url} > jMeter.tgz",
      "tar zxvf jMeter.tgz"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files"
    destination = "/jmeter-master"
  }
  
  provisioner "file" {
    source      = var.jmx_script_file
    destination = "/jmeter-master/files/script.jmx"
  }
    provisioner "file" {
    source      = var.azure_auth
    destination = "/jmeter-master/files/my.azureauth"
  }

  provisioner "remote-exec" {
    inline = [     
      "sudo snap install dotnet-sdk --classic --channel=6.0",
      "cd /jmeter-master/files",      
      "sudo mkdir executer",
      "sudo chown -R ubuntu executer",
      "cd executer",
      "sudo git clone https://github.com/marcoslobo/Multicloud.Jmeter.VmmsCaller.git",
      "cd Multicloud.Jmeter.VmmsCaller/",
      "sudo dotnet build .",
      "sudo dotnet publish -o ../publish",
      "cd /jmeter-master/files",
      "sudo mv my.azureauth  /jmeter-master/files/executer/publish/"      
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker-compose -f ~/../../jmeter-master/files/docker-compose.yml up -d"
    ]
  }
}
