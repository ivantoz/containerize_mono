# DevOps Assessment (Containerize)

As a DevOps Engineer of a remote team writing node.js, you are tasked with solving the **[“Works on my machine”](https://blog.codinghorror.com/the-works-on-my-machine-certification-program/)** problem your team mates are facing.

## The Task

Using Docker and Docker compose, containerize a node.js application fronted by an niginx reverse proxy and show us your understanding about how to deploy an application securely while still allowing for low friction development.

What we’ll be reviewing in your submission;

- Secure and performant settings in your nginx configuration, including SSL/TLS specifics
- Usage of the principle of least privilege/surprise
- Docker best practices including security, configuration, and image size

### Part 1

Complete the provided `nginx/nginx.conf` by writing a `server` directive(s) that proxies to the upstream application.

Requirements;

- Nginx should accept requests on ports 80 and 443
- All HTTP requests should permanently redirect to their HTTPS equivalent
- Use the provided SSL keypair found in `nginx/files/localhost.crt` and `nginx/files/localhost.key` for your SSL configuration
- Ensure the SSL keypair is available to nginx, but is not baked in to the container image
- The SSL configuration should use modern and secure protocols and ciphers
- Nginx should proxy requests to the application using an `upstream` directive
- Pass headers `X-Forwarded-For`, `X-Real-IP`, and `X-Forwarded-Proto` to the upstream application with appropriate values

### Part 2

Complete `app/Dockerfile`, `nginx/Dockerfile` and `docker-compose.yml` to produce a production ready image that can be also be used for development with Compose.

Requirements;

- The app found in `./app/src` is securely built, installed, and configured into a container.
- When run by itself, the app container should start the app, serving traffic with a production quality server, on port `8000` without any extra configuration.
- Running `docker-compose up` should:
    - Start the app container in development mode listening on port `8000`
    - Allow local edits of the app source to be reflected in the running app container without restart (eg: hot code reload)
    - Start an nginx container configured with the files from Part One
    - The `app` service should not be reachable directly from the host and can only be accessed through the `nginx` service.

### Putting it all together

After running `docker-compose up` a command such as `curl -k [https://localhost/](https://localhost/)` should return output similar to:

```bash
You cannot be more than what you are.
X-Forwarded-For: 192.168.0.1
X-Real-IP: 192.168.0.1
X-Forwarded-Proto: https
```

You can run the validation script to further test your work;

```bash
# this command would would running and build containers, so be careful
./validate.sh
```

### Dos

- Do add notes on running your solution and why you choose your particular solution in a `COMMENTS.md` file. Remember, you are working with a remote team. Written communication is important!
- Do feel free to offer suggestions or feedback on this exercise

### Do nots

- Do not worry about data persistence, scaling, or OCSP stapling
- Do not alter `validate.sh` or the SSL key pair in `nginx/files`.
- Do not modify the `app` and `nginx` service names in `docker-compose.yml`.
- Do not modify the `app` and `nginx` container names in `docker-compose.yml`.
- Do not create any additional Dockerfile or docker-compose files