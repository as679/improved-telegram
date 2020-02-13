# This file contains the AMI Ids of the images used for the various instances

variable "ami_avi_controller" {
  type        = map(string)
  description = "Avi Controller AMI by region updated 11/02/20"

  default = {
    eu-west-1 = "ami-0c9d42aa12626b637" #18.2.6
    us-west-2 = "ami-0416a7968f5001af5" #18.2.7
  }
}

variable "ami_ubuntu" {
  type        = map(string)
  description = "Ubuntu Bionic Beaver AMI by region updated 10/10/18"

  default = {
    eu-west-1 = "ami-07042e91d04b1c30d" 
    us-west-2 = "ami-0edf3b95e26a682df"
  }
}
