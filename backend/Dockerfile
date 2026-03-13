# ───── Stage 1: Install Dependencies ─────
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy package manifests first (Docker layer caching)
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy application source code
COPY . .

# ───── Stage 2: Production Runtime ─────
FROM node:20-alpine

# Enforce production mode
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy package manifests
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy application from builder
COPY --from=builder /usr/src/app/src ./src
COPY --from=builder /usr/src/app/server.js ./server.js

# Create uploads directory with correct ownership
# (node user is UID 1000 in the official Node Alpine image)
RUN mkdir -p /usr/src/app/uploads && chown -R node:node /usr/src/app/uploads

# Switch to non-root user for security
USER node

# Expose API port (Render uses $PORT, default 5000)
EXPOSE 5000

# Health check to let Docker/Render know the container is alive
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-5000}/api/health || exit 1

# Start Express server
CMD ["node", "server.js"]
