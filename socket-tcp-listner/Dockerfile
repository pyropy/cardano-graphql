FROM debian:buster-slim
RUN apt-get update -y && apt-get install socat -y

RUN mkdir /ipc 

RUN touch /ipc/node.socket

EXPOSE 3333

ENV CARDANO_NODE_SOCKET_PATH=/ipc/node.socket \
    SOCKET_TCP_ADDRESS=socket-tcp-listner:3333
    
CMD ["socat", "UNIX-LISTEN:$CARDANO_NODE_SOCKET_PATH,fork,reuseaddr,unlink-early, TCP:$SOCKET_TCP_ADDRESS"]
