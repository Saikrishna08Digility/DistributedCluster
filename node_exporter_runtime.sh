#!/bin/bash

# Start node_exporter with specified collectors and options
/usr/local/bin/node_exporter \
    --collector.disable-defaults \
    --collector.textfile \
    --collector.textfile.directory /tmp/node_exporter \
    --web.listen-address=":9109"
