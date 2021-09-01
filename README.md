# NTU-IoT-Server

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server) 
![k3s - 1.20.7](https://img.shields.io/badge/k3s-1.20.7-informational?logo=Kubernetes)
![MQTT - 1.6.13](https://img.shields.io/badge/Paho.MQTT-1.2.0-informational?logo=Eclipse+Mosquitto)
![Telegraf - 1.19](https://img.shields.io/badge/Telegraf-1.19-informational)
![InfluxDB - 1.8.4](https://img.shields.io/badge/InfluxDB-1.8.4-informational?logo=InfluxDB)
![Grafana - 8.0.5](https://img.shields.io/badge/Grafana-8.0.5-informational?logo=Grafana)
![Made with - Docker](https://img.shields.io/badge/Made_with-Docker-informational?logo=Docker)
![Ansible - 3.4.0](https://img.shields.io/badge/Ansible-3.4.0-informational?logo=Ansible)
[![hackmd-github-sync-badge](https://hackmd.io/tC5D1J9HRv6GG4JH7J5cEQ/badge)](https://hackmd.io/tC5D1J9HRv6GG4JH7J5cEQ)

## Overview
![](https://i.imgur.com/x8TBhiz.png)

## Introduction

This is NTU BME MS thesis project backend setting. Include several services:
- Control:
    - k3s: Control running services in nodes.
    - Ansible: Update/Upgrade running program or configuration.
    - WireGuard: VPN service for communication between server and nodes.
- Database:
    - MQTT + Telegraf + InfluxDB + Grafana: Dairy cow feeding data.
    - Rsync: Backup image.
    

## Documentation

|     Service     | Installation                                                                            | Usage                                                                              |
|:---------------:| --------------------------------------------------------------------------------------- |:---------------------------------------------------------------------------------- |
| K3s & WireGuard | [README](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/README.init.k3s_wg.md)  | [README](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/k3s/README.md)     |
|     Ansible     | [README](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/README.init.ansible.md) | [README](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/ansible/README.md) |
|    Database     | [README](https://github.com/WesleyCh3n/NTU-IoT-Server/blob/main/README.init.server.md)  | -                                                                                  |
