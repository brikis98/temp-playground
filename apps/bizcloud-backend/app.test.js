import request from "supertest";
import app from "./app.js";

describe("Test the backend app", () => {
  test("Get / should return metrics", async () => {
    const response = await request(app).get("/");
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({
      synergy: "97.3%",
      mean_time_to_powerpoint: "4 min",
      maturity: "Bronze+",
    });
  });

  test("Get /health should return healthy status", async () => {
    const response = await request(app).get("/health");
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ ok: true });
  });
});
