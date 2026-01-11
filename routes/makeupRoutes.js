import express from "express";
import multer from "multer";
import { 
  addMakeupDetails, 
  updateMakeupDetails,  
  getAllMakeup
} from "../controllers/makeupController.js";
import { uploadMakeupImage, deleteMakeupImage } from "../controllers/uploadController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

// Business details
router.post("/add", addMakeupDetails);
router.put("/update", updateMakeupDetails);

//get makeup details
router.get("/all", getAllMakeup);

// Image upload/delete
router.post("/upload-image", upload.single("image"), uploadMakeupImage);
router.delete("/delete-image/:vendorId", deleteMakeupImage);

export default router;
