############################
# Templates section
############################
data "template_file" "systemd" {
  template = file("${path.module}/user_data/systemd.tpl")
  count    = var.custom_systemd ? 0 : 1

  vars = {
    bastion_host_name = local.bastion_host_name
    bastion_ssh_port = var.bastion_ssh_port
    host_ssh_port = var.host_ssh_port
    vpc               = var.vpc_id
  }
}

data "template_file" "ssh_populate" {
  count    = var.custom_ssh_populate ? 0 : 1
  template = file("${path.module}/user_data/ssh_populate.tpl")

  vars = {
    bastion_assume_role_arn = var.bastion_assume_role_arn
    aws_region = data.aws_region.current.name
  }
}

data "template_file" "cloud_config" {
  template = file("${path.module}/user_data/cloud_config.tpl")
  vars = {
    host_ssh_username = var.host_ssh_username
    host_ssh_public_key = var.host_ssh_public_key
  }
}

data "template_file" "docker_setup" {
  count    = var.custom_docker_setup ? 0 : 1
  template = file("${path.module}/user_data/docker_setup.tpl")

  vars = {
    bastion_container_image = var.bastion_container_image
    bastion_ssh_port = var.bastion_ssh_port
  }
}

data "template_file" "iam-authorized-keys" {
  count    = var.custom_authorized_keys_command ? 0 : 1
  template = file("${path.module}/user_data/iam-authorized-keys.tpl")
  vars = {
    iam_authorized_keys_version = "2.2.0"
  }
}

############################
# Templates combined section
############################
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename = "init.cfg"
    content = data.template_file.cloud_config.rendered
  }

  # systemd section
  part {
    filename     = "module_systemd"
    content_type = "text/x-shellscript"
    content = element(
      concat(data.template_file.systemd.*.rendered, ["#!/bin/bash"]),
      0,
    )
  }

  # ssh_populate_assume_role
  part {
    filename     = "module_ssh_populate"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content = element(
      concat(
        data.template_file.ssh_populate.*.rendered,
        ["#!/bin/bash"],
      ),
      0,
    )
  }

  # docker_setup section
  part {
    filename     = "module_docker_setup"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content = element(
      concat(data.template_file.docker_setup.*.rendered, ["#!/bin/bash"]),
      0,
    )
  }

  # iam-authorized-keys-command
  part {
    filename     = "module_iam-authorized-keys"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content = element(
      concat(
        data.template_file.iam-authorized-keys.*.rendered,
        ["#!/bin/bash"],
      ),
      0,
    )
  }

  part {
    filename     = "extra_user_data"
    content_type = var.extra_user_data_content_type
    content      = var.extra_user_data_content != "" ? var.extra_user_data_content : "#!/bin/bash"
    merge_type   = var.extra_user_data_merge_type
  }
}

