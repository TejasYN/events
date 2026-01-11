import express from "express";
import multer from "multer";
import { 
        addVenueDetails, updateVenueDetails, getAllVenues, uploadVenueImage, deleteVenueImage 
    } from "../controllers/venueController.js";

const router = express.Router();
const upload = multer({ dest: "uploads/" });

//add and update venue details
router.post("/add", addVenueDetails);
router.put("/update", updateVenueDetails);

//get venue details
router.get("/all", getAllVenues);

// Images
router.post("/upload-image", upload.single("image"), uploadVenueImage);
router.delete("/delete-image", deleteVenueImage);

export default router;
