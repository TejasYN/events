import Music from "../models/Music.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Music Details
export const addMusicDetails = async (req, res) => {
  try {
    const { vendorId, musicName, city, address, phone, categories, experience, shortDescription, images } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const music = await Music.create({
      vendorId,
      musicName,
      city,
      address,
      phone,
      categories,
      experience,
      shortDescription,
      images,
    });

    vendor.businessDetails = music._id;
    vendor.vendorTypeDetails = "Music";
    await vendor.save();

    res.status(201).json({ message: "Music details added", music });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Music Details
export const updateMusicDetails = async (req, res) => {
  try {
    let { vendorId, ...updatedData } = req.body;
    if (!vendorId) {
      return res.status(400).json({ message: "vendorId is required" });
    }
    // Cast vendorId to ObjectId
    try {
      vendorId = new mongoose.Types.ObjectId(vendorId);
    } catch (e) {
      return res.status(400).json({ message: "Invalid vendorId format" });
    }

    // Validate required fields for creation
    const requiredFields = ["musicName", "city"];
    for (const field of requiredFields) {
      if (!updatedData[field]) {
        return res.status(400).json({ message: `${field} is required` });
      }
    }

    let music = await Music.findOne({ vendorId });
    if (!music) {
      try {
        music = await Music.create({ vendorId, ...updatedData });
      } catch (err) {
        return res.status(400).json({ message: "Validation failed", error: err.message });
      }
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: music._id,
        vendorTypeDetails: "Music",
      });
      return res.status(201).json({ message: "Music created", music });
    }

    music = await Music.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    if (!music) {
      return res.status(404).json({ message: "Music not found" });
    }
    res.status(200).json({ message: "Music updated successfully", music });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Music
export const getAllMusic = async (req, res) => {
  try {
    const music = await Music.find().populate("vendorId");
    res.status(200).json(music);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Upload Music Image
export const uploadMusicImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "music";

    // Ensure bucket exists
    const exists = await minioClient.bucketExists(bucketName).catch(() => false);
    if (!exists) {
      await minioClient.makeBucket(bucketName, "us-east-1");
    }

    const baseName = req.file.originalname || "upload";
    const prefix = vendorId ? `${vendorId}_` : "";
    const fileName = `${prefix}${Date.now()}_${baseName}`;

    await minioClient.fPutObject(bucketName, fileName, req.file.path);

    const endpoint = process.env.MINIO_ENDPOINT || "10.13.29.36";
    const port = process.env.MINIO_PORT || 9000;
    const fileUrl = `http://${endpoint}:${port}/${bucketName}/${fileName}`;

    // Delete temp file
    try { fs.unlinkSync(req.file.path); } catch (_) {}

    // Update MongoDB if vendorId is known
    let updatedMusic = null;
    if (vendorId) {
      updatedMusic = await Music.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, Music: updatedMusic });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

// ✅ Delete Music Image
export const deleteMusicImage = async (req, res) => {
  try {
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    const Music = await Music.findOne({ vendorId });
    if (!Music) {
      return res.status(404).json({ message: "Music not found" });
    }

    // Remove image from MongoDB
    Music.images = Music.images.filter((img) => img !== imageUrl);
    await Music.save();

    // Delete from MinIO
    try {
      const bucketName = process.env.MINIO_BUCKET || "music";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean);
      const objectName = segments[segments.length - 1];
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO:", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: Music.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
