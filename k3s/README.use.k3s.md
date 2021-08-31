# NTU-IoT-Server: k3s

## Pods

2 Pods will be created in each node.
- [Stream pod](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/k3s/stream.t.yml.tmp): `stream.t.yml`
- [Backup image pods](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/k3s/backup.t.yml.tmp): `backup.t.yml`

### `stream.t.yml`

This pod run [ntu-iot-node](https://github.com/WesleyCh3n/NTU-IoT-Node) and pass the arguments it used.

Mount Path:
- ntu-iot-node: `/home/pi/ntu-iot-node/:/home/`
- Raspicam:
    - `/opt/vc:/opt/vc`
    - `/dev/vchiq:/dev/vchiq`
    - `/dev/vcsm:/dev/vcsm`
- Timezone: `/usr/share/zoneinfo/Asia/Taipei:/etc/localtime`

Docker Image: [wesleych3n/ntu-iot:cc-slim](https://hub.docker.com/layers/wesleych3n/ntu-iot/cc-slim/images/sha256-35eae8d8639e65f627726fb02caf60c53d8455c4e2aba83377bd5dfd27102f32?context=explore)

### `backup.t.yml`
This pod run [upload.sh](https://github.com/WesleyCh3n/NTU-IoT-Node/blob/main/upload.sh) and pass the arguments it used.

Mount Path:
- upload.sh: `/home/pi/ntu-iot-node/:/home/`
- Telegram config: `/home/pi/ntu-iot-node/cfg/telegram-send.conf:/etc/telegram-send.conf`
- Timezone: `/usr/share/zoneinfo/Asia/Taipei:/etc/localtime`
- rsync ssh key: `/home/pi/.ssh/id_rsa:/root/.ssh/id_rsa`

Docker Image: [wesleych3n/ntu-iot:send](https://hub.docker.com/layers/wesleych3n/ntu-iot/send/images/sha256-57cf36bfb660886bb333d4a8a353fa6efb1ced667001f9d483d4bc780c38f33b?context=explore)

---

## Yaml parser: `j` 

Because we want to specify different numbers in `yaml` argument, `j` is the program to parse `{{  }}` with [Jinja2](https://jinja.palletsprojects.com/en/3.0.x/) style.

In `yaml`, `{{ '%02d' % Number }}` will be replaced with the node number we pass into `j`. And print out each node parsing result.

### Usage

```bash
j <yml file> <node num> | kubectl <operation>
```
---

## `kubectl` Useful Command

```bash
# Node Status
k get no
# Specific Node Status
k describe node <node-name>

# All Pod Status
k get pod
# Specific Pod Status
k describe pod <pod-name>

# Logs
## Log all
k logs <pod-name>
## Log last 5 line
k logs --tail=5 <pod-name>

# Pods Manipulation
## Create Pods with # Node
j stream.t.yml 1 2 3 4 5 | k apply -f -
j backup.t.yml 1 2 3 4 5 | k apply -f -
## Create Pods with # Node
j stream.t.yml 1 2 3 4 5 | k delete -f -
j backup.t.yml 1 2 3 4 5 | k delete -f -
## Delete all pods
k delete pods --all

# Remove a Node from cluster
k drain <node-name>
k delete node <node-name>
```
