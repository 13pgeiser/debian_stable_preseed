# Debian base.
FROM debian:10-slim

RUN echo 'Acquire::http::Pipeline-Depth "0";\n\
Acquire::http::No-Cache=True;\n\
Acquire::BrokenProxy=true;\n'\
>> /etc/apt/apt.conf.d/99fixbadproxy; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /var/lib/apt/lists/partial/*; \
    apt-get clean;

# Upgrade
RUN set -ex \
    && apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

