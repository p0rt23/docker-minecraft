FROM ghcr.io/graalvm/jdk-community:22

ENV IMAGE_NAME="minecraft"
ENV SERVER_FILE="server.jar"
ENV WORKING="opt/${IMAGE_NAME}"
WORKDIR /${WORKING}

RUN microdnf update -y && \
  microdnf install -y tmux

COPY ./${SERVER_FILE} /${WORKING}/
COPY ./minecraft/ /${WORKING}/

RUN chmod +x /${WORKING}/*.sh

EXPOSE 25565
ENTRYPOINT ["./entrypoint.sh"]
