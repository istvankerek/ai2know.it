# Frontend Dockerfile – Vite + React Router
# Multi-stage: dev + prod

# --- DEV ---
FROM node:20-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# --- BUILD ---
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- PROD ---
FROM caddy:2-alpine AS prod
COPY --from=build /app/dist /srv
EXPOSE 3000
