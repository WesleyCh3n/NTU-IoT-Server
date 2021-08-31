# NTU-IoT-Server: Ansible

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server) 
[![hackmd-github-sync-badge](https://hackmd.io/RDrU7t73QzKSXZpAEokcOw/badge)](https://hackmd.io/RDrU7t73QzKSXZpAEokcOw)

## Usage

```bash
ansible-playbook <task.yml>
```

## Tasks

- `deploy_code.local.yml`: Upgrade `ntu-iot-node` package. Edit `host_vars/vars.yml`'s `version` to select which version to upgrade.
- `deploy_wifi_systemd.yml`: Create systemmd to let RPi keep connecting to router.
- `gather_image.yml`: Retrieve a captured image from node.
- `gather_stdout.yml`: Run shell command in and print out the result from node.