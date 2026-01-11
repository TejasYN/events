import User from "../models/User.js";
import nodemailer from "nodemailer";
import dotenv from "dotenv";


// ✅ Register User without OTP (temporary)


// ✅ Register User
export const registerUser = async (req, res) => {
  try {
    const { username, email, birthdate, mobile, city } = req.body;

    if (!username || !email || !birthdate || !mobile || !city) {
      return res.status(400).json({ message: "All fields are required" });
    }

    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // ✅ Convert birthdate to Date
    const parsedDate = new Date(birthdate);

    user = new User({
      username,
      email,
      birthdate: parsedDate,
      mobile: String(mobile), // ✅ ensure string
      city,
    });

    await user.save();

    res.status(200).json({
      message: "User registered successfully",
      user: {
        username: user.username,
        email: user.email,
        mobile: user.mobile,
        city: user.city,
        birthdate: user.birthdate.toISOString(), // ✅ send as string
      },
    });
  } catch (error) {
    console.error("❌ Error in registerUser:", error.message);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Login with email or mobile
export const loginUser = async (req, res) => {
  try {
    const { identifier } = req.body;

    if (!identifier) {
      return res.status(400).json({ message: "Email or Mobile is required" });
    }

    let user;
    if (identifier.includes("@")) {
      user = await User.findOne({ email: identifier });
    } else {
      user = await User.findOne({ mobile: identifier });
    }

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      message: "Login successful",
      user: {
        username: user.username,
        email: user.email,
        mobile: user.mobile,
        city: user.city,
        birthdate: user.birthdate.toISOString(), // ✅ send as string
      },
    });
  } catch (error) {
    console.error("❌ Error in loginUser:", error.message);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
