# Pull the shellcheck image so we can fetch out the shellcheck binary
FROM koalaman/shellcheck:latest as shellcheck

FROM python:3.8-slim

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY pyproject.toml poetry.lock README.md /tmp/

COPY --from=shellcheck /bin/shellcheck /bin/shellcheck

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -yq bind9utils curl dialog g++ gcc git gnupg iproute2 \
        libssl-dev libxml2-dev libffi-dev libxslt1-dev make openssh-client \
        procps sudo \
    && pip install -U pip poetry \
    && cd /tmp \
    && poetry config virtualenvs.create false \
    && poetry install --no-ansi -v \
    && groupadd -g $USER_GID $USERNAME \
    && useradd -d "/home/$USERNAME" -m -s /bin/bash -u $USER_UID -g $USERNAME $USERNAME \
    && chmod 755 /bin/shellcheck \
    && rm -rf /root/.cache \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/tmp/*
    # [Optional] Add sudo support for the non-root user
#    && apt-get install -y sudo \
#    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#    && chmod 0440 /etc/sudoers.d/$USERNAME \
