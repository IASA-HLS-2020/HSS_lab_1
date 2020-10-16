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

```javascript
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

```javascript
module.exports = {
  server: { baseDir: "./static/" },
  open: false,
};
```

[nginx.conf](task_4/nginx/nginx.conf)

```Nginx
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

```json
{
  "info": {
    "_postman_id": "f293d78e-f492-4707-8013-a90549e5d7b4",
    "name": "HSS lab1",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "api",
      "item": [
        {
          "name": "Posts",
          "item": [
            {
              "name": "Posts list",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "e0238cbf-05b4-4e97-986c-ffb0974f0673",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = [",
                      "    {",
                      "        \"id\": 1,",
                      "        \"title\": \"Post 1\"",
                      "    },",
                      "    {",
                      "        \"id\": 2,",
                      "        \"title\": \"Post 2\"",
                      "    },",
                      "    {",
                      "        \"id\": 3,",
                      "        \"title\": \"Post 3\"",
                      "    }",
                      "    ]",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/posts",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "posts"]
                },
                "description": "Show posts list"
              },
              "response": []
            },
            {
              "name": "Post 1",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "dcb5c2b6-aa2b-49fb-affa-6f2d14d74fef",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = ",
                      "    {",
                      "    \"id\": 1,",
                      "    \"title\": \"Post 1\"",
                      "  }",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/posts/1",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "posts", "1"]
                },
                "description": "Show post with id 1"
              },
              "response": []
            },
            {
              "name": "Post 2",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "04cd8fc0-f4a3-4de2-a13d-96cd7a290175",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = ",
                      "    {",
                      "    \"id\": 2,",
                      "    \"title\": \"Post 2\"",
                      "  }",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/posts/2",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "posts", "2"]
                },
                "description": "Show post with id 2"
              },
              "response": []
            },
            {
              "name": "Post 3",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "292ab31d-1c68-4251-9395-d69e26a66911",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = ",
                      "    {",
                      "    \"id\": 3,",
                      "    \"title\": \"Post 3\"",
                      "  }",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/posts/3",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "posts", "3"]
                },
                "description": "Show post with id 3"
              },
              "response": []
            }
          ],
          "protocolProfileBehavior": {},
          "_postman_isSubFolder": true
        },
        {
          "name": "Comments",
          "item": [
            {
              "name": "Comments list",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "1e024bd0-68cc-4588-8a18-28604d5941ff",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = [",
                      "    {",
                      "      \"id\": 1,",
                      "      \"body\": \"some comment\",",
                      "      \"postId\": 1",
                      "    },",
                      "    {",
                      "      \"id\": 2,",
                      "      \"body\": \"some comment\",",
                      "      \"postId\": 1",
                      "    }",
                      "  ]",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/comments",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "comments"]
                },
                "description": "Show comments list"
              },
              "response": []
            },
            {
              "name": "Comments 1",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "4ddfe03b-4ce3-4789-b25c-24b1df171e89",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = ",
                      "    {",
                      "        \"id\": 1,",
                      "        \"body\": \"some comment\",",
                      "        \"postId\": 1",
                      "    }",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/comments/1",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "comments", "1"]
                },
                "description": "Show comment with id 1"
              },
              "response": []
            },
            {
              "name": "Comments 2",
              "event": [
                {
                  "listen": "test",
                  "script": {
                    "id": "e5bc7f7e-49c7-4041-bb6e-4d870f50f2ac",
                    "exec": [
                      "pm.test(\"Status code is 200\", function () {",
                      "    pm.response.to.have.status(200);",
                      "});",
                      "pm.test(\"Is valid dummy db\", function () {",
                      "    var jsonData = pm.response.json();",
                      "    var expect = ",
                      "    {",
                      "        \"id\": 2,",
                      "        \"body\": \"some comment\",",
                      "        \"postId\": 1",
                      "    }",
                      "    pm.expect(jsonData).to.eql(expect);",
                      "});"
                    ],
                    "type": "text/javascript"
                  }
                }
              ],
              "request": {
                "method": "GET",
                "header": [],
                "url": {
                  "raw": "http://localhost:8000/api/comments/2",
                  "protocol": "http",
                  "host": ["localhost"],
                  "port": "8000",
                  "path": ["api", "comments", "2"]
                },
                "description": "Show comment with id 2"
              },
              "response": []
            }
          ],
          "protocolProfileBehavior": {},
          "_postman_isSubFolder": true
        },
        {
          "name": "Profile",
          "event": [
            {
              "listen": "test",
              "script": {
                "id": "c0dafd3b-3448-44c1-9045-b1c331ed461f",
                "exec": [
                  "pm.test(\"Status code is 200\", function () {",
                  "    pm.response.to.have.status(200);",
                  "});",
                  "pm.test(\"Is valid dummy db\", function () {",
                  "    var jsonData = pm.response.json();",
                  "    var expect = [",
                  "    {",
                  "      \"id\": 1,",
                  "      \"body\": \"some comment\",",
                  "      \"postId\": 1",
                  "    },",
                  "    {",
                  "      \"id\": 2,",
                  "      \"body\": \"some comment\",",
                  "      \"postId\": 1",
                  "    }",
                  "  ]",
                  "    pm.expect(jsonData).to.eql(expect);",
                  "});"
                ],
                "type": "text/javascript"
              }
            }
          ],
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8000/api/comments",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8000",
              "path": ["api", "comments"]
            },
            "description": "Show profile object"
          },
          "response": []
        }
      ],
      "protocolProfileBehavior": {}
    },
    {
      "name": "static",
      "item": [
        {
          "name": "Welcome page",
          "event": [
            {
              "listen": "test",
              "script": {
                "id": "f9f0e114-af90-4d79-93b2-a00bdc637592",
                "exec": [
                  "pm.test(\"Status code is 200\", function () {",
                  "    pm.response.to.have.status(200);",
                  "});"
                ],
                "type": "text/javascript"
              }
            }
          ],
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "http://localhost:8000/index.html",
              "protocol": "http",
              "host": ["localhost"],
              "port": "8000",
              "path": ["index.html"]
            },
            "description": "Get a welcoms static page"
          },
          "response": []
        }
      ],
      "protocolProfileBehavior": {}
    }
  ],
  "protocolProfileBehavior": {}
}
```
