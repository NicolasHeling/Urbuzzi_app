# Build stage
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install --omit=dev
COPY --from=builder /usr/src/app/dist ./dist
CMD ["sh", "-c", "node ./node_modules/typeorm/cli.js migration:run -d dist/data-source.js && node dist/main"]
