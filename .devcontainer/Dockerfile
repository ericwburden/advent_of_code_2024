        FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

        # Install Gleam and other dependencies
        RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
            && apt-get -y install --no-install-recommends \
            curl \
            build-essential \
            erlang-dev \
            erlang-nox \
            elixir \
            && curl -LO https://github.com/gleam-lang/gleam/releases/download/v1.12.0/gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz \
            && tar -xzf gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz -C /usr/local/bin \
            && rm gleam-v1.12.0-x86_64-unknown-linux-musl.tar.gz

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