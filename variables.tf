variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "slave_instance_type" {
  description = "Instance type for slave nodes"
  default = "t2.micro"
}

variable "master_instance_type" {
  description = "Instance type for master node"
  default = "t2.medium"
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

variable "slave_asg_size" {
  description = "Amount of working nodes in ASG"
  default = "2"
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