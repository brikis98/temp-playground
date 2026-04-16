# syntax=docker/dockerfile:1
FROM node:20.19.0-bookworm-slim AS base

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY *.js ./

FROM base AS dev
USER node
ENV NODE_ENV=development
EXPOSE 8081
CMD ["npm", "run", "start:dev"]

FROM base AS test
USER node
ENV NODE_ENV=test
CMD ["npm", "test"]

FROM node:20.19.0-bookworm-slim AS prod
WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund
COPY app.js server.js ./

USER node
ENV NODE_ENV=production
EXPOSE 8081

CMD ["npm", "start"]
