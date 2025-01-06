#!/usr/bin/env bash

# Load PostgeSQL environment variables and Bitnami Logging Libraty
. /opt/bitnami/scripts/postgresql-env.sh
. /opt/bitnami/scripts/liblog.sh

# We have to use the bitnami configuration variable to add timescaledb to
# shared preload list, or else it gets overwritten.
if [ -z "$POSTGRESQL_SHARED_PRELOAD_LIBRARIES" ]
then
    POSTGRESQL_SHARED_PRELOAD_LIBRARIES=timescaledb,pg_cron
else
    POSTGRESQL_SHARED_PRELOAD_LIBRARIES="$POSTGRESQL_SHARED_PRELOAD_LIBRARIES,timescaledb,pg_cron"
fi
export POSTGRESQL_SHARED_PRELOAD_LIBRARIES

# If it's already init, run timescaledb-tune and update pg_cron db (to update the config if needed)
if [ -f "$POSTGRESQL_VOLUME_DIR/.user_scripts_initialized" ]; then
    # Run timescaledb-tune script
    info "Running timescaledb-tune to update the configuration..."
    /docker-entrypoint-initdb.d/001_timescaledb_tune.sh
    info "timescaledb-tune finished"
fi

# If pg_cron config file does not exist, create it
if [ ! -f "$POSTGRESQL_CONF_DIR/conf.d/pg_cron.conf" ]; then
    echo "cron.database_name = '$POSTGRESQL_DATABASE'" > "$POSTGRESQL_CONF_DIR/conf.d/pg_cron.conf"
fi

# Fall through to the original entrypoint. Note that we use exec here because
# this wrapper script shouldn't change PID 1 of the container.
exec "/opt/bitnami/scripts/postgresql/entrypoint.sh" "$@"
