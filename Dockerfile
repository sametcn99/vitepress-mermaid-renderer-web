# Multi-stage Dockerfile for building and serving the VitePress static site
FROM oven/bun:alpine AS builder
WORKDIR /app

# Install build dependencies via Bun (use lockfile when available)
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile --production=false || bun install --production=false

# Copy source and build
COPY . .
RUN bun run docs:build

# Normalize build output path: some setups output `dist`, others `.vitepress/dist`.
RUN if [ -d "dist" ]; then \
      cp -r dist /app/dist_out; \
    elif [ -d ".vitepress/dist" ]; then \
      cp -r .vitepress/dist /app/dist_out; \
    else \
      echo "No build output found (looked for dist or .vitepress/dist)" && exit 1; \
    fi

FROM nginx:stable-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static site from builder
COPY --from=builder /app/dist_out/ /usr/share/nginx/html/

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
