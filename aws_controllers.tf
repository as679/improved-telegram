# Terraform definition for the controllers

data "template_file" "controller_userdata" {
  count    = var.pod_count
  template = file("${path.module}/userdata/controller.userdata")

  vars = {
    hostname = "${var.id}-pod${count.index + 1}-controller"
    jumpbox_ip  = aws_instance.jumpbox.private_ip
    number   = count.index + 1
  }
}

resource "aws_eip" "ctrl_eip" {
  count = var.pod_count
  vpc   = true

  tags = {
    Name               = "${var.id}_pod${count.index + 1}_controller"
    Owner              = var.owner
  }
}

resource "aws_eip_association" "ctrl_eip_assoc" {
  count         = var.pod_count
  instance_id   = aws_instance.ctrl[count.index].id
  allocation_id = aws_eip.ctrl_eip[count.index].id

}


resource "aws_instance" "ctrl" {
  count                       = var.pod_count
  ami                         = var.ami_avi_controller[var.aws_region]
  availability_zone           = var.aws_az[var.aws_region]
  instance_type               = var.flavour_avi
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.ctrl_sg.id]
  subnet_id                   = aws_subnet.infranet.id
  iam_instance_profile        = aws_iam_instance_profile.controller_iam_profile.name
  source_dest_check           = false
  user_data                   = data.template_file.controller_userdata[count.index].rendered
  depends_on                  = [aws_instance.server]

  tags = {
    Name               = "${var.id}_pod${count.index + 1}_controller"
    Owner              = var.owner
    Lab_Group          = "controllers"
    Lab_Name           = "controller.pod${count.index + 1}.lab"
    ansible_connection = "local"
    Lab_Timezone       = var.lab_timezone
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_avi
    delete_on_termination = "true"
  }
}
