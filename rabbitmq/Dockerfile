FROM rabbitmq:3-management

# Copy the entrypoint script
COPY rabbitmq/entrypoint.sh /usr/local/bin/custom-entrypoint.sh
# Normalize line endings (CRLF -> LF), strip UTF-8 BOM, and make it executable
RUN sed -i '1s/^\xEF\xBB\xBF//' /usr/local/bin/custom-entrypoint.sh \
    && sed -i 's/\r$//' /usr/local/bin/custom-entrypoint.sh \
    && chmod +x /usr/local/bin/custom-entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["rabbitmq-server"]
