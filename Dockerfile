FROM ghcr.io/tabarra/txadmin:latest

# Set working directory
WORKDIR /home/container

# Copy citizen resources
COPY ../citizen /home/container/resources

# Create necessary directories
RUN mkdir -p /home/container/cache /home/container/logs

# Set permissions
RUN chown -R container:container /home/container

# Switch to container user
USER container

# Expose ports
EXPOSE 30120/tcp 30120/udp 40120/tcp

CMD ["/home/container/entrypoint.sh"]