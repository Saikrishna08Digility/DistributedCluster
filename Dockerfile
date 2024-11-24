# FROM cassandra:5.0.2

# # Download and install node_exporter
# RUN apt-get update && apt-get install -y wget && \
#     wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz && \
#     tar -xvzf node_exporter-1.1.2.linux-amd64.tar.gz && \
#     ln -s /node_exporter-1.1.2.linux-amd64 /node_exporter-current && \
#     mv /node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin/ && \
#     rm -rf node_exporter-1.1.2.linux-amd64* && \
#     mkdir -p /tmp/node_exporter && \
#     apt-get remove -y wget && apt-get clean

# # Copy shell script for starting node_exporter
# COPY ./node_exporter_runtime.sh /usr/local/bin/node_exporter_runtime.sh
# RUN chmod +x /usr/local/bin/node_exporter_runtime.sh

# # Expose the node_exporter port
# EXPOSE 9100

# # Set the entry point to the runtime script
# ENTRYPOINT ["/usr/local/bin/node_exporter_runtime.sh"]

FROM cassandra:5.0.2

# Install necessary tools (wget for downloading, cron for scheduling tasks)
RUN apt-get update && apt-get install -y wget cron && \
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz && \
    tar -xvzf node_exporter-1.8.2.linux-amd64.tar.gz && \
    ln -s /node_exporter-1.8.2.linux-amd64 /node_exporter-current && \
    mv /node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/ && \
    rm -rf node_exporter-1.8.2.linux-amd64* && \
    mkdir -p /tmp/node_exporter && \
    apt-get remove -y wget && apt-get clean

# Copy runtime scripts and metrics publishing script
COPY ./node_exporter_runtime.sh /usr/local/bin/node_exporter_runtime.sh
COPY ./send_cass_metrics_to_prom_2024.sh /usr/local/bin/send_cass_metrics_to_prom_2024.sh

# Copy metrics file to the /tmp directory in the container
COPY ./oramad_cass_prom_metrics_0.txt /tmp/oramad_cass_prom_metrics_0.txt

# Make scripts executable
RUN chmod +x /usr/local/bin/node_exporter_runtime.sh /usr/local/bin/send_cass_metrics_to_prom_2024.sh

# Set up crontab for periodic execution of the metrics publishing script
RUN echo "*/2 * * * * sh /usr/local/bin/send_cass_metrics_to_prom_2024.sh" > /etc/cron.d/send_cass_metrics_to_prom && \
    chmod 0644 /etc/cron.d/send_cass_metrics_to_prom && \
    crontab /etc/cron.d/send_cass_metrics_to_prom


# Node Exporter port
EXPOSE 9109 
# Start cron service and Node Exporter
CMD ["/bin/bash", "-c", "cron && /usr/local/bin/node_exporter_runtime.sh"]

