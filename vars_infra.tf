# This file contains various variables that affect the configuration of the deployed infrastructure
#

variable "vpc_cidr" {
  description = "Primary CIDR block for VPC"
  default     = "172.20.0.0/16"
}

variable "flavour_master" {
  description = "AWS instance type for servers etc"
  default     = "t3.xlarge"
}

variable "flavour_server" {
  description = "AWS instance type for servers etc"
  default     = "t3.large"
}

variable "flavour_centos" {
  description = "AWS instance type for servers etc"
  default     = "t3.medium"
}

variable "flavour_avi" {
  description = "AWS instance type for Avi controllers"
  default     = "t3.2xlarge"
}

variable "vol_size_centos" {
  description = "Volume size for instances in G"
  default     = "60"
}

variable "vol_size_avi" {
  description = "Volume size for Avi controllers in G"
  default     = "128"
}

