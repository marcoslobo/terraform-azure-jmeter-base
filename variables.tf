variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "node_instance_type" {
  description = "Instance type for slave nodes"
  default = "Standard_B2s"
}

variable "master_instance_type" {
  description = "Instance type for master node"
  default = "Standard_B2s"
}

variable "slave_ssh_public_key_file" {
  description = "SSH public key filename for slave nodes"
  default = "ssh/slave.pub"
}

variable "master_ssh_public_key_file" {
  description = "SSH public key filename for master node"
  default = "ssh/master.pub"
}

variable "master_ssh_private_key_file" {
  description = "SSH private key filename for master node"
  default = "ssh/master"
}

variable "node_quantity" {
  description = "Amount of working nodes in Azure Scale"
  default = "1"
}

variable "jmx_script_file" {
  description = "JMX Script to run on master"
}

variable "jmeter3_url" {
  description = "URL with jmeter archive"
  default = "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-3.3.tgz" 
}

variable "azure_auth" {
  description = "Azure auth file"
}