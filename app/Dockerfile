FROM node:18.11.0-alpine

# Create app directory and modify ownership
#################################################################
RUN mkdir -p /home/node/app && chown -R node:node /home/node/app

WORKDIR /home/node/app

# Install app dependencies
#################################################################
COPY app/src/package*.json ./

RUN npm install

USER node

COPY --chown=node:node app/src/index.js .

EXPOSE 8000

CMD [ "npm","start" ]