FROM alpine

ENV IMAGE_NAME="minecraft"
ENV SERVER_FILE="server.jar"
ENV WORKING="opt/${IMAGE_NAME}"
WORKDIR /${WORKING}

RUN apk update && apk add tmux
RUN apk add \
    --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
    openjdk17

COPY ./${SERVER_FILE} /${WORKING}/
COPY ./minecraft/ /${WORKING}/

RUN chmod +x /${WORKING}/*.sh

EXPOSE 25565
ENTRYPOINT ["./entrypoint.sh"]
