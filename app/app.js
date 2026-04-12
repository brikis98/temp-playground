import express from "express";

const app = express();
app.set("view engine", "ejs");

app.get("/", async (req, res) => {
  res.render("hello");
});

export default app;
