# Outputs for Terraform
#

output "Jumpbox_PublicIP" {
  value = aws_instance.jumpbox.public_ip
}

output "Controller_PublicIP" {
  value = aws_eip.ctrl_eip.*.public_ip
}
