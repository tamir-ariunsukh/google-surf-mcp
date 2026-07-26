import http from 'node:http';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js';
import { searchTool, searchParallelTool, extractTool, searchExtractTool, healthTool, initDeps, type PoolHandle } from './agent.js';
import { PKG_NAME, VERSION } from './version.js';

const PORT = parseInt(process.env.PORT || '3000', 10);
const NAME = PKG_NAME;

const server = new McpServer({ name: NAME, version: VERSION });
server.server.onerror = (e: unknown) => console.error('[mcp]', e);

// Register tools (same as index.ts)
const deps: Record<string, unknown> = {};
healthTool(server);
initDeps({ pool: {} as PoolHandle });
searchTool(server);
searchParallelTool(server);
extractTool(server);
searchExtractTool(server);

const httpServer = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('OK');
    return;
  }

  if (req.url === '/sse') {
    const transport = new SSEServerTransport('/messages', res);
    server.server.connect(transport);
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`<h1>🚀 ${NAME} v${VERSION}</h1><p>SSE: <a href="/sse">/sse</a> | <a href="/health">/health</a></p>`);
    return;
  }

  res.writeHead(404);
  res.end('Not Found');
});

httpServer.listen(PORT, () => {
  console.log(`🚀 ${NAME} HTTP server on port ${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health`);
  console.log(`   SSE:    http://localhost:${PORT}/sse`);
});
