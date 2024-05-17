# FROM ghcr.io/linuxserver/baseimage-alpine:edge
FROM node:20-bookworm
# FROM ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION

LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="NeilSeligmann"

ARG DEBIAN_FRONTEND=noninteractive

# RUN apt update -y && apt -y install software-properties-common dirmngr apt-transport-https lsb-release ca-certificates

RUN apt update -y && apt install -y -q \
	jq \
	wget \
	libasound2 \
	bzip2 \
	curl \
	pulseaudio \
	pulseaudio-utils \
	alsa-utils

ENV WORKDIR /plexamp

RUN mkdir -p $WORKDIR
RUN chown -R $UNAME:$UNAME $WORKDIR
USER $UNAME

WORKDIR $WORKDIR
RUN wget -q "$(curl -s "https://plexamp.plex.tv/headless/version$1.json" | jq -r '.updateUrl')" -O plexamp.tar.bz2
RUN tar xfj plexamp.tar.bz2


ENV WORKDIR $WORKDIR/plexamp
WORKDIR $WORKDIR

COPY ./run.sh $WORKDIR/run.sh
RUN chmod +x $WORKDIR/run.sh

USER node

ENTRYPOINT sh -c $WORKDIR/run.sh
