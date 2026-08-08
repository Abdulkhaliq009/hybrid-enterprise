const request = require("supertest");
const { createApp } = require("../server");

// Mock SQL client so tests run without a database
const mockSql = {
  connect: jest.fn().mockResolvedValue({}),
  query: jest.fn(),
};
mockSql.query.mockResolvedValue({
  recordset: [{ id: 1, name: "Croissant", price: 2.5 }],
});

describe("API", () => {
  const app = createApp({ sql: mockSql });

  test("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
  });

  test("GET /products returns data from SQL", async () => {
    const res = await request(app).get("/products");
    expect(res.status).toBe(200);
    expect(res.body.count).toBe(1);
    expect(res.body.data[0].name).toBe("Croissant");
  });

  test("POST /products validates body", async () => {
    const res = await request(app).post("/products").send({});
    expect(res.status).toBe(400);
  });
});
