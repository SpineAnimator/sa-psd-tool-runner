FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq tar gzip \
    libicu70 libssl3 libkrb5-3 libcurl4 liblttng-ust1 libunwind8 zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1001 --shell /bin/bash runner \
    && mkdir -p /runner \
    && chown -R runner:runner /runner

WORKDIR /runner
COPY --chown=runner:runner entrypoint.sh /usr/local/bin/sa-runner-entrypoint
RUN chmod 0755 /usr/local/bin/sa-runner-entrypoint

USER runner
VOLUME ["/runner"]
ENTRYPOINT ["/usr/local/bin/sa-runner-entrypoint"]
