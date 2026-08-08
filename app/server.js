const express = require("express");
const sql = require("mssql");

function dbConfig() {
  return {
    server: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || "1433"),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: { encrypt: false, trustServerCertificate: true },
    pool: { max: 10, min: 0, idleTimeoutMillis: 30000 },
  };
}

function createApp(deps = {}) {
  const sqlClient = deps.sql || sql;
  const app = express();
  app.use(express.json());

  app.get("/health", (req, res) => {
    res.json({ status: "ok", timestamp: new Date().toISOString(), pod: process.env.HOSTNAME || "local" });
  });

  app.get("/ready", async (req, res) => {
    try {
      await sqlClient.connect(dbConfig());
      res.json({ status: "ready", db: "connected" });
    } catch (err) {
      res.status(503).json({ status: "not-ready", error: err.message });
    }
  });

  app.get("/products", async (req, res) => {
    try {
      await sqlClient.connect(dbConfig());
      const result = await sqlClient.query("SELECT * FROM products ORDER BY id");
      res.json({ source: "on-prem SQL Server", count: result.recordset.length, data: result.recordset });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  app.post("/products", async (req, res) => {
    const { name, price } = req.body || {};
    if (!name || price === undefined) {
      return res.status(400).json({ error: "name and price required" });
    }
    try {
      await sqlClient.connect(dbConfig());
      const result = await sqlClient.query`INSERT INTO products (name, price) OUTPUT INSERTED.id VALUES (${name}, ${price})`;
      res.status(201).json({ id: result.recordset[0].id, name, price });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });

  return app;
}

module.exports = { createApp, dbConfig };
