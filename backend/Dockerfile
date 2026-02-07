# Build

FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm install --production

# Copy source
FROM node:18-alpine
WORKDIR /app

COPY --from=base /app/node_modules ./node_modules
COPY . .

ENV PORT=5000
EXPOSE 5000

CMD ["node", "server.js"]

