FROM node:latest
RUN npm install --global lite-server
WORKDIR /root/
ENTRYPOINT lite-server -c /root/bs-config.js