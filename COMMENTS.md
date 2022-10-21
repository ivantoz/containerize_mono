# Background

This project is a DevOps Assessment for Mono 

# Containerize - Comments

## Overview

The objective of this repository is to provide a development deployment to solve the **[“Works on my machine”](https://blog.codinghorror.com/the-works-on-my-machine-certification-program/)** problem which team members are facing.


## Service - Nginx

### General Notes

Nginx accepts requests on ports 80 and 443. All HTTP requests redirect to HTTPS.

Any changes to `nginx` files require a Docker image rebuild, except the SSL keypair which requires a `nginx` container restart. 
Script to build nginx image
```
docker-compose build nginx
```
The external SSL keypair is available to the `nginx` container via the following mapped volumes:
```
volumes:
    - ./nginx/files/localhost.crt:/etc/ssl/certs/localhost.crt
    - ./nginx/files/localhost.key:/etc/ssl/private/localhost.key
```

Externalized Logs for `nginx` can be found at this location: `./nginx/external/logs`.

### Settings for nginx.conf

The SSL configuration within `./nginx/nginx.conf` uses modern and secure protocols and ciphers. 
```
ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
```

Nginx proxies requests to the NodeJS app using an `upstream` directive with the following `./nginx/nginx.conf` configuration. Any update to the `app` service name or port requires a change here and an image rebuild.
```
upstream app {
    server app:8000;
}
```

The important headers `X-Forwarded-For`, `X-Real-IP`, and `X-Forwarded-Proto` are sent to the upstream application with the following `./nginx/nginx.conf` configuration:
```
location / {
    proxy_pass         https://$upstream_app;
    proxy_set_header   Host $host;
    proxy_set_header   X-Real-IP $remote_addr;
    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header   X-Forwarded-Proto $scheme;
}
```

## Service - App

### General Notes

The NodeJS app is using a Node Server. When run by itself, the app container should start the app, serving traffic with a production quality server, on port `8000` without any extra configuration.
Running `docker-compose up -d` should:
    - Start the app container in development mode listening on port `8000`
    - Allow local edits of the app source to be reflected in the running app container without restart.

In the packaged compose configuration, the `app` service is not reachable directly from the host. 
It can only be accessed through the `nginx` service because the app's port is not exposed on the docker-compose.yml file.

Due to the following mapped volume, `- "./app/src:/home/node/app:rw"`, local edits of the `app` source are reflected in the `app` container without restart. Changes to `package.json` need an `app` image rebuild since they constitute an environment change and not a code change. To rebuild you can use the compose build script, 
```bash
docker-compose build app 
```


## Deploying the System to a Development Environment

### Pre-Deployment Considerations

`nginx` base image: `nginx:1.23.2`

`app` base image: `node:18.11.0-alpine`

For the absolute minimum image size a `alpine` base image was used for `app`.

Both containers do not run as root. This is set within the Dockerfile.

### Optional Pre-build Step
To ensure service file permissions in the Docker containers match the Docker host, set the `uid` and `gid` of the internal user for the Docker containers here `./app/Dockerfile` and here `./nginx/Dockerfile`, then rebuild each image. The default `uid` and `gid` values are set to `1000`. 

### Deploy Time

To run the system issue the following command: 
```bash
docker-compose up --build -d
```

To verify a successful deployment, issue the following command: 
```bash
curl -k https://localhost/
```
Output similar to the following will be displayed.
```Text
It's easier to ask forgiveness than it is to get permission.
X-Forwarded-For: 172.20.0.1
X-Real-IP: 172.20.0.1
X-Forwarded-Proto: https
```

You can run the validation script to further test your work;

```bash
# this command will be running and build containers, so be careful
./validate.sh
```