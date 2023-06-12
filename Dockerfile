# Builder image to compile the website
FROM ubuntu as builder

WORKDIR /workdir

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    bash \
    ca-certificates \
    curl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# See https://github.com/nodesource/distributions/blob/main/README.md#debinstall
RUN curl -sSL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

RUN npm install --global yarn@1.*

# bump to update website
ENV WEBSITE_VERSION 0.9.6-next.457e49a
COPY . /workdir

RUN /usr/bin/yarn --cwd website \
  && /usr/bin/yarn --cwd website build

# Main image derived from openvsx-server 
FROM docker.io/amvanbaren/openvsx-server:457e49a6

COPY --from=builder --chown=openvsx:openvsx /workdir/website/static/ BOOT-INF/classes/static/
COPY --from=builder --chown=openvsx:openvsx /workdir/configuration/ config/
