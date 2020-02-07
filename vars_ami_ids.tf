# This file contains the AMI Ids of the images used for the various instances
#

# aws ec2 describe-images --owners 139284885014 --filters Name=name,Values='Avi-Controller-17.2.8*' --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'
variable "ami_avi_controller" {
  type        = map(string)
  description = "Avi AMI by region updated 07/01/19"

  default = {
    eu-west-1 = "ami-0c9d42aa12626b637" #18.2.6
    us-east-1 = "ami-072d592b6535776f2" #18.2.7
    us-west-2 = "ami-0416a7968f5001af5" #18.2.7
  }
}

# aws ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce --region eu-west-2 | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId'

# NOTE
# Prebuilt packer image is used in labs
variable "ami_centos" {
  type        = map(string)
  description = "CentOS AMI by region updated 10/10/18"

  default = {
    #eu-west-1 = "ami-0defbd4ca292ce6e5"
    eu-west-1 = "ami-0f630a3f40b1eb0b8"
    us-west-2 = "ami-01161bd085729d109"
  }
}
