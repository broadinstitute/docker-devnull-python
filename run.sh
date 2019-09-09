#!/bin/bash

DOCKER_IMAGE='broadinstitute/devnull-python:latest'
SUDO=

usage() {
    PROG="$( basename "$0" )"
    echo "usage: ${PROG} [--version] [--help] <command> [<args>]"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

if [ "$TERM" != 'dumb' ] ; then
    TTY='-it'
fi

if [ "$( uname -s )" != 'Darwin' ]; then
    if [ ! -w "$DOCKER_SOCKET" ]; then
        SUDO='sudo'
    fi
fi

$SUDO docker run $TTY --rm \
    -v "$( pwd )":/usr/src \
    $DOCKER_IMAGE "$@"
