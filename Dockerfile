# Dockerfile for building and previewing the VitePress static site
FROM oven/bun:alpine
WORKDIR /app

# VitePress needs git for lastUpdated timestamps during build
RUN apk add --no-cache git

# Install dependencies via Bun (use lockfile when available)
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile || bun install

# Copy source and build
COPY . .
RUN bun run docs:build

EXPOSE 3000
CMD ["bun", "run", "docs:preview", "--", "--host", "0.0.0.0", "--port", "3000"]
