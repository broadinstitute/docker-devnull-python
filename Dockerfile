# Pull the shellcheck image so we can fetch out the shellcheck binary
FROM koalaman/shellcheck-alpine:latest as shellcheck

FROM python:3.7-alpine

ENV PIPENV_NOSPIN=1 \
    PIPENV_HIDE_EMOJIS=1 \
    PIPENV_COLORBLIND=1

# This Dockerfile adds a non-root 'vscode' user with sudo access. However, for Linux,
# this user's GID/UID must match your local user UID/GID to avoid permission issues
# with bind mounts. Update USER_UID / USER_GID if yours is not 1000. See
# https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY Pipfile /tmp/

COPY --from=shellcheck /bin/shellcheck /bin/shellcheck

RUN apk update \
    && apk add bash curl dialog g++ gcc git iproute2 libffi-dev libssl1.1 libxml2-dev \
        libxslt-dev make musl-dev openssh-client openssl-dev procps sudo \
    && pip install pipenv==2018.11.26 --upgrade \
    && cd /tmp \
    && pipenv lock \
    && pipenv install --system \
    && addgroup -g $USER_GID $USERNAME \
    && adduser -D -s /bin/bash -u $USER_UID -G $USERNAME $USERNAME \
    && chmod 755 /bin/shellcheck \
    && rm -rf /root/.cache \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/tmp/*
    # [Optional] Add sudo support for the non-root user
#    && apt-get install -y sudo \
#    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#    && chmod 0440 /etc/sudoers.d/$USERNAME \
