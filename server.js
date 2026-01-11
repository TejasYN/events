import express from "express";
import dotenv from "dotenv";
import cors from "cors";

import connectDB from "./config/db.js";
import userRoutes from "./routes/userRoutes.js";
import vendorRoutes from "./routes/vendorRoutes.js";

import venueRoutes from "./routes/venueRoutes.js";
import cateringRoutes from "./routes/cateringRoutes.js";
import photographyRoutes from "./routes/photographyRoutes.js";
import decorationRoutes from "./routes/decorationRoutes.js";
import musicRoutes from "./routes/musicRoutes.js";
import makeupRoutes from "./routes/makeupRoutes.js";

import venueuploadRoutes from "./routes/venueuploadRoutes.js";
import cateringuploadRoutes from "./routes/cateringuploadRoutes.js";
import photographyuploadRoutes from "./routes/photographyuploadRoutes.js";
import decorationuploadRoutes from "./routes/decorationuploadRoutes.js";
import musicuploadRoutes from "./routes/musicuploadRoutes.js";
import makeupuploadRoutes from "./routes/makeupuploadRoutes.js";

dotenv.config();
connectDB();

const app = express();

// ✅ Middleware
app.use(cors());
app.use(express.json());

// ✅ Routes
app.use("/api/users", userRoutes);
app.use("/api/vendors", vendorRoutes);

app.use("/api/venues", venueRoutes);
app.use("/api/caterings", cateringRoutes);
app.use("/api/photography", photographyRoutes);
app.use("/api/decoration", decorationRoutes);
app.use("/api/music", musicRoutes);
app.use("/api/makeup", makeupRoutes);

app.use("/api/upload/venues", venueuploadRoutes);
app.use("/api/upload/catering", cateringuploadRoutes);
app.use("/api/upload/photography", photographyuploadRoutes);
app.use("/api/upload/decoration", decorationuploadRoutes);
app.use("/api/upload/music", musicuploadRoutes);
app.use("/api/upload/makeup", makeupuploadRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
