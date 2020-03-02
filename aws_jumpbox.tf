# Terraform definition for the lab jumpbox
#

data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jumpbox.userdata")

  vars = {
    hostname     = "jumpbox.pod.lab"
    server_count = var.pod_count
    vpc_id       = aws_vpc.K8S_vpc.id
    region       = var.aws_region
    az           = var.aws_az[var.aws_region]
    mgmt_net     = aws_subnet.mgmtnet.tags.Name
    pkey         = tls_private_key.generated.private_key_pem
    pubkey       = tls_private_key.generated.public_key_openssh
  }
}

resource "aws_instance" "jumpbox" {
  ami               = var.ami_ubuntu[var.aws_region]
  availability_zone = var.aws_az[var.aws_region]
  instance_type     = var.flavour_ubuntu
  key_name          = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.jumpbox_sg.id]
  subnet_id                   = aws_subnet.infranet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.jumpbox_iam_profile.name
  source_dest_check           = false
  user_data                   = data.template_file.jumpbox_userdata.rendered
  depends_on                  = [aws_internet_gateway.igw]

  tags = {
    Name                          = "jumpbox.pod.lab"
    Owner                         = var.owner
    Lab_Group                     = "jumpbox"
    Lab_Name                      = "jumpbox.pod.lab"
    Lab_vpc_id                    = aws_vpc.K8S_vpc.id
    Lab_avi_default_password      = var.avi_default_password
    Lab_avi_admin_password        = var.avi_admin_password
    Lab_avi_backup_admin_username = var.avi_backup_admin_username
    Lab_avi_backup_admin_password = var.avi_backup_admin_password
    Lab_avi_mgmt_net              = "${var.id}_mgmt_net"
    Lab_avi_app_net               = "${var.id}_app_net"
    Lab_Timezone                  = var.lab_timezone
    Lab_Noshut                    = "jumpbox"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_ubuntu
    delete_on_termination = "true"
  }

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloud-init.done ]; do sleep 1; done"
    ]
  }

  provisioner "local-exec"{
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${aws_instance.jumpbox.public_ip},' --private-key ${local.private_key_filename} -e'private_key_filename=${local.private_key_filename}' --user ubuntu provisioning/provision_jumpbox.yml"
  }
}
