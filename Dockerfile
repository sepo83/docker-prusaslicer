FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# set version label
#ARG BUILD_DATE
#ARG VERSION
#ARG ORCASLICER_VERSION
#LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
#LABEL maintainer="thelamer"

# title
ENV TITLE=PrucaSlicer \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://github.com/prusa3d/PrusaSlicer/blob/master/resources/icons/PrusaSlicer.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    jq \
    firefox-esr \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-pulseaudio \
    gstreamer1.0-qt5 \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    libgstreamer1.0 \
    libgstreamer-plugins-bad1.0 \
    libgstreamer-plugins-base1.0 \
    libwebkit2gtk-4.0-37 \
    libwebkit2gtk-4.1-0 \
    libwx-perl && \
  echo "**** install prucaslicer from appimage ****" && \
  if [ -z ${PRUCASLICER_URL+x} ]; then \
    PRUSASLICER_URL=$(curl -sX GET "https://api.github.com/repos/prusa3d/PrusaSlicer/releases/latest" | \
	jq -r '.assets[].browser_download_url' | grep linux-x64 | grep GTK3 | grep .AppImage | sed 's/%2B/\+/g'); \
  fi && \
  cd /tmp && \
  curl -o \
    /tmp/prusa.app -L \
    ${PRUSASLICER_URL} && \
  chmod +x /tmp/prusa.app && \
  ./prusa.app --appimage-extract && \
  mv squashfs-root /opt/prusaslicer && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config
