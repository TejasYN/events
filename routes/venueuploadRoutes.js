import express from "express";
import multer from "multer";
import { uploadVenueImage, deleteVenueImage, } from "../controllers/uploadController.js";

const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Venue Images Upload/Delete route
router.post("/", upload.single("file"), uploadVenueImage);
router.delete("/:vendorId", deleteVenueImage);

export default router;
