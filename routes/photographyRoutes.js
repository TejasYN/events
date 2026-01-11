import express from "express";
import multer from "multer";
import { 
  addPhotographyDetails, 
  updatePhotographyDetails, 
  getAllPhotography,
} from "../controllers/photographyController.js";
import { uploadPhotographyImage, deletePhotographyImage } from "../controllers/uploadController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

// Business details
router.post("/add", addPhotographyDetails);
router.put("/update", updatePhotographyDetails);

//get Photography details
router.get("/all", getAllPhotography);

// Image upload/delete
router.post("/upload-image", upload.single("image"), uploadPhotographyImage);
router.delete("/delete-image/:vendorId", deletePhotographyImage);

export default router;
