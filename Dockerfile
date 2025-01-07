# Stage 1: Build bitcoin core
FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y \
    automake \
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
    && rm -rf /var/lib/apt/lists/*

WORKDIR /bitcoin
RUN git clone https://github.com/bitcoin/bitcoin.git . \
    && git checkout v25.1 \
    && ./autogen.sh \
    && ./configure --disable-wallet --without-gui --without-miniupnpc \
    && make -j$(nproc) \
    && strip src/bitcoin-cli

# Stage 2: Final image
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    libboost-system1.74.0 \
    libboost-filesystem1.74.0 \
    libboost-chrono1.74.0 \
    libboost-program-options1.74.0 \
    libboost-thread1.74.0 \
    libssl1.1 \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    iproute2 \
    iptables \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /bitcoin/src/bitcoind /usr/local/bin/
COPY --from=builder /bitcoin/src/bitcoin-cli /usr/local/bin/

RUN mkdir -p /bitcoin

VOLUME ["/bitcoin"]
WORKDIR /bitcoin

# Expose RPC ports
EXPOSE 8332 8333

ENTRYPOINT ["bitcoind", "-datadir=/bitcoin/.bitcoin", "-conf=/bitcoin/bitcoin.conf", "-rpcbind=0.0.0.0", "-daemon=0"]
