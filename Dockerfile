# Multi-stage Dockerfile for building and serving the VitePress static site
FROM node:20-alpine AS builder
WORKDIR /app

# Install build dependencies
COPY package.json package-lock.json* ./
RUN npm ci --no-audit --no-fund

# Copy source and build
COPY . .
RUN npm run docs:build

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

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
