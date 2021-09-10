users:
  - name: ${ssh_host_username}
    home: /home/${ssh_host_username}
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh-authorized-keys:
      - ${ssh_host_public_key}
