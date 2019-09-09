FROM python:3.7-alpine

RUN apk update \
    && apk add bash curl g++ gcc git libffi-dev libssl1.1 libxml2-dev libxslt-dev make musl-dev openssh-client openssl-dev \
    && pip install pipenv==2018.11.26 --upgrade \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/tmp/*

WORKDIR /usr/src

CMD ["bash", "-l"]
