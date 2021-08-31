# MQTT Telegraf InfluxDB Grafana + Rsync with Docker Installation 

![docker](https://www.docker.com/sites/default/files/d8/2019-07/horizontal-logo-monochromatic-white.png)

[![WesleyCh3n - NTU-IoT-Server](https://img.shields.io/badge/WesleyCh3n-NTU--IoT--Server-2ea44f?logo=github)](https://github.com/WesleyCh3n/NTU-IoT-Server)
[![hackmd-github-sync-badge](https://hackmd.io/0-caMk-xQHWDdDMfPQqfvw/badge)](https://hackmd.io/0-caMk-xQHWDdDMfPQqfvw)

[Reference](https://gabrieltanner.org/blog/grafana-sensor-visualization)

## Manually

### MQTT Mosquitto
```bash
docker run -d --ip 172.17.0.3 \
--restart unless-stopped \
-p 1883:1883 \
-p 9001:9001 \
--name mosquitto \
-v F:\grafana\mosquitto\mosquitto.conf:/mosquitto/config/mosquitto.conf \
-v F:\grafana\mosquitto\passwd:/mosquitto/passwd \
eclipse-mosquitto:1.6.13
```

### Influxdb
```bash
docker run -d --ip 172.17.0.4 \
--restart unless-stopped \
-p 8086:8086 \
-v F:\grafana\data\:/var/lib/influxdb \
--name influxdb \
influxdb:1.8.4
```

After create container. Let's create user for `telegraf`. First go into influx shell.
```bash
docker exec -it influxdb influx
```
Then
```sql
CREATE DATABASE sensors
CREATE USER telegraf WITH PASSWORD 'telegraf'
GRANT ALL ON sensors TO telegraf
```

### Telegraf
```bash
docker run -d --ip 172.17.0.5 \
--restart unless-stopped \
-v F:/grafana/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
--name telegraf \
telegraf
```

### Gragana
```bash
docker run -d --ip 172.17.0.6 --restart unless-stopped \
           -p 3000:3000 \
           --name grafana \
           -v f:/grafana/grafana:/var/lib/grafana \
           -e "GF_SMTP_ENABLED=true" \
           -e "GF_SMTP_HOST=smtp.gamil.com" \
           -e "GF_SMTP_USER=<replaced>" \
           -e "GF_SMTP_PASSWORD=<replaced>" \
           -e "GF_SECURITY_ALLOW_EMBEDDING=true" \
           -e "GF_SECURITY_COOKIE_SECURE=true" \
           -e "GF_SECURITY_COOKIE_SAMESITE=none" \
           -e "GF_AUTH_ANONYMOUS_ENABLED=true" \
           grafana/grafana
```
In Grafana, use the below setting.
- http://172.17.0.4:8086/
- sensors
- telegraf
- telegraf

---
## OR, Use docker-compose

```yaml
version: "3"
services:
  mqtt:
    container_name: mqtt
    image: eclipse-mosquitto:1.6.13
    networks:
      IoT:
        ipv4_address: 172.18.0.3
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - F:\grafana\mosquitto\mosquitto.conf:/mosquitto/config/mosquitto.conf
      - F:\grafana\mosquitto\passwd:/mosquitto/passwd
    restart: unless-stopped
  influxdb:
    container_name: influxdb
    image: influxdb:1.8.4
    networks:
      IoT:
        ipv4_address: 172.18.0.4
    ports:
      - "8086:8086"
    volumes:
      - F:\grafana\data\:/var/lib/influxdb
    restart: unless-stopped
  telegraf:
    container_name: telegraf
    image: telegraf
    networks:
      IoT:
        ipv4_address: 172.18.0.5
    volumes:
      - F:/grafana/telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro
    restart: unless-stopped
  grafana:
    container_name: grafana
    image: grafana/grafana
    networks:
      IoT:
        ipv4_address: 172.18.0.6
    ports:
      - "3000:3000"
    volumes:
      - f:/grafana/grafana:/var/lib/grafana
    environment:
      - GF_SMTP_ENABLED=true
      - GF_SMTP_HOST=smtp.gamil.com
      - GF_SMTP_USER=<replaced>
      - GF_SMTP_PASSWORD=<replaced>
      - GF_SECURITY_ALLOW_EMBEDDING=true
    restart: unless-stopped
networks:
  IoT:
    driver: bridge
    ipam:
     config:
      - subnet: 172.18.0.0/16
        gateway: 172.18.0.1
```
Then,
```bash
docker-compose up -d
```

Finished ;)

## (Optional) Chronograf

```
docker run -d --network="iot-server_IoT" \
--name=chronograf \
-p 8888:8888 \
chronograf \
--influxdb-url=http://172.18.0.4:8086
```

---

## Need to mention...
我們時區是GMT+8所以select time range 要-8小時

- **Export bounding box**
    ```sql
    -- 若要選早上11:00~12:00
    SELECT "box0", "box1", "box3", "box2" \
    FROM "sensors"."autogen"."NTU_FEED" \
    WHERE time > '2021-04-21T03:00:00Z' AND time < '2021-04-21T04:00:00Z' \
    AND "node"='02'
    ```

- **Sum all node**
    ```sql
    SELECT SUM("indv_node") FROM (SELECT round(mean("total")) AS "indv_node" \
    FROM "sensors"."autogen"."NTU_FEED" \
    WHERE time > now() - 720m AND time < now() \
    AND ("node"='01' OR "node"='02' OR "node"='03' OR "node"='04' OR "node"='05') \
    GROUP BY time($__interval), "node" FILL(null)) \
    WHERE time > now() - 720m AND time < now() \
    GROUP BY time($__interval) FILL(null)
    ```

    ```sql
    SELECT round(mean("total")) AS "node01" \
    FROM "sensors"."autogen"."NTU_FEED" \
    WHERE time > now() - 720m AND time < now() \
    AND "node"='01' \
    GROUP BY time($__interval) FILL(null)
    ```

## Rsync Server

```bash
docker run --name=rsync_server \
-d --restart unless-stopped \
-p 2222:22 \
-v /dir/you/want/to/mount:/data \
-e SSH_AUTH_KEY_1="<rsync_rsa.pub>" \
eeacms/rsync server
```

Remember to replace `<rsync_rsa.pub>` to the content in `secret/rsync_rsa.pub`

For more information, check the [docker hub](https://hub.docker.com/r/eeacms/rsync).

###### tags: `Thesis`
