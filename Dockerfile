FROM alpine:latest as builder

ARG DEPTRAC_VERSION=0.12.0
ARG GPG_KEY=ED42E9154E81A416E7FBA19F4F2AB4D11A9A65F7
ARG GPG_KEY_SERVER=hkps://keys.openpgp.org

RUN apk add --update --no-cache curl gnupg \
    && curl -LS https://github.com/qossmic/deptrac/releases/download/$DEPTRAC_VERSION/deptrac.phar -o /tmp/deptrac \
    && curl -LS https://github.com/qossmic/deptrac/releases/download/$DEPTRAC_VERSION/deptrac.phar.asc -o /tmp/deptrac.phar.asc \
    && gpg --keyserver $GPG_KEY_SERVER --recv-keys $GPG_KEY \
    && gpg --verify /tmp/deptrac.phar.asc /tmp/deptrac \
    && chmod +x /tmp/deptrac

# ---

FROM php:8.0.9-alpine as release

LABEL "repository"="https://github.com/ohartl/docker-deptrac"
LABEL "homepage"="https://github.com/ohartl/docker-deptrac/"
LABEL "maintainer"="Oliver Hartl <hello@ohartl.de>"

RUN apk add --update --no-cache graphviz ttf-freefont
COPY --from=builder /tmp/deptrac /usr/local/bin/deptrac

VOLUME ["/app"]
WORKDIR /app

ENTRYPOINT ["deptrac"]
CMD ["analyze"]
