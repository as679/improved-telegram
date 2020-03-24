# This file contains various variables that affect the deployment itself
#

# The following variables should be defined via a seperate mechanism to avoid distribution
# For example the file terraform.tfvars

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_region" {
}

variable "avi_default_password" {
}

variable "avi_admin_password" {
}

variable "avi_backup_admin_username" {
}

variable "avi_backup_admin_password" {
}

variable "pod_count" {
  description = "The pod size. Each pod gets a controller"
  default     = 2
}

variable "lab_timezone" {
  description = "Lab Timezone: PST, EST, GMT or SGT"
  default = "EST"
}

variable "server_count" {
  description = "K8S Workers count per pod"
  default     = 4
}

variable "master_count" {
  description = "K8S Masters count per pod"
  default     = 1
}

variable "id" {
  description = "A prefix for the naming of the objects / instances"
  default     = "aviK8S"
}

variable "owner" {
  description = "Sets the AWS Owner tag appropriately"
  default     = "aviK8S_Training"
}

variable "aws_az" {
  type        = map(string)
  description = "Control of placement of objects within the AWS Availability Zone"

  default = {
    us-west-2 = "us-west-2a"
    eu-west-1 = "eu-west-1a"
  }
}

