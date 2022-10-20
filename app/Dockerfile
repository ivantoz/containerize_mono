# your code goes here ...
FROM node:14-alpine

RUN mkdir -p /home/node/app && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY src/package*.json ./

RUN npm install

USER node

COPY --chown=node:node src .

EXPOSE 8000

CMD [ "node", "index.js" ]