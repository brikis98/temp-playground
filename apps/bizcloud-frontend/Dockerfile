# syntax=docker/dockerfile:1
FROM node:20.19.0-bookworm-slim AS base

WORKDIR /usr/src/app

# Install dependencies from lockfile in a cache-friendly layer.
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

# Copy application sources once and reuse in downstream targets.
COPY *.js ./
COPY views ./views

FROM base AS dev
USER node
ENV NODE_ENV=development
EXPOSE 8080
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
COPY views ./views

USER node
ENV NODE_ENV=production
EXPOSE 8080

CMD ["npm", "start"]
