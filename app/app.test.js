import request from "supertest";
import app from "./app.js";

describe("Test the app", () => {
  test("Get / should return Hello, World!", async () => {
    const response = await request(app).get("/");
    expect(response.statusCode).toBe(200);
    expect(response.text).toContain("Hello, World!");
  });
});
