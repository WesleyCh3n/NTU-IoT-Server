# Install K3s with Wireguard as flannel interface

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server) [![hackmd-github-sync-badge](https://hackmd.io/pVh3bSYHSImngWi0rugCGA/badge)](https://hackmd.io/pVh3bSYHSImngWi0rugCGA)

![k3s cluster](https://i.imgur.com/jIZuxwQ.png)

[Reference](https://www.inovex.de/blog/how-to-set-up-a-k3s-cluster-on-wireguard/)


In this example, we use the following configuration
- Server
    - Wireguard ip: 10.112.0.1
    - Wireguard external port: 51871
    - Wireguard public key: rcflbneYW/3wVQy8H/jDi/oGlLgyrC4vmJvt4YJOVmw=
    - Wireguard private key: yBo18fnFVjKrRS0dfH0DDehGrVBH1aDaZValIwdEW1I=
    - Public ip: 140.112.111.111
- Client
    - Wireguard ip: 10.112.0.50
    - Wireguard public key: csQQ8c7waCFksyIQyCOIu/eqxaGUxueu8h02qr1f81Q=
    - Wireguard private key: IG10ERcQaBIH0MA/thDn5Yo1XM9tJZXwJNVwpQuCFn4=

## Server

### Setting Wireguard
- Install wireguard
    ```bash
    sudo apt-get update && sudo apt install wireguard
    ```

- Enable ip forwarding.
    ```bash
    sudo sysctl -w net.ipv4.ip_forward=1
    ```

- Generate public & private key for server, there will be privatekey and publickey file created.
    ```bash
    wg genkey | tee privatekey | wg pubkey > publickey
    ```

- add `/etc/wireguard/wg0.conf`
    ```yaml
    # /etc/wireguard/wg0.conf
    [Interface]

    # The IP address of this host in the wireguard tunnels
    Address = 10.112.0.1
    PostUp = /etc/wireguard/add-nat.sh
    PostDown = /etc/wireguard/del-nat.sh

    # Every Raspberry Pi connects via UDP to this port. Your Cloud VM must be reachable on this port via UDP from the internet.
    ListenPort = 51871

    # Set the private key to the value of server
    PrivateKey = yBo18fnFVjKrRS0dfH0DDehGrVBH1aDaZValIwdEW1I=

    # Set the MTU according to the internet connections of your clients
    # In our case the autodetection assumed 8920 since the cloud network supported jumbo frames.
    MTU = 1420

    [Peer]
    # Client's public key and IP
    PublicKey = csQQ8c7waCFksyIQyCOIu/eqxaGUxueu8h02qr1f81Q=
    AllowedIPs = 10.112.0.50/32
    ```

- add `/etc/wireguard/add-nat.sh`
    ```shell
    #!/bin/bash
    IPT="/usr/sbin/iptables"

    IN_FACE="enp5s0"                   # NIC connected to the internet
    WG_FACE="wg0"                    # WG NIC
    SUB_NET="10.112.0.0/24"            # WG IPv4 sub/net aka CIDR
    WG_PORT="51871"                  # WG udp port

    ## IPv4 ##
    $IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE
    $IPT -I INPUT 1 -i $WG_FACE -j ACCEPT
    $IPT -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
    $IPT -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
    $IPT -I INPUT 1 -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT
    ```

- add `/etc/wireguard/del-nat.sh`
    ```shell
    #!/bin/bash
    IPT="/usr/sbin/iptables"

    IN_FACE="enp5s0"                   # NIC connected to the internet
    WG_FACE="wg0"                    # WG NIC
    SUB_NET="10.112.0.0/24"            # WG IPv4 sub/net aka CIDR
    WG_PORT="51871"                  # WG udp port

    ## IPv4 ##
    $IPT -t nat -D POSTROUTING -s $SUB_NET -o $IN_FACE -j MASQUERADE
    $IPT -D INPUT -i $WG_FACE -j ACCEPT
    $IPT -D FORWARD -i $IN_FACE -o $WG_FACE -j ACCEPT
    $IPT -D FORWARD -i $WG_FACE -o $IN_FACE -j ACCEPT
    $IPT -D INPUT -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT
    ```

- bring up wg0 interface, or do the second step if you want to startup on boot
    
    - quick start
    ```bash
    wg-quick up wg0
    ```
    - startup on boot
    ```bash
    sudo systemctl enable wg-quick@wg0.service
    sudo systemctl start wg-quick@wg0.service
    ```

- `sudo wg show` can see the connection

### k3s
- Install k3s
    ```bash
    curl -sfL https://get.k3s.io | sh -s - \
        --write-kubeconfig-mode 644 \
        --disable servicelb \
        --disable traefik \
        --disable metrics-server \
        --disable local-storage \
        --node-external-ip 140.112.111.111 \
        --advertise-address 10.112.0.1 \
        --flannel-iface wg0
    ```

    
- Wait till master is ready. To varify
    ```bash
    kubectl get no -o wide
    ```
    or
    ```bash
    sudo systemctl status k3s.service
    ```

- Get k3s token, this will be used as client `K3S_TOKEN`
    ```bash
    sudo cat /var/lib/rancher/k3s/server/node-token
    ```

## Client (Raspberry Pi)
### Wireguard
- Install wireguard
    ```bash
    sudo apt-get update && sudo apt-get install raspberrypi-kernel-headers wireguard
    ```

- Generate public & private key for server, there will be privatekey and publickey file created.
    ```bash
    wg genkey | tee privatekey | wg pubkey > publickey
    ```

- add `/etc/wireguard/wg0.conf`
    ```yaml
    # /etc/wireguard/wg0.conf
    [Interface]
    # The IP address of the Raspberry Pi in the wireguard network
    Address = 10.112.0.50/32

    # Private key of the Raspberry Pi
    PrivateKey = IG10ERcQaBIH0MA/thDn5Yo1XM9tJZXwJNVwpQuCFn4=

    [Peer]
    # Public Key of the cloud VM
    PublicKey = rcflbneYW/3wVQy8H/jDi/oGlLgyrC4vmJvt4YJOVmw=

    # Public IP of the cloud VM
    Endpoint = 140.112.111.111:51871

    # All traffic for the wireguard network should be routed to our cloud VM
    AllowedIPs = 10.112.0.0/24

    # Since our Raspberry Pis are located behind NAT devices, send keep alives to our cloud VM to keep the connection in the NAT tables.
    PersistentKeepalive = 20
    ```

- bring up wg0 interface, or do the second step if you want to startup on boot
    
    - quick start
    ```bash
    wg-quick up wg0
    ```
    - startup on boot
    ```bash
    sudo systemctl enable wg-quick@wg0.service
    sudo systemctl start wg-quick@wg0.service
    ```
- Verify
    ```bash
    $ nc -v 10.112.0.1 22
    Connection to 10.112.0.1 22 port [tcp/ssh] succeeded!
    SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.2
    ```
### k3s
- Cgroup enable. append following to `/boot/cmdline.txt` then reboot
    ```bash
    cgroup_memory=1 cgroup_enable=memory
    ```
- `cat /proc/cgroups` to see if `memory` exist
    ```
    #subsys_name    hierarchy       num_cgroups     enabled
    cpuset  6       1       1
    cpu     3       1       1
    cpuacct 3       1       1
    blkio   5       1       1
    memory  8       56      1
    devices 2       25      1
    freezer 4       1       1
    net_cls 7       1       1
    pids    9       30      1
    ```

- Install k3s
    ```bash
    curl -sfL https://get.k3s.io | \
    K3S_URL=https://10.112.0.1:6443 \
    K3S_TOKEN="<replaced>" \
    sh -s - --node-label node=02 \
        --node-ip 10.112.0.3 \
        --flannel-iface wg0
    ```

- Wait till master is ready. To varify
    ```bash
    # On server
    kubectl get no -o wide
    ```
    or
    ```bash
    # On client
    sudo systemctl status k3s-agent.service
    ```


## Problem
In order to let kube-system local-path-provisioner working. Add 
```bash
iptables -A INPUT -s 10.42.0.0/16 -d <host_internal_ip>/32 -j ACCEPT
```
to the iptable and restart k3s.service

On Master Node
Find the node
kubectl get nodes

Drain it
kubectl drain nodetoberemoved

Delete it
kubectl delete node nodetoberemoved

###### tags: `k3s`, `Wireguard`, `Tutorial`