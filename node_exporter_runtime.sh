#!/bin/bash
/usr/local/bin/node_exporter --collector.disable-defaults --collector.textfile --collector.textfile.directory /tmp --web.listen-address=":9100"

