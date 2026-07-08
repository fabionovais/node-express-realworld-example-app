FROM node:18-slim AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/*

COPY package*.json ./

RUN npm ci

COPY . .

RUN ./node_modules/.bin/prisma generate --schema=src/prisma/schema.prisma

RUN npx nx build api

RUN npm prune --omit=dev


FROM node:18-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

COPY --from=builder /app/dist/api ./api
COPY --from=builder /app/node_modules ./api/node_modules

WORKDIR /app/api

EXPOSE 3000

CMD ["node", "main.js"]