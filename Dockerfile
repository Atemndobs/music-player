FROM node:16-alpine3.15

RUN apk update
RUN apk add curl bash

RUN curl -o- -L https://yarnpkg.com/install.sh | bash

ENV PATH="/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:${PATH}"

WORKDIR /app

COPY package*.json ./
COPY .env ./
RUN yarn install
RUN npm install serve -g

COPY . .
# RUN yarn add serve

ENV PORT=8080
ENV NODE_PORT=8080

RUN npm install pm2 -g

RUN yarn build

# CMD ["pm2", "start", "/usr/lib/node_modules/serve/bin/serve", "-s", "dist", "--name", "vue", "--no-daemon"]