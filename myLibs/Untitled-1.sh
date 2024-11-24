docker run -d --net="host" --pid="host" -v "/:/host:ro,rslave" quay.io/prometheus/node-exporter:latest --path.rootfs=/host


docker run -d --name cassandra_node_exporter -v ./node_exporter_runtime.sh:/usr/local/bin/node_exporter_runtime.sh -p 9100:9100 cassandra-node-exporter
