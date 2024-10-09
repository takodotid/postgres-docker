#!/bin/bash

. /opt/bitnami/scripts/liblog.sh

# This is reverting the changes made in 000_alter_owner_temp.sh

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

    # Find "timescaledb.telemetry_level" in the postgresql.conf file
    if grep -q "timescaledb.telemetry_level" /bitnami/postgresql/conf/postgresql.conf; then
        # Change the owner of the initial databases to the POSTGRES_USER
        psql -U postgres postgres -f "ALTER DATABASE postgres OWNER TO postgres;"
        psql -U postgres template1 -f "ALTER DATABASE template1 OWNER TO postgres;"

        # Change the owner of the POSTGRES_DB to the POSTGRES_USER
        psql -U postgres $POSTGRES_DB -f "ALTER DATABASE $POSTGRES_DB OWNER TO postgres;"
    fi
fi
