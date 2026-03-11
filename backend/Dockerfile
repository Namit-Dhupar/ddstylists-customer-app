# Stage 1: Build (Dependencies)
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Copy package manifests
COPY package*.json ./

# Install all dependencies (including devDependencies for testing/linting if applied)
RUN npm install

# Copy application source code
COPY . .

# Stage 2: Production (Runtime)
FROM node:20-alpine

# Enforce production mode for optimized Express performance
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy package manifests
COPY package*.json ./

# Install only production dependencies for a smaller attack surface
RUN npm install --omit=dev

# Copy application structure from builder
COPY --from=builder /usr/src/app/src ./src
COPY --from=builder /usr/src/app/server.js ./server.js

# Hardening: Switch to the least privileged user 'node' 
# provided by the official Node Alpine image.
USER node

# Expose API Port
EXPOSE 5000

# Start Express server
CMD ["node", "server.js"]
