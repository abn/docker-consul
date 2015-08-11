# Consul Container

This project puts [Consul](https://github.com/hashicorp/consul) in scratch docker container. It is available on [Docker Hub](https://registry.hub.docker.com/u/alectolytic/consul/) and can be pulled using the following command.

```sh
docker pull alectolytic/consul
```

You will note that this is a tiny image.
```
$ docker images | grep docker.io/alectolytic/logstash-forwarder
docker.io/alectolytic/consul    latest    46303750e525    3 minutes ago    14.34 MB
```

## Quickstart

#### Default

By default, a single consul agent is run in server mode.

```sh
docker run --rm -it alectolytic/consul
```

This is equivalent to executing the following.

```sh
consul agent -server -bootstrap-expect 1 -data-dir /data
```

The output looks similar to this.

```
==> WARNING: BootstrapExpect Mode is specified as 1; this is the same as Bootstrap mode.
==> WARNING: Bootstrap mode enabled! Do not enable unless necessary
==> WARNING: It is highly recommended to set GOMAXPROCS higher than 1
==> Starting raft data migration...
==> Starting Consul agent...
==> Starting Consul agent RPC...
==> Consul agent running!
        Node name: '52b7a6700f2c'
       Datacenter: 'dc1'
           Server: true (bootstrap: true)
      Client Addr: 127.0.0.1 (HTTP: 8500, HTTPS: -1, DNS: 8600, RPC: 8400)
     Cluster Addr: 172.17.0.63 (LAN: 8301, WAN: 8302)
   Gossip encrypt: false, RPC-TLS: false, TLS-Incoming: false
            Atlas: <disabled>

==> Log data will now stream in as it occurs:

   2015/08/11 22:11:06 [INFO] serf: EventMemberJoin: 52b7a6700f2c 172.17.0.63
   2015/08/11 22:11:06 [INFO] serf: EventMemberJoin: 52b7a6700f2c.dc1 172.17.0.63
   2015/08/11 22:11:06 [INFO] raft: Node at 172.17.0.63:8300 [Follower] entering Follower state
   2015/08/11 22:11:06 [INFO] consul: adding server 52b7a6700f2c (Addr: 172.17.0.63:8300) (DC: dc1)
   2015/08/11 22:11:06 [INFO] consul: adding server 52b7a6700f2c.dc1 (Addr: 172.17.0.63:8300) (DC: dc1)
   2015/08/11 22:11:06 [ERR] agent: failed to sync remote state: No cluster leader
   2015/08/11 22:11:08 [WARN] raft: Heartbeat timeout reached, starting election
   2015/08/11 22:11:08 [INFO] raft: Node at 172.17.0.63:8300 [Candidate] entering Candidate state
   2015/08/11 22:11:08 [INFO] raft: Election won. Tally: 1
   2015/08/11 22:11:08 [INFO] raft: Node at 172.17.0.63:8300 [Leader] entering Leader state
   2015/08/11 22:11:08 [INFO] consul: cluster leadership acquired
   2015/08/11 22:11:08 [INFO] consul: New leader elected: 52b7a6700f2c
   2015/08/11 22:11:08 [INFO] raft: Disabling EnableSingleNode (bootstrap)
   2015/08/11 22:11:08 [INFO] consul: member '52b7a6700f2c' joined, marking health alive
   2015/08/11 22:11:10 [INFO] agent: Synced service 'consul'

```

#### Persisted data volume

```sh
# create data container
docker create  --entrypoint=_ -v /data --name consul-data scratch

# run consul
docker run --rm -it --volumes-from alectolytic/consul
```

#### Custom commands

```sh
docker run --rm -it alectolytic/consul agent -server -bootstrap-expect 1 -data-dir /data
```

#### Configuration file

```sh
docker run --rm -it -v /path/to/config.json:/config.json alectolytic/consul agent -config-file=/config.json
```

**NOTE:** If running on an SELinux enabled system, run `chcon -Rt svirt_sandbox_file_t /path/to/config.json` before staring consul.


## Exposed ports

```
EXPOSE \
    53/tcp 53/udp \
    8300/tcp \
    8301/tcp 8301/udp \
    8302/tcp 8302/udp \
    8400/tcp \
    8500/tcp \
    8600/tcp 8600/udp
```
