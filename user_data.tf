############################
# Templates section
############################
locals {
  systemd_template = var.custom_systemd ? "#!/bin/bash" : templatefile("${path.module}/user_data/systemd.tpl",
    {
      bastion_host_name = local.bastion_host_name
      bastion_ssh_port  = var.bastion_ssh_port
      host_ssh_port     = var.host_ssh_port
      vpc               = var.vpc_id
    }
  )

  ssh_populate_template = var.custom_ssh_populate ? "#!/bin/bash" : templatefile("${path.module}/user_data/ssh_populate.tpl",
    {
      bastion_assume_role_arn = var.bastion_assume_role_arn
      aws_region              = data.aws_region.current.name
    }
  )

  cloud_config_template = templatefile("${path.module}/user_data/cloud_config.tpl",
    {
      host_ssh_username   = var.host_ssh_username
      host_ssh_public_key = var.host_ssh_public_key
    }
  )

  docker_setup_template = var.custom_docker_setup ? "#!/bin/bash" : templatefile("${path.module}/user_data/docker_setup.tpl",
    {
      bastion_container_image = var.bastion_container_image
      bastion_ssh_port        = var.bastion_ssh_port
    }
  )

  iam_authorized_keys_template = var.custom_authorized_keys_command ? "#!/bin/bash" : templatefile("${path.module}/user_data/iam-authorized-keys.tpl",
    {
      iam_authorized_keys_version = "2.2.0"
    }
  )
}

############################
# Templates combined section
############################
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "init.cfg"
    content      = local.cloud_config_template
  }

  # systemd section
  part {
    filename     = "module_systemd"
    content_type = "text/x-shellscript"
    content      = local.systemd_template
  }

  # ssh_populate_assume_role
  part {
    filename     = "module_ssh_populate"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content      = local.ssh_populate_template
  }

  # docker_setup section
  part {
    filename     = "module_docker_setup"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content      = local.docker_setup_template
  }

  # iam-authorized-keys-command
  part {
    filename     = "module_iam-authorized-keys"
    content_type = "text/x-shellscript"
    merge_type   = "str(append)"
    content      = local.iam_authorized_keys_template
  }

  part {
    filename     = "extra_user_data"
    content_type = var.extra_user_data_content_type
    content      = var.extra_user_data_content != "" ? var.extra_user_data_content : "#!/bin/bash"
    merge_type   = var.extra_user_data_merge_type
  }
}
