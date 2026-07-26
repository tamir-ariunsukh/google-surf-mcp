FROM node:22-bookworm-slim
WORKDIR /app
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
ENV PORT=3000

RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium xvfb xauth && \
    rm -rf /var/lib/apt/lists/*

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json package-lock.json* ./
RUN pnpm import 2>/dev/null || true; pnpm install --frozen-lockfile --ignore-scripts 2>/dev/null || pnpm install --ignore-scripts
COPY . .
RUN pnpm run build && pnpm prune --prod

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "build/index.js"]
