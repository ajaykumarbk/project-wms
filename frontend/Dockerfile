# FROM node:18-alpine as builder

# WORKDIR /app
# COPY package*.json ./
# RUN npm install

# COPY . .
# RUN npm run build

# FROM nginx:alpine

# # Set Cloud Run port variable
# ENV PORT=8080

# # Add envsubst to expand ${PORT}
# RUN apk add --no-cache gettext

# # Copy nginx config
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Expand ${PORT} in nginx.conf
# RUN envsubst '$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp \
#     && mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# # Copy built frontend
# COPY --from=builder /app/dist /usr/share/nginx/html

# EXPOSE 8080

# CMD ["nginx", "-g", "daemon off;"]

# --- Stage 1: Build Vite App ---
# FROM node:18-alpine AS builder
# WORKDIR /app

# COPY package*.json ./
# RUN npm install

# COPY . .
# RUN npm run build

# # --- Stage 2: Serve with NGINX ---
# FROM nginx:alpine

# # Expose port 8080
# EXPOSE 8080

# # Replace default NGINX config
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Copy build output
# COPY --from=builder /app/dist /usr/share/nginx/html

# CMD ["nginx", "-g", "daemon off;"]

# Stage 1: Build the Vite/React app
FROM node:18-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps   # --legacy-peer-deps helps with some Vite/React deps

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Serve with NGINX on port 80
FROM nginx:alpine

# Copy custom NGINX config (SPA-friendly)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose the port Kubernetes expects
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]