import Makeup from "../models/Makeup.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Makeup Details
export const addMakeupDetails = async (req, res) => {
  try {
    const { vendorId, makeupName, city, address, phone, categories, experience, shortDescription, images } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const makeup = await Makeup.create({
      vendorId,
      makeupName,
      city,
      address,
      phone,
      categories,
      experience,
      shortDescription,
      images,
    });

    vendor.businessDetails = makeup._id;
    vendor.vendorTypeDetails = "Makeup";
    await vendor.save();

    res.status(201).json({ message: "Makeup details added", makeup });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Makeup Details
export const updateMakeupDetails = async (req, res) => {
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
    const requiredFields = ["makeupName", "city"];
    for (const field of requiredFields) {
      if (!updatedData[field]) {
        return res.status(400).json({ message: `${field} is required` });
      }
    }

    let makeup = await Makeup.findOne({ vendorId });
    if (!makeup) {
      try {
        makeup = await Makeup.create({ vendorId, ...updatedData });
      } catch (err) {
        return res.status(400).json({ message: "Validation failed", error: err.message });
      }
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: makeup._id,
        vendorTypeDetails: "Makeup",
      });
      return res.status(201).json({ message: "Makeup created", makeup });
    }

    makeup = await Makeup.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    if (!makeup) {
      return res.status(404).json({ message: "Makeup not found" });
    }
    res.status(200).json({ message: "Makeup updated successfully", makeup });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Makeup
export const getAllMakeup = async (req, res) => {
  try {
    const makeup = await Makeup.find().populate("vendorId");
    res.status(200).json(makeup);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Upload Makeup Image
export const uploadMakeupImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "makeup";

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
    let updatedMakeup = null;
    if (vendorId) {
      updatedMakeup = await Makeup.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, Makeup: updatedMakeup });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

// ✅ Delete Makeup Image
export const deleteMakeupImage = async (req, res) => {
  try {
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    const Makeup = await Makeup.findOne({ vendorId });
    if (!Makeup) {
      return res.status(404).json({ message: "Makeup not found" });
    }

    // Remove image from MongoDB
    Makeup.images = Makeup.images.filter((img) => img !== imageUrl);
    await Makeup.save();

    // Delete from MinIO
    try {
      const bucketName = process.env.MINIO_BUCKET || "makeup";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean);
      const objectName = segments[segments.length - 1];
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO:", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: Makeup.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
