#ddev-generated

FROM seleniarm/standalone-chromium:4.1.4-20220429
ENV CAROOT=/mnt/ddev-global-cache/mkcert

USER root
RUN apt update >/dev/null && apt install -y iputils-ping less mkcert vim >/dev/null
RUN usermod -s /bin/bash seluser
USER seluser
RUN echo "capath=/etc/ssl/certs/" >>~/.curlrc
