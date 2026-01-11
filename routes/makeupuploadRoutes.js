import express from "express";
import multer from "multer";
import { uploadMakeupImage, deleteMakeupImage } from "../controllers/uploadController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Photography Images Upload/Delete
router.post("/", upload.single("file"), uploadMakeupImage);
router.delete("/:vendorId", deleteMakeupImage);

export default router;
