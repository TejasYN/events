import Decorations from "../models/Decorations.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Decoration Details
export const addDecorationDetails = async (req, res) => {
  try {
    const { vendorId, decorationName, city, address, phone, categories, experience, shortDescription, images } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const decoration = await Decorations.create({
      vendorId,
      decorationName,
      city,
      address,
      phone,
      categories,
      experience,
      shortDescription,
      images,
    });

    vendor.businessDetails = decoration._id;
    vendor.vendorTypeDetails = "Decorations";
    await vendor.save();

    res.status(201).json({ message: "Decoration details added", decoration });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Decoration Details
export const updateDecorationDetails = async (req, res) => {
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
    const requiredFields = ["decorationName", "city"];
    for (const field of requiredFields) {
      if (!updatedData[field]) {
        return res.status(400).json({ message: `${field} is required` });
      }
    }

    let decoration = await Decorations.findOne({ vendorId });
    if (!decoration) {
      try {
        decoration = await Decorations.create({ vendorId, ...updatedData });
      } catch (err) {
        return res.status(400).json({ message: "Validation failed", error: err.message });
      }
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: decoration._id,
        vendorTypeDetails: "Decorations",
      });
      return res.status(201).json({ message: "Decorations created", decoration });
    }

    decoration = await Decorations.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    if (!decoration) {
      return res.status(404).json({ message: "Decorations not found" });
    }
    res.status(200).json({ message: "Decorations updated successfully", decoration });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Decorations
export const getAllDecorations = async (req, res) => {
  try {
    const decorations = await Decorations.find().populate("vendorId");
    res.status(200).json(decorations);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Upload Decoration Image
export const uploadDecorationImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "decorations";

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
    let updatedDecorations = null;
    if (vendorId) {
      updatedDecorations = await Decorations.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, Decorations: updatedDecorations });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

// ✅ Delete Decoration Image
export const deleteDecorationImage = async (req, res) => {
  try {
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    const Decorations = await Decorations.findOne({ vendorId });
    if (!Decorations) {
      return res.status(404).json({ message: "Decorations not found" });
    }

    // Remove image from MongoDB
    Decorations.images = Decorations.images.filter((img) => img !== imageUrl);
    await Decorations.save();

    // Delete from MinIO
    try {
      const bucketName = process.env.MINIO_BUCKET || "decorations";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean);
      const objectName = segments[segments.length - 1];
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO:", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: Decorations.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
