############################
# Templates section
############################
data "template_file" "systemd" {
  template = file("${path.module}/user_data/systemd.tpl")
  count    = local.custom_systemd_no

  vars = {
    bastion_host_name = local.bastion_host_name
    vpc               = var.vpc
  }
}

data "template_file" "ssh_populate_assume_role" {
  count    = local.assume_role_yes * local.custom_ssh_populate_no
  template = file("${path.module}/user_data/ssh_populate_assume_role.tpl")

  vars = {
    assume_role_arn = var.assume_role_arn
    aws_region = var.aws_region
  }
}

data "template_file" "cloud_config" {
  template = file("${path.module}/user_data/cloud_config.tpl")
  vars = {
    ssh_host_username = var.ssh_host_username
    ssh_host_public_key = var.ssh_host_public_key
  }
}

data "template_file" "ssh_populate_same_account" {
  count    = local.assume_role_no * local.custom_ssh_populate_no
  template = file("${path.module}/user_data/ssh_populate_same_account.tpl")
}

data "template_file" "docker_setup" {
  count    = local.custom_docker_setup_no
  template = file("${path.module}/user_data/docker_setup.tpl")

  vars = {
    container_ubuntu_version = var.container_ubuntu_version
  }
}

data "template_file" "iam-authorized-keys" {
  count    = local.custom_authorized_keys_command_no
  template = file("${path.module}/user_data/iam-authorized-keys.tpl")
}

############################
# Templates combined section
############################
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename = "init.cfg"
    content = data.template_file.cloud_config.*.rendered
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
    filename     = "module_ssh_populate_assume_role"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content = element(
      concat(
        data.template_file.ssh_populate_assume_role.*.rendered,
        ["#!/bin/bash"],
      ),
      0,
    )
  }

  # ssh_populate_same_account
  part {
    filename     = "module_ssh_populate_same_account"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content = element(
      concat(
        data.template_file.ssh_populate_same_account.*.rendered,
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

