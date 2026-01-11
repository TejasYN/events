import express from "express";
import multer from "multer";
import { uploadDecorationImage, deleteDecorationImage } from "../controllers/uploadController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Photography Images Upload/Delete
router.post("/", upload.single("file"), uploadDecorationImage);
router.delete("/:vendorId", deleteDecorationImage);

export default router;
