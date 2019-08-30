FROM alpine

ENV IMAGE_NAME="minecraft"
ENV SERVER_FILE="server.jar"
ENV WORKING="opt/${IMAGE_NAME}"
WORKDIR /${WORKING}

RUN apk update && apk add openjdk8 && apk add tmux

COPY ./${SERVER_FILE} /${WORKING}/
COPY ./minecraft/* /${WORKING}/

RUN chmod +x /${WORKING}/*.sh

EXPOSE 25565
ENTRYPOINT ["./entrypoint.sh"]
