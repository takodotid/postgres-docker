#!/usr/bin/env bash

# Load PostgeSQL environment variables and Bitnami Logging Libraty
. /opt/bitnami/scripts/postgresql-env.sh
. /opt/bitnami/scripts/liblog.sh

# We have to use the bitnami configuration variable to add timescaledb to
# shared preload list, or else it gets overwritten.
if [ -z "$POSTGRESQL_SHARED_PRELOAD_LIBRARIES" ]
then
    POSTGRESQL_SHARED_PRELOAD_LIBRARIES=timescaledb
else
    POSTGRESQL_SHARED_PRELOAD_LIBRARIES="$POSTGRESQL_SHARED_PRELOAD_LIBRARIES,timescaledb"
fi
export POSTGRESQL_SHARED_PRELOAD_LIBRARIES

# If it's already init, run timescaledb-tune again (to update the config if needed)
if [ -f "$POSTGRESQL_VOLUME_DIR/.user_scripts_initialized" ]; then
    # Run timescaledb-tune script
    info "Running timescaledb-tune to update the configuration..."
    /docker-entrypoint-initdb.d/001_timescaledb_tune.sh
    info "timescaledb-tune finished"
fi

# Fall through to the original entrypoint. Note that we use exec here because
# this wrapper script shouldn't change PID 1 of the container.
exec "/opt/bitnami/scripts/postgresql/entrypoint.sh" "$@"
