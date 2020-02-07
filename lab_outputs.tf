# Outputs for Terraform
#

output "JumpHost_PublicIP" {
  value = aws_instance.jump.public_ip
}

output "JumpHost_PrivateIP" {
  value = aws_instance.jump.private_ip
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

