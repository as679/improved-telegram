# Terraform definition for the lab servers
#

data "template_file" "server_userdata" {
  count    = var.server_count * var.pod_count
  template = file("${path.module}/userdata/server.userdata")

  vars = {
    hostname = "server${floor(count.index / var.pod_count % var.server_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    jumpbox_ip  = aws_instance.jumpbox.private_ip
    pubkey       = tls_private_key.generated.public_key_openssh
    number   = count.index + 1
  }
}

resource "aws_instance" "server" {
  count                  = var.server_count * var.pod_count
  ami                    = var.ami_ubuntu[var.aws_region]
  availability_zone      = var.aws_az[var.aws_region]
  instance_type          = var.flavour_server
  key_name               = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg[count.index % var.pod_count].id]
  subnet_id              = aws_subnet.appnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.k8s_iam_profile.name
  source_dest_check      = false
  user_data              = data.template_file.server_userdata[count.index].rendered
  depends_on             = [aws_instance.master]

  tags = {
    Name      = "server${floor(count.index / var.pod_count % var.server_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    Owner     = var.owner
    Lab_Group = "servers"
    Lab_Name  = "server${floor(count.index / var.pod_count % var.server_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    "kubernetes.io/cluster/pod${count.index % var.pod_count + 1}" = "shared"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_ubuntu
    delete_on_termination = "true"
  }
}
