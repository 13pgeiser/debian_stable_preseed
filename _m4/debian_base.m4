# Debian base.
FROM debian:bookworm-slim

# Upgrade
RUN set -ex \
    && apt-get update \
    && apt-get -y dist-upgrade \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

