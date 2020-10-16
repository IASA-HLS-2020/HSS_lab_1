# HSS_lab1 :rocket:

IASA HighScalable Systems lab 1

## Task 1

[docker-compose.yml](task_1/docker-compose.yml)

```yaml
version: "3.8"
services:
hello-world:
    image: hello-world:latest
```

## Task 2

[docker-compose.yml](task_2/docker-compose.yml)

```yaml
version: "3.8"
services:
lite-server:
    restart: always
    build: .
    volumes:
    - ./dist:/root/dist
    ports:
    - 3000:3000
```

[Dockerfile](task_2/Dockerfile)

```Dockerfile
FROM node:latest
RUN npm install --global lite-server
WORKDIR /root/dist/
ENTRYPOINT lite-server -c bs-config.js
```

[bs-config.js](task_2/dist/bs-config.js)

```javasscript
module.exports = {
  server: { baseDir: "./static/" },
  open: false,
};
```

## Task 3

[docker-compose.yml](task_3/docker-compose.yml)

```yaml
version: "3.8"
services:
json-server:
    restart: always
    build: .
    volumes:
    - ./dist:/root/dist
    ports:
    - 3000:80
```

[Dockerfile](task_3/Dockerfile)

```Dockerfile
FROM node:latest
RUN npm install -g json-server
WORKDIR /root/dist/
ENTRYPOINT json-server ./db/db.json
```

[json-server.json](task_3/dist/json-server.json)

```json
{
  "port": 80,
  "host": "0.0.0.0",
  "watch": true,
  "static": "./static"
}
```

## Task 4

[docker-compose.yml](task_4/docker-compose.yml)

```yaml
version: "3.8"
services:
    nginx:
        restart: always
        image: nginx:latest
        command: "nginx -g 'daemon off;'"
        volumes:
        - ./nginx/nginx.conf:/etc/nginx/nginx.conf
        ports:
        - 8000:80
        depends_on:
        - json-server
        - lite-server

    json-server:
        restart: always
        build: 
        context: ./api
        dockerfile: ./api.Dockerfile
        volumes:
        - ./api:/root
    
    lite-server:
        restart: always
        build: 
        context: ./dist
        dockerfile: ./lite.Dockerfile
        entrypoint: lite-server -c /root/bs-config.js
        volumes: 
        - ./dist:/root
```

[lite.Dockerfile](task_4/dist/lite.Dockerfile)

```Dockerfile
FROM node:latest
RUN npm install --global lite-server
WORKDIR /root/
ENTRYPOINT lite-server -c /root/bs-config.js
```

[api.Dockerfile](task_4/dist/api.Dockerfile)

```Dockerfile
FROM node:latest
RUN npm install -g json-server
WORKDIR /root/
ENTRYPOINT json-server /root/db/db.json --routes routes.json
```

[json-server.json](task_4/api/json-server.json)

```json
{
  "host": "0.0.0.0",
  "watch": true
}
```

[routes.json](task_4/api/routes.json)

```json
{
  "/api/*": "/$1"
}
```

[bs-config.js](task_4/dist/bs-config.js)

```javasscript
module.exports = {
  server: { baseDir: "./static/" },
  open: false
};
```

[nginx.conf](task_4/nginx/nginx.conf)

```conf
events { worker_connections 1024; }

http {

  upstream static {
    least_conn;
    server lite-server:3000;
  }
  upstream api {
    least_conn;
    server json-server:3000;
  }

  server {

    listen 80;
    log_subrequest on;
    location /api/ {
        proxy_http_version 1.1;
      proxy_connect_timeout 300s;
      proxy_send_timeout 300s;
      proxy_read_timeout 300s;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_cache_bypass $http_upgrade;
      proxy_pass http://api/;
    }
    location / {
      proxy_http_version 1.1;
      proxy_connect_timeout 300s;
      proxy_send_timeout 300s;
      proxy_read_timeout 300s;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_cache_bypass $http_upgrade;
      proxy_pass http://static/;
    }
  }
}
```

## Task 5

[Postman collection](task_5/HSS_lab1.postman_collection.json)
