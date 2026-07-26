FROM node:22-bookworm-slim
WORKDIR /app
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium xvfb xauth && \
    rm -rf /var/lib/apt/lists/*

# Copy ALL source files needed for build
COPY package.json package-lock.json tsconfig.json tsconfig.scripts.json ./
COPY scripts/ ./scripts/
COPY src/ ./src/
COPY server.json ./

RUN npm ci --ignore-scripts && \
    npm run build && \
    npm prune --omit=dev

RUN xvfb-run -a node build/bootstrap-auto.js
ENV NODE_ENV=production
COPY README.md LICENSE ./
CMD ["node", "build/index.js"]
