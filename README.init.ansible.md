# Ansible Installation

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server) [![hackmd-github-sync-badge](https://hackmd.io/MEZ7JLrfQ12e8LU3UdwsBQ/badge)](https://hackmd.io/MEZ7JLrfQ12e8LU3UdwsBQ)

<center>
<img src="https://upload.wikimedia.org/wikipedia/commons/2/24/Ansible_logo.svg" alt="logo">
</center>

## Installation

Using python virtual environment (`virtualenv`).
```bash
python3 -m virtualenv ansible  # Create a virtualenv
source ansible/bin/activate   # Activate the virtual environment
python3 -m pip3 install ansible
```

## Preparation

### `ansible.cfg`

```cfg
[defaults]
inventory = ./host_vars/hosts.ini # TODO: select host path
stdout_callback = yaml
bin_ansible_callbacks = True
host_key_checking = False
```

### `host_vars/hosts.ini`

- TODO: replace the node host ip and the correct path of ssh key for ssh into node.

```cfg
[node]
NODE01 NUM=01 ansible_host=10.112.0.2 ansible_user=pi ansible_ssh_private_key_file=<replaced>
NODE02 NUM=02 ansible_host=10.112.0.3 ansible_user=pi ansible_ssh_private_key_file=<replaced>
NODE03 NUM=03 ansible_host=10.112.0.4 ansible_user=pi ansible_ssh_private_key_file=<replaced>
NODE04 NUM=04 ansible_host=10.112.0.8 ansible_user=pi ansible_ssh_private_key_file=<replaced>
NODE05 NUM=05 ansible_host=10.112.0.9 ansible_user=pi ansible_ssh_private_key_file=<replaced>

[all:vars]
ansible_python_interpreter=/usr/bin/python3
```

### `host_vars/vars.yml`

```yaml
version: "4.0.3" # ntu-iot-node program version

# you can add your variable as you widh
```

###### tags: `ansible`