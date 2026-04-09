# BizCloud AI App

Now with 400% more cloud!

## Running locally

First, install dependencies:

```shell
npm install
```

To run the app (with hot reload via `nodemon`):

```shell
npm run start:dev
```

You can now test the app at http://localhost:8080.

To run tests:

```shell
npm test
```

## Running in Docker

The `Dockerfile` defines three targets:

- `dev`: For running locally (with hot reload via `nodemon`). Includes dev dependencies.
- `test`: For running automated tests. Includes dev dependencies.
- `prod`: For deployment (e.g., into Kubernetes). Does not include dev dependencies.

To build all three targets:

```shell
docker build --target dev -t bizcloud-ai:dev .
docker build --target test -t bizcloud-ai:test .
docker build --target prod -t bizcloud-ai:<VERSION> .
```

To run the dev image (with code bind-mounted from the host OS for hot reload):

```shell
docker run \
  --rm \
  -p 8080:8080 \
  -it \
  --init \
  -v .:/usr/src/app \
  -v /usr/src/app/node_modules \
  bizcloud-ai:dev
```

To run the test image:

```shell
docker run --rm -it --init bizcloud-ai:test
```

To run the prod image:

```shell
docker run --rm -p 8080:8080 -it --init bizcloud-ai:<VERSION>
```