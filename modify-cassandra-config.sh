#!/bin/bash
sed -i 's/# enable_materialized_views: false/enable_materialized_views: true/' /etc/cassandra/cassandra.yaml

if [ -f /usr/local/bin/docker-entrypoint.sh ]; then
    exec /usr/local/bin/docker-entrypoint.sh "$@"
else
    echo "Entrypoint script not found!"
    exit 1
fi
