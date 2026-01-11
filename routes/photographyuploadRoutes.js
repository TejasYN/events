import express from "express";
import multer from "multer";
import { uploadPhotographyImage, deletePhotographyImage } from "../controllers/uploadController.js";

const router = express.Router();
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Photography Images Upload/Delete
router.post("/", upload.single("file"), uploadPhotographyImage);
router.delete("/:vendorId", deletePhotographyImage);

export default router;
