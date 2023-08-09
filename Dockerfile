ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

RUN apt-get update && \
    apt-get install -y openssh-server

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
