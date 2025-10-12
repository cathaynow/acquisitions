# See https://docs.docker.com/engine/reference/builder/
# Multi-stage Dockerfile for dev and prod

# Base dependencies
FROM node:22-alpine AS base
WORKDIR /app

# Install dependencies first (leverage Docker layer cache)
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the source
COPY . .

ENV PORT=3000
EXPOSE 3000

# Development stage
FROM base AS development
ENV NODE_ENV=development
CMD ["npm", "run", "dev"]

# Production stage
FROM node:22-alpine AS production
WORKDIR /app
ENV NODE_ENV=production

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy necessary app files
COPY src ./src
COPY drizzle.config.js ./drizzle.config.js
COPY drizzle ./drizzle

ENV PORT=3000
EXPOSE 3000
CMD ["npm", "start"]
