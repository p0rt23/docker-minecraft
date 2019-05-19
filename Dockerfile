FROM alpine

ENV IMAGE_NAME="minecraft"
ENV SERVER_FILE="server.jar"
ENV WORKING="opt/${IMAGE_NAME}"
WORKDIR /${WORKING}

RUN apk update && apk add openjdk8 && apk add tmux

COPY ./${SERVER_FILE} /${WORKING}/
COPY ./minecraft/* /${WORKING}/

RUN mkdir backups &&\
    chmod +x /${WORKING}/*.sh &&\
    crontab crontab.txt &&

EXPOSE 25565
VOLUME ["./world", "./backups"]
ENTRYPOINT ["./server-start.sh"]
