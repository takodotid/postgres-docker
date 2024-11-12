# TimescaleDB
FROM docker.io/timescale/timescaledb:2.17.2-pg17-bitnami AS timescaledb

# Select and copy the last 3 versions of the extension
RUN mkdir -p /tmp/lib /tmp/share /tmp/bin \
    && cd /opt/bitnami/postgresql/lib \
    && cp timescaledb.so /tmp/lib \
    && cp -r $(ls . | grep timescaledb- | grep -v tsl | sort | tail -n 3) /tmp/lib \
    && cp -r $(ls . | grep timescaledb-tsl- | sort | tail -n 3) /tmp/lib \
    && cd /opt/bitnami/postgresql/share/extension \
    && cp -r $(ls . | grep timescaledb | grep .sql) /tmp/share \
    && cp timescaledb.control /tmp/share \
    && cd /usr/local/bin \
    && cp -r $(ls . | grep timescaledb-) /tmp/bin

RUN echo -e "[INFO] TimescaleDB lib files to be installed: \n$(ls /tmp/lib)"

# PostgreSQL Server
FROM docker.io/bitnami/postgresql:17.0.0 AS postgresql

# TimescaleDB tools
COPY --from=timescaledb /tmp/bin/* /usr/local/bin/

# TimescaleDB extension (We will install last 3 versions)
COPY --from=timescaledb /tmp/lib/* /opt/bitnami/postgresql/lib/
COPY --from=timescaledb /tmp/share/* /opt/bitnami/postgresql/share/extension/

# TimescaleDB Docker initialization scripts
COPY --from=timescaledb /docker-entrypoint-initdb.d/*.sh /docker-entrypoint-initdb.d/
COPY ./initdb/* /docker-entrypoint-initdb.d/

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]
