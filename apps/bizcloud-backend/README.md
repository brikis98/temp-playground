# BizCloud Backend App

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

You can now test the app at http://localhost:8081.

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
docker build --target dev -t bizcloud-backend:dev .
docker build --target test -t bizcloud-backend:test .
docker build --target prod -t bizcloud-backend:<VERSION> .
```

To run the dev image (with code bind-mounted from the host OS for hot reload):

```shell
docker run \
  --rm \
  -p 8081:8081 \
  -it \
  --init \
  -v .:/usr/src/app \
  -v /usr/src/app/node_modules \
  bizcloud-backend:dev
```

To run the test image:

```shell
docker run --rm -it --init bizcloud-backend:test
```

To run the prod image:

```shell
docker run --rm -p 8081:8081 -it --init bizcloud-backend:<VERSION>
```

## Building and pushing the Docker image for prod

You have to build Docker images for a specific CPU architecture. For example, if you have an M-series Mac, you need to
build for `linux/arm64`. If you are going to deploy in an EKS cluster, you typically have to build for `linux/amd64`.

To do that, you first need to create and use a `buildx` builder with Docker:

```shell
docker buildx create --name multi --use
docker buildx inspect --bootstrap
```

Authenticate to your ECR repository:

```shell
aws ecr get-login-password --region us-east-2 \
| docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.us-east-2.amazonaws.com
```

You can then build and push Docker images for multiple CPU architectures:

```shell
docker buildx build \
  --target prod \
  --platform linux/amd64,linux/arm64 \
  -t <ECR_REPO_URL>:<VERSION> \
  --push \
  .
```
