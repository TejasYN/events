import express from "express";
import multer from "multer";
import { uploadCateringImage, deleteCateringImage } from "../controllers/uploadController.js";

const router = express.Router();

const storage = multer.memoryStorage();
const upload = multer({ storage });

// Catering Images Upload/Delete route
router.post("/", upload.single("file"), uploadCateringImage);
router.delete("/:vendorId", deleteCateringImage);

export default router;
