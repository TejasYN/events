import express from "express";
import { registerVendor, getVendors, loginVendor } from "../controllers/vendorController.js";

const router = express.Router();

router.post("/register", registerVendor);
router.get("/", getVendors);
router.post("/login", loginVendor);

export default router;
