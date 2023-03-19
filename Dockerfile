FROM node:16-alpine3.15

RUN apk update
RUN apk add curl bash

RUN curl -o- -L https://yarnpkg.com/install.sh | bash

ENV PATH="/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:${PATH}"

WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .
RUN yarn add serve
RUN yarn build
ENV PORT=8080
ENV NODE_PORT=8080

RUN yarn add pm2
RUN pm2 start "yarn serve --port 8080" --name vue
#CMD ["yarn", "serve", "-s", "build", "-l", "8080"]