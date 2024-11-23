# FROM cassandra:5.0.2

# # Download and install node_exporter
# RUN apt-get update && apt-get install -y wget && \
#     wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz && \
#     tar -xvzf node_exporter-1.1.2.linux-amd64.tar.gz && \
#     mv node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin/ && \
#     rm -rf node_exporter-1.1.2.linux-amd64* && \
#     apt-get remove -y wget && apt-get clean

# # Copy shell script to start node_exporter
# COPY node_exporter_runtime.sh /usr/local/bin/node_exporter_runtime.sh
# RUN chmod +x /usr/local/bin/node_exporter_runtime.sh

# # Expose the node_exporter port
# EXPOSE 9100

FROM quay.io/prometheus/node-exporter:latest

# Switch to root user to set permissions
USER root

# Copy the script and grant execution permissions
COPY node_exporter_runtime.sh /usr/local/bin/node_exporter_runtime.sh
RUN chmod +x /usr/local/bin/node_exporter_runtime.sh

# Switch back to the original user
USER nobody

# Set the script as the entrypoint
ENTRYPOINT ["/usr/local/bin/node_exporter_runtime.sh"]


