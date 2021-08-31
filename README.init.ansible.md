# Ansible

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server) [![hackmd-github-sync-badge](https://hackmd.io/MEZ7JLrfQ12e8LU3UdwsBQ/badge)](https://hackmd.io/MEZ7JLrfQ12e8LU3UdwsBQ)


## Installation

Using python virtual environment.
```bash=
$ python3 -m virtualenv ansible  # Create a virtualenv
$ source ansible/bin/activate   # Activate the virtual environment
$ python3 -m pip3 install ansible
```

## `ansible.cfg`

```cfg
[defaults]
inventory = ./host_vars/hosts.ini # TODO: select host path
stdout_callback = yaml
bin_ansible_callbacks = True
host_key_checking = False
```

## Host configuration

###### tags: `ansible`