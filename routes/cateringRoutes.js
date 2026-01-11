import express from "express";
import multer from "multer";
import { addCateringDetails, updateCateringDetails, getAllCatering, uploadCateringImage,
    deleteCateringImage, } 
from "../controllers/cateringController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

// add and update catering details
router.post("/add", addCateringDetails);
router.put("/update", updateCateringDetails);

//get Catering details
router.get("/all", getAllCatering);

// Images
router.post("/upload-image", upload.single("image"), uploadCateringImage);
router.delete("/delete-image", deleteCateringImage);

export default router;
