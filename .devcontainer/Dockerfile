FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install Gleam, Rust prerequisites, and other dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    build-essential \
    pkg-config \
    erlang-dev \
    erlang-nox \
    elixir \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LO https://github.com/gleam-lang/gleam/releases/download/v1.12.0/gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz -C /usr/local/bin \
    && rm gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --default-toolchain stable

# Add Cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install aoc-cli with Cargo
RUN cargo install aoc-cli

# Set default user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if [ "$USER_UID" != "1000" ] || [ "$USER_GID" != "1000" ]; then \
        groupadd --gid $USER_GID $USERNAME \
        && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
        && apt-get update \
        && apt-get install -y sudo \
        && echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
        && chmod 0440 /etc/sudoers.d/$USERNAME; \
    fi
