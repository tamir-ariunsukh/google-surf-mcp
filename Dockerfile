FROM node:22-bookworm-slim
WORKDIR /app
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium xvfb xauth && \
    rm -rf /var/lib/apt/lists/*

COPY . .
RUN npm ci --ignore-scripts && npm run build && npm prune --omit=dev
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "build/http-wrapper.js"]
