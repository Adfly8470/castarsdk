const express = require("express");
const cors = require("cors");
const userRoutes = require("./routes/user");
const eventsRoutes = require("./routes/events");
const communityRoutes = require("./routes/community");
const notificationsRoutes = require("./routes/notifications");
const categoriesRoutes = require("./routes/categories");
const paymentRoutes = require("./routes/payments");
const downloadRoutes = require('./routes/download');
// const settingsRoutes = require("./routes/settings");

const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/user", userRoutes);
app.use("/api/events", eventsRoutes);
app.use("/api/community", communityRoutes);
app.use("/api/notifications", notificationsRoutes);
app.use("/api/categories", categoriesRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api", downloadRoutes);
// app.use("/api/settings", settingsRoutes);

const port = parseInt(process.env.PORT) || process.argv[3] || 8080;
app.listen(port, () => {
    console.log(`Listening on http://localhost:${port}`);
});
