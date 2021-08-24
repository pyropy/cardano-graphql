FROM debian:buster-slim
RUN apt-get update -y && apt-get install socat -y

EXPOSE 3333

CMD ["socat TCP-LISTEN:3333,reuseaddr,fork UNIX-CONNECT:/node-ipc/node.socket"]
