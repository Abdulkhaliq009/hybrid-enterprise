FROM node:20-alpine AS base

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY app.js server.js ./

ENV PORT=3000 NODE_ENV=production
EXPOSE 3000

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
