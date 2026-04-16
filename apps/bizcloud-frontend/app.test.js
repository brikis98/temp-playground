import request from "supertest";
import { jest } from "@jest/globals";
import app from "./app.js";

describe("Test the frontend app", () => {
  afterEach(() => {
    delete global.fetch;
  });

  test("Get / should render data from the backend", async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({
        synergy: "97.3%",
        mean_time_to_powerpoint: "4 min",
        maturity: "Bronze+",
      }),
    });

    const response = await request(app).get("/");
    expect(response.statusCode).toBe(200);
    expect(response.text).toContain("97.3%");
    expect(response.text).toContain("4 min");
    expect(response.text).toContain("Bronze+");
  });

  test("Get / should render fallback data when backend is unavailable", async () => {
    global.fetch = jest.fn().mockRejectedValue(new Error("backend unavailable"));

    const response = await request(app).get("/");
    expect(response.statusCode).toBe(200);
    expect(response.text).toContain("N/A");
    expect(response.text).toContain("Unknown");
  });

  test("Get /health should return healthy status", async () => {
    const response = await request(app).get("/health");
    expect(response.statusCode).toBe(200);
    expect(response.body).toEqual({ ok: true });
  });
});
