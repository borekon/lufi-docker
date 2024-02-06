FROM debian:12-slim

ARG LUFI_VERSION=0.07.0

USER root

RUN apt update \
	&& apt install -y \
    wget \
    unzip \
    cron \
    sudo \
	build-essential \
	libssl-dev \
    zlib1g-dev \
	libio-socket-ssl-perl \
	libmojo-pg-perl \
	liblwp-protocol-https-perl \
	&& apt-get clean -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log,tmp}/*

RUN addgroup --gid $GID nonroot
RUN adduser --uid $UID --gid $GID --disabled-password --gecos "" nonroot
RUN echo 'nonroot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# copie des cron
COPY lufi-cron /etc/cron.d/lufi-cron
RUN chmod 0644 /etc/cron.d/lufi-cron

RUN cpan Carton
USER nonroot
WORKDIR /home/nonroot/lufi


RUN wget https://framagit.org/fiat-tux/hat-softwares/lufi/-/archive/${LUFI_VERSION}/lufi-${LUFI_VERSION}.zip \
    && unzip lufi-${LUFI_VERSION}.zip -d /tmp \
    && mv /tmp/lufi-${LUFI_VERSION}/* /home/nonroot/lufi \
    && rm -rf /tmp/* lufi-${LUFI_VERSION}.zip


COPY --chown=nonroot:nonroot lufi.conf /home/nonroot/lufi/lufi.conf
RUN mkdir -p /home/nonroot/lufi/themes/megalis
COPY themes/megalis /home/nonroot/lufi/themes/megalis
COPY docker-entrypoint.sh /home/nonroot/lufi/docker-entrypoint.sh
RUN chmod a+x /home/nonroot/lufi/docker-entrypoint.sh


RUN carton install --deployment --without=test --without=mysql \
    && rm -rf local/cache/* local/man/*


EXPOSE 8081
ENTRYPOINT ["/home/nonroot/lufi/docker-entrypoint.sh"]
