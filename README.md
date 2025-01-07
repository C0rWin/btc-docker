# Bitcoin Core Docker Container

## Introduction

This repository contains a Dockerfile for building and running a Bitcoin Core node. The Docker image is built in two stages: one for compiling Bitcoin Core from 
source and another for creating the final runtime image with only the necessary binaries and dependencies.

## Description

### Stage 1: Build Bitcoin Core

- **Base Image**: `debian:bullseye-slim`
- **Dependencies Installed**:
  - `automake`, `autotools-dev`, `build-essential`, `git`, `libtool`, `pkg-config`, `python3-minimal`
  - Boost libraries (`libboost-system-dev`, `libboost-filesystem-dev`, `libboost-chrono-dev`, `libboost-program-options-dev`, `libboost-test-dev`, 
`libboost-thread-dev`)
  - OpenSSL and libevent development libraries
  - `libdb++-dev`, `bsdmainutils`
- **Build Process**:
  - Clones the Bitcoin Core repository (`v25.1`).
  - Configures, builds, and strips the `bitcoin-cli` binary.

### Stage 2: Final Image

- **Base Image**: `debian:bullseye-slim`
- **Dependencies Installed**:
  - Boost runtime libraries
  - OpenSSL and libevent runtime libraries
  - `iproute2`, `iptables`
- **Binary Copies**:
  - `bitcoind` and `bitcoin-cli` from the builder stage.
- **Volume**:
  - `/bitcoin` for data storage.
- **Ports Exposed**:
  - `8332` (RPC)
  - `8333` (P2P)
- **Entry Point**:
  - Runs `bitcoind` with default configuration options.

## How to Build the Image

To build the Docker image, navigate to the directory containing the `Dockerfile` and run the following command:

```sh
docker build -t bitcoin-core:v25.1 .
```

This will create a Docker image tagged as `bitcoin-core:v25.1`.

## How to Run the Container

### Basic Usage

To run a Bitcoin Core node, use the following command:

```sh
docker run -d --name bitcoin-node -v bitcoin-data:/bitcoin -p 8332:8332 -p 8333:8333 bitcoin-core:v25.1
```

- `-d`: Runs the container in detached mode.
- `--name bitcoin-node`: Assigns a name to the container.
- `-v bitcoin-data:/bitcoin`: Mounts a Docker volume named `bitcoin-data` to `/bitcoin` inside the container.
- `-p 8332:8332 -p 8333:8333`: Exposes ports 8332 and 8333.

### Custom Configuration

You can provide a custom configuration file (`bitcoin.conf`) by mounting it into the container:

1. Create a `bitcoin.conf` file on your host machine.
2. Mount this file into the container using the `-v` option.

Example:

```sh
docker run -d --name bitcoin-node -v bitcoin-data:/bitcoin -v /path/to/bitcoin.conf:/bitcoin/bitcoin.conf -p 8332:8332 -p 8333:8333 bitcoin-core:v25.1
```

### Using RPC

To interact with the Bitcoin Core node via RPC, you can use `bitcoin-cli` from another container or host machine.

Example:

```sh
docker exec -it bitcoin-node bitcoin-cli getblockcount
```

## Example Configuration File (`bitcoin.conf`)

Here is an example of a basic `bitcoin.conf` file:

```ini
rpcuser=your_rpc_user
rpcpassword=your_rpc_password
rpcallowip=0.0.0.0/0
txindex=1
server=1
daemon=0
```

**Note**: Adjust the `rpcuser` and `rpcpassword` to secure your node.

## Conclusion

This Docker setup provides a convenient way to run a Bitcoin Core node in an isolated environment, making it easy to manage and scale. For more advanced 
configurations, refer to the [Bitcoin Core documentation](https://bitcoin.org/en/full-node).
