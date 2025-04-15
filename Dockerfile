# Stage 1: Build bitcoin core
FROM debian:bookworm-slim AS builder

ARG BITCOIN_VERSION=v29.0

RUN apt-get update && apt-get install -y \
    automake \
    cmake \
    autotools-dev \
    build-essential \
    git \
    libtool \
    pkg-config \
    python3-minimal \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-chrono-dev \
    libboost-program-options-dev \
    libboost-test-dev \
    libboost-thread-dev \
    libssl-dev \
    libevent-dev \
    libdb++-dev \
    bsdmainutils \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /bitcoin
RUN git clone https://github.com/bitcoin/bitcoin.git . \
    && git checkout -b ${BITCOIN_VERSION} ${BITCOIN_VERSION} \
    && cmake -B build \
    && cmake --build build -j$(nproc)  

# Stage 2: Final image
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libboost-system1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-chrono1.74.0 \
    libboost-program-options1.74.0 \
    libboost-thread1.74.0 \
    libssl3 \
    libevent-2.1-7 \
    libevent-extra-2.1-7 \
    libevent-pthreads-2.1-7 \
    iproute2 \
    iptables \
    libsqlite3-0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /bitcoin/build/bin/bitcoind /usr/local/bin/
COPY --from=builder /bitcoin/build/bin/bitcoin-cli /usr/local/bin/

RUN mkdir -p /bitcoin

# Create bitcoin user and group
RUN groupadd -r bitcoin && \
    useradd -r -g bitcoin -s /sbin/nologin -c "Bitcoin node user" bitcoin && \
    chown -R bitcoin:bitcoin /bitcoin

VOLUME ["/bitcoin"]
WORKDIR /bitcoin

# Expose RPC ports
EXPOSE 8332 8333

USER bitcoin

ENTRYPOINT ["bitcoind", "-datadir=/bitcoin/.bitcoin", "-conf=/bitcoin/bitcoin.conf", "-rpcbind=0.0.0.0", "-daemon=0"]
