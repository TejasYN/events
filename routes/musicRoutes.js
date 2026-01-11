import express from "express";
import multer from "multer";
import { 
  addMusicDetails, 
  updateMusicDetails,  
  getAllMusic
} from "../controllers/musicController.js";
import { uploadMusicImage, deleteMusicImage } from "../controllers/uploadController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

// add and update music details
router.post("/add", addMusicDetails);
router.put("/update", updateMusicDetails);

//get music details
router.get("/all", getAllMusic);

// Image
router.post("/upload-image", upload.single("image"), uploadMusicImage);
router.delete("/delete-image/:vendorId", deleteMusicImage);

export default router;
