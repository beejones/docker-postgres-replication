#!/bin/bash
set -e

echo [*] configuring $REPLICATION_ROLE instance

echo "max_connections = $MAX_CONNECTIONS" >> "$PGDATA/postgresql.conf"

# We set primary replication-related parameters for both replica and primary,
# so that the replica might work as a primary after failover.
echo "wal_level = hot_standby" >> "$PGDATA/postgresql.conf"
echo "wal_keep_size  = $WAL_KEEP_SEGMENTS" >> "$PGDATA/postgresql.conf"
echo "max_wal_senders = $MAX_WAL_SENDERS" >> "$PGDATA/postgresql.conf"

# replica settings, ignored on primary
echo "hot_standby = on" >> "$PGDATA/postgresql.conf"
echo "wal_log_hints = on" >> "$PGDATA/postgresql.conf"
echo "log_replication_commands = on" >> "$PGDATA/postgresql.conf"




echo "host replication $REPLICATION_USER 0.0.0.0/0 trust" >> "$PGDATA/pg_hba.conf"

pg_ctl -D "$PGDATA" -m fast -w reload