import express from "express";
import { registerUser } from "../controllers/userController.js";  // only registerUser no OTP verification
import { loginUser } from "../controllers/userController.js";   // only loginUser no OTP verification

const router = express.Router();

// Register route
router.post("/register", registerUser);
// Login route
router.post("/login", loginUser);

export default router;
