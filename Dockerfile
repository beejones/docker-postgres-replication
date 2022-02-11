# -*- mode: conf -*-
FROM postgres:12.3

# common settings
ENV MAX_CONNECTIONS 500
ENV WAL_KEEP_SEGMENTS 256
ENV MAX_WAL_SENDERS 100

# primary/replica settings
ENV REPLICATION_ROLE primary
ENV REPLICATION_USER replication
ENV REPLICATION_PASSWORD "replication"

# replica settings
#ENV POSTGRES_PRIMARY_SERVICE_HOST localhost
#ENV POSTGRES_PRIMARY_SERVICE_PORT 5432

# postgres settings
ENV POSTGRES_USER postgres
ENV POSTGRES_PASSWORD postgres

COPY 10-config.sh /docker-entrypoint-initdb.d/
COPY 20-replication.sh /docker-entrypoint-initdb.d/
# Evaluate vars inside PGDATA at runtime.
# For example HOSTNAME in 'ENV PGDATA=/mnt/$HOSTNAME'
# is resolved runtime rather then during build
RUN sed -i 's/set -e/set -e -x\nPGDATA=$(eval echo "$PGDATA")/' /docker-entrypoint.sh
