FROM alpine:latest as builder

ARG DEPTRAC_VERSION=0.15.2
ARG GPG_KEY=41DDE07547459FAECFA17813B8F640134AB1782E
ARG GPG_KEY_SERVER=hkps://keys.openpgp.org

RUN apk add --update --no-cache curl gnupg \
    && curl -LS https://github.com/qossmic/deptrac/releases/download/$DEPTRAC_VERSION/deptrac.phar -o /tmp/deptrac \
    && curl -LS https://github.com/qossmic/deptrac/releases/download/$DEPTRAC_VERSION/deptrac.phar.asc -o /tmp/deptrac.phar.asc \
    && gpg --keyserver $GPG_KEY_SERVER --recv-keys $GPG_KEY \
    && gpg --verify /tmp/deptrac.phar.asc /tmp/deptrac \
    && chmod +x /tmp/deptrac

# ---

FROM php:8.0.11-alpine as release

LABEL "repository"="https://github.com/ohartl/docker-deptrac"
LABEL "homepage"="https://github.com/ohartl/docker-deptrac/"
LABEL "maintainer"="Oliver Hartl <hello@ohartl.de>"

RUN apk add --update --no-cache graphviz ttf-freefont
COPY --from=builder /tmp/deptrac /usr/local/bin/deptrac

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["deptrac"]
CMD ["analyze"]
