import express from "express";
import multer from "multer";
import { 
  addDecorationDetails, 
  updateDecorationDetails, 
  getAllDecorations
} from "../controllers/decorationController.js";
import { uploadDecorationImage, deleteDecorationImage } from "../controllers/uploadController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

// Business details
router.post("/add", addDecorationDetails);
router.put("/update", updateDecorationDetails);

//get Photography details
router.get("/all", getAllDecorations);

// Image upload/delete
router.post("/upload-image", upload.single("image"), uploadDecorationImage);
router.delete("/delete-image/:vendorId", deleteDecorationImage);

export default router;
