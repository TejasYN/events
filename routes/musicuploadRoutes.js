import express from "express";
import multer from "multer";
import { uploadMusicImage, deleteMusicImage } from "../controllers/uploadController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Photography Images Upload/Delete
router.post("/", upload.single("file"), uploadMusicImage);
router.delete("/:vendorId", deleteMusicImage);

export default router;
