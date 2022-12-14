# Build stage
FROM node:18-alpine3.15 AS builder
ENV NODE_ENV production

WORKDIR /app
# Cache and Install dependencies
COPY package.json .
RUN npm install
# Copy app files
COPY . .
# Build the app
RUN npm run build

# Test stage
FROM builder as test
RUN npm ci
COPY . .
RUN npm run test

# Bundle static assets with nginx
FROM nginx:1.23.1 AS production
# Copy built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html
# Add your nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]