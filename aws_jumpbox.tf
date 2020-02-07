# Terraform definition for the lab jumpbox
#

data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jumpbox.userdata")

  vars = {
    hostname     = "${var.id}_jump"
    server_count = var.student_count
    vpc_id       = aws_vpc.OCP_vpc.id
    region       = var.aws_region
    az           = var.aws_az[var.aws_region]
    mgmt_net     = aws_subnet.mgmtnet.tags.Name
    pkey         = var.pkey
    pubkey       = tls_private_key.generated.public_key_openssh
  }
}

resource "aws_instance" "jump" {
  ami               = var.ami_centos[var.aws_region]
  availability_zone = var.aws_az[var.aws_region]
  instance_type     = var.flavour_centos
  key_name          = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.jumpsg.id]
  subnet_id                   = aws_subnet.pubnet.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.lab_profile.name
  source_dest_check           = false
  user_data                   = data.template_file.jumpbox_userdata.rendered
  depends_on                  = [aws_internet_gateway.igw]

  tags = {
    Name                          = "${var.id}_jumpbox"
    Owner                         = var.owner
    Lab_Group                     = "jumpbox"
    Lab_Name                      = "jumpbox.student.lab"
    Lab_vpc_id                    = aws_vpc.OCP_vpc.id
    Lab_avi_default_password      = var.avi_default_password
    Lab_avi_admin_password        = var.avi_admin_password
    Lab_avi_backup_admin_username = var.avi_backup_admin_username
    Lab_avi_backup_admin_password = var.avi_backup_admin_password
    Lab_avi_management_network    = "${var.id}_management_network"
    Lab_avi_vip_network           = "${var.id}_infra_network"
    Lab_Timezone                  = var.lab_timezone
    Lab_Noshut                    = "jumpbox"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = var.vol_size_centos
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


  #provisioner "file" {
  #  source      = "provisioning/handle_bootstrap.py"
  #  destination = "/usr/local/bin/handle_bootstrap.py"
  #}

  #provisioner "file" {
  #  source      = "provisioning/handle_bootstrap.service"
  #  destination = "/etc/systemd/system/handle_bootstrap.service"
  #}

  #provisioner "file" {
  #  source      = "provisioning/create_backup_user.yml"
  #  destination = "/root/create_backup_user.yml"
  #}

  #provisioner "file" {
  #  source      = "provisioning/ansible_inventory.py"
  #  destination = "/etc/ansible/hosts"
  #}

  #provisioner "file" {
  #  source      = "provisioning/cleanup_controllers.py"
  #  destination = "/usr/local/bin/cleanup_controllers.py"
  #}

  provisioner "local-exec"{
    command = "ansible-playbook -i '${aws_instance.jump.public_ip},' --private-key ${local.private_key_filename} --user ubuntu provision_jumpbox.yml"
  }
}

