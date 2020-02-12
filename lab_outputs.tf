# Outputs for Terraform
#

output "Jumpbox_PublicIP" {
  value = aws_instance.jumpbox.public_ip
}

output "Jumpbox_PrivateIP" {
  value = aws_instance.jumpbox.private_ip
}

#output "Controller_PublicIP" {
#  value = aws_instance.ctrl.*.public_ip
#}

#output "Controller_PrivateIP" {
#  value = aws_instance.ctrl.*.private_ip
#}

#output "Server_PrivateIP" {
#  value = aws_instance.server.*.private_ip
#}

