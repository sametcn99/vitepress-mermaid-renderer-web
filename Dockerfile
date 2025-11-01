# Dockerfile for building and previewing the VitePress static site
FROM oven/bun:alpine
WORKDIR /app

# VitePress needs git for lastUpdated timestamps during build
RUN apk add --no-cache git

# Install dependencies via Bun (use lockfile when available)
COPY package.json ./
RUN bun install

# Copy source and build
COPY . .
RUN bun run docs:build

EXPOSE 3000
# Bind VitePress preview server to all interfaces so it is reachable outside the container
CMD ["bun", "run", "docs:preview", "--", "--host", "0.0.0.0", "--port", "3000"]
