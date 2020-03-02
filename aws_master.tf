# Terraform definition for the lab masters
#

data "template_file" "master_userdata" {
  count    = var.master_count * var.pod_count
  template = file("${path.module}/userdata/master.userdata")

  vars = {
    hostname = "master${floor(count.index / var.pod_count % var.master_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    jumpbox_ip  = aws_instance.jumpbox.private_ip
    pubkey       = tls_private_key.generated.public_key_openssh
    number   = count.index + 1
  }
}

resource "aws_instance" "master" {
  count                       = var.master_count * var.pod_count
  ami                         = var.ami_ubuntu[var.aws_region]
  availability_zone           = var.aws_az[var.aws_region]
  instance_type               = var.flavour_master
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.k8s_sg[count.index].id]
  subnet_id                   = aws_subnet.appnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.k8s_iam_profile.name
  source_dest_check = false
  user_data         = data.template_file.master_userdata[count.index].rendered
  depends_on        = [aws_instance.jumpbox]

  tags = {
    Name         = "master${floor(count.index / var.pod_count % var.master_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    Owner        = var.owner
    Lab_Group    = "k8s_masters"
    Lab_Name     = "master${floor(count.index / var.pod_count % var.master_count + 1)}.pod${count.index % var.pod_count + 1}.lab"
    Lab_Timezone = var.lab_timezone
    "kubernetes.io/cluster/pod${count.index % var.pod_count + 1}" = "shared"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_ubuntu
    delete_on_termination = "true"
  }
}
