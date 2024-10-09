# TimescaleDB tools
FROM docker.io/library/golang:alpine AS timescaledb-tools

RUN apk update && apk add --no-cache git gcc musl-dev \
    && go install github.com/timescale/timescaledb-tune/cmd/timescaledb-tune@latest \
    && go install github.com/timescale/timescaledb-parallel-copy/cmd/timescaledb-parallel-copy@latest

# TimescaleDB extension
FROM docker.io/timescale/timescaledb:2.17.0-pg17-bitnami AS timescaledb

# Select and copy the last 3 versions of the extension 
RUN cd /opt/bitnami/postgresql/lib \
    && cp timescaledb.so /tmp \
    && cp -r $(ls . | grep timescaledb- | sort | tail -n 3) /tmp \
    && cp -r $(ls . | grep timescaledb-tsl- | sort | tail -n 3) /tmp \
    && cd /opt/bitnami/postgresql/share/extension \
    && cp -r $(ls . | grep timescaledb | grep .sql) /tmp

# PostgreSQL Server
FROM docker.io/bitnami/postgresql:17.0.0 AS postgresql

# TimescaleDB tools
COPY --from=timescaledb-tools /go/bin/* /usr/local/bin/

# TimescaleDB extension (We will install last 3 versions)
COPY --from=timescaledb /tmp/*.so /opt/bitnami/postgresql/lib/
COPY --from=timescaledb /tmp/*.sql /opt/bitnami/postgresql/share/extension/

# TimescaleDB Docker initialization scripts
COPY --from=timescaledb /docker-entrypoint-initdb.d/*.sh /docker-entrypoint-initdb.d/

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/postgresql/run.sh" ]
