FROM node:latest
RUN npm install -g json-server
WORKDIR /root/dist/
ENTRYPOINT json-server ./db/db.json 