#!/bin/bash

. /opt/bitnami/scripts/liblog.sh

# This is made so TimescaleDB initdb CREATE DATABASE will work.

if [ -z "${POSTGRESQL_POSTGRES_PASSWORD:-}" ]; then
    POSTGRESQL_POSTGRES_PASSWORD=${POSTGRES_POSTGRES_PASSWORD:-}
fi

export PGPASSWORD="$POSTGRESQL_POSTGRES_PASSWORD"

if [ $POSTGRES_USER != "postgres" ]; then
    # IF pgpassword is not set, fail
    if [ -z "${PGPASSWORD:-}" ]; then
        error "If you set POSTGRES_USER to a value other than 'postgres', you need to set POSTGRESQL_POSTGRES_PASSWORD or POSTGRES_POSTGRES_PASSWORD environment variable"
        error "This is because bitnami image does not make the POSTGRES_USER a superuser"
        exit 1
    fi

    # Find "timescaledb.telemetry_level" in the postgresql.conf file, if not found, then alter the owner of the databases
    if ! grep -q "timescaledb.telemetry_level" ${POSTGRESQL_CONF_DIR}/postgresql.conf; then
        # Change the owner of the initial databases to the POSTGRES_USER
        psql -U postgres postgres -f "ALTER DATABASE postgres OWNER TO $POSTGRES_USER"
        psql -U postgres template1 -f "ALTER DATABASE template1 OWNER TO $POSTGRES_USER"

        # Change the owner of the POSTGRES_DB to the POSTGRES_USER
        psql -U postgres $POSTGRES_DB -f "ALTER DATABASE $POSTGRES_DB OWNER TO $POSTGRES_USER"
    fi

    # Mark to revert the changes
    touch /tmp/alter_owner_temp_revert
fi
