# Build the manager binary
FROM debian
COPY scripts /scripts
RUN chmod +x /scripts/*
ENTRYPOINT ["/scripts/run.sh"]