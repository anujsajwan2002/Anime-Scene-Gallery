# ---------- Build stage ----------
FROM node:18-alpine AS build
WORKDIR /app

# install deps (use npm ci if package-lock.json exists)
COPY package*.json ./
RUN npm ci --silent || npm install --silent

# copy rest and build
COPY . .
RUN npm run build

# ---------- Production stage ----------
FROM nginx:stable-alpine AS production
# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built static files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx config to enable SPA fallback (see next step)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
