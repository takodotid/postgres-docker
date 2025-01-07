# TimescaleDB
FROM docker.io/timescale/timescaledb:2.17.2-pg16-bitnami AS timescaledb

# Select and copy the last 3 versions of timescaledb extension
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
RUN echo -e "[INFO] TimescaleDB share files to be installed: \n$(ls /tmp/share)"

# PostgreSQL Server (base image)
FROM docker.io/bitnami/postgresql:16.6.0 AS postgresql

# pg_cron
FROM postgresql AS pg_cron

# Switch to root
USER root

# Select and copy the pg_cron extension files
RUN install_packages --no-install-recommends git gcc make llvm clang \
    && git clone https://github.com/citusdata/pg_cron.git \
    && cd pg_cron \
    && make install

RUN echo -e "[INFO] pg_cron lib files to be installed: \n$(ls /opt/bitnami/postgresql/lib | grep pg_cron)"
RUN echo -e "[INFO] pg_cron share files to be installed: \n$(ls /opt/bitnami/postgresql/share/extension | grep pg_cron)"

# PostgreSQL Server (final image)
FROM postgresql AS final

# TimescaleDB tools
COPY --from=timescaledb /tmp/bin/* /usr/local/bin/

# TimescaleDB extension (We will install last 3 versions)
COPY --from=timescaledb /tmp/lib/* /opt/bitnami/postgresql/lib/
COPY --from=timescaledb /tmp/share/* /opt/bitnami/postgresql/share/extension/

# pg_cron extension
COPY --from=pg_cron /opt/bitnami/postgresql/lib/pg_cron* /opt/bitnami/postgresql/lib/
COPY --from=pg_cron /opt/bitnami/postgresql/share/extension/pg_cron* /opt/bitnami/postgresql/share/extension/

# TimescaleDB Docker initialization scripts
COPY --from=timescaledb /docker-entrypoint-initdb.d/*.sh /docker-entrypoint-initdb.d/
COPY ./initdb/* /docker-entrypoint-initdb.d/

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]
