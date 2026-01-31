# ==============================================================================
# Phase IV - Todo Chatbot Frontend Dockerfile
# Next.js application with multi-stage build for optimized image size
# ==============================================================================

# Stage 1: Dependencies - Install node modules
FROM node:20-alpine AS deps

# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies (including devDependencies for build)
RUN npm ci

# ==============================================================================
# Stage 2: Builder - Build the application
# ==============================================================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source code
COPY . .

# Set build-time environment variables
ARG NEXT_PUBLIC_API_URL=http://todo-backend-svc:8000
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}

# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN npm run build

# ==============================================================================
# Stage 3: Runner - Production image
# ==============================================================================
FROM node:20-alpine AS runner

# Labels
LABEL maintainer="Claude Code" \
      description="Todo Chatbot Next.js Frontend" \
      version="1.0.0" \
      org.opencontainers.image.source="phase-4-kubernetes-deployment"

WORKDIR /app

# Set production environment
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME="0.0.0.0"

# Create non-root user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy necessary files from builder
# Automatically leverage output traces to reduce image size
COPY --from=builder /app/public ./public

# Set correct permissions for prerender cache
RUN mkdir .next && chown nextjs:nodejs .next

# Copy standalone build output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Run the application
CMD ["node", "server.js"]
