import { Hono } from "hono"
import { cors } from "hono/cors"
import { bearerAuth } from "hono/bearer-auth"
import { logger } from "hono/logger"

import { completionRoutes } from "./routes/chat-completions/route"
import { embeddingRoutes } from "./routes/embeddings/route"
import { messageRoutes } from "./routes/messages/route"
import { modelRoutes } from "./routes/models/route"
import { tokenRoute } from "./routes/token/route"
import { usageRoute } from "./routes/usage/route"

export const server = new Hono()

server.use(logger())
server.use(cors())

// Health check endpoint (no auth required)
server.get("/", (c) => c.text("Server running"))

// API key authentication middleware
const apiKey = process.env.API_KEY
if (apiKey) {
  server.use("/*", async (c, next) => {
    // Skip auth for health check
    if (c.req.path === "/") return next()

    // Check x-api-key header first
    const xApiKey = c.req.header("x-api-key")
    if (xApiKey === apiKey) return next()

    // Fall back to Bearer token auth
    const auth = bearerAuth({ token: apiKey })
    return auth(c, next)
  })
}

server.route("/chat/completions", completionRoutes)
server.route("/models", modelRoutes)
server.route("/embeddings", embeddingRoutes)
server.route("/usage", usageRoute)
server.route("/token", tokenRoute)

// Compatibility with tools that expect v1/ prefix
server.route("/v1/chat/completions", completionRoutes)
server.route("/v1/models", modelRoutes)
server.route("/v1/embeddings", embeddingRoutes)

// Anthropic compatible endpoints
server.route("/v1/messages", messageRoutes)
