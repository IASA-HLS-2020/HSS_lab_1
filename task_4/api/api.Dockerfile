FROM node:latest
RUN npm install -g json-server
WORKDIR /root/
ENTRYPOINT json-server /root/db/db.json --routes routes.json