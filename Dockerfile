FROM node:20-bullseye

ENV UNAME pacat

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y -q \
	jq \
	wget \
	libasound2 \
	bzip2 \
	curl \
	pulseaudio-utils

# Set up the user
RUN export UNAME=$UNAME UID=1000 GID=1000 && \
	mkdir -p "/home/${UNAME}" && \
	echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:/home/${UNAME}:/bin/bash" >> /etc/passwd && \
	echo "${UNAME}:x:${UID}:" >> /etc/group && \
	mkdir -p /etc/sudoers.d && \
	echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
	chmod 0440 /etc/sudoers.d/${UNAME} && \
	chown ${UID}:${GID} -R /home/${UNAME} && \
	gpasswd -a ${UNAME} audio

# COPY pulse-client.conf /etc/pulse/client.conf

# ENV HOME /home/pacat

ENV WORKDIR /home/pacat
RUN mkdir -p $WORKDIR

COPY ./run.sh $WORKDIR/plexamp/run.sh
RUN chmod +x $WORKDIR/plexamp/run.sh

RUN chown -R $UNAME:$UNAME $WORKDIR
USER $UNAME

WORKDIR $WORKDIR
RUN wget -q "$(curl -s "https://plexamp.plex.tv/headless/version$1.json" | jq -r '.updateUrl')" -O plexamp.tar.bz2
RUN tar xfj plexamp.tar.bz2
ENV WORKDIR $WORKDIR/plexamp
WORKDIR $WORKDIR
# ENTRYPOINT node $WORKDIR/js/index.js

ENTRYPOINT sh -c $WORKDIR/run.sh
