FROM node:16-alpine3.15

RUN apk update
RUN apk add curl bash

RUN curl -o- -L https://yarnpkg.com/install.sh | bash

ENV PATH="/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:${PATH}"

WORKDIR /app

COPY package*.json ./
RUN yarn install

COPY . .

CMD ["yarn", "start"]