#!/bin/bash

. /opt/bitnami/scripts/liblog.sh

# This is reverting the changes made in 000_alter_owner_temp.sh

if [ -z "${POSTGRESQL_POSTGRES_PASSWORD:-}" ]; then
    POSTGRESQL_POSTGRES_PASSWORD=${POSTGRES_POSTGRES_PASSWORD:-}
fi

if [ -z "${POSTGRES_USER:-}" ]; then
    POSTGRES_USER="postgres"
fi

export PGPASSWORD="$POSTGRESQL_POSTGRES_PASSWORD"

if [ $POSTGRES_USER != "postgres" ]; then
    # IF pgpassword is not set, fail
    if [ -z "${PGPASSWORD:-}" ]; then
        error "If you set POSTGRES_USER to a value other than 'postgres', you need to set POSTGRESQL_POSTGRES_PASSWORD or POSTGRES_POSTGRES_PASSWORD environment variable"
        error "This is because bitnami image does not make the POSTGRES_USER a superuser"
        exit 1
    fi

    # If there is /tmp/alter_owner_temp_revert, revert the changes
    if [ -f /tmp/alter_owner_temp_revert ]; then
        # Change the owner of the initial databases to the POSTGRES_USER
        psql -U postgres -c "ALTER DATABASE postgres OWNER TO $POSTGRES_USER"
        psql -U postgres -c "ALTER DATABASE template1 OWNER TO $POSTGRES_USER"

        # Change the owner of the POSTGRES_DB to the POSTGRES_USER
        psql -U postgres -c "ALTER DATABASE $POSTGRES_DB OWNER TO $POSTGRES_USER"
        rm /tmp/alter_owner_temp_revert
    fi
fi
