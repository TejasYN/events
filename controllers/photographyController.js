import Photography from "../models/Photography.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Photography Details
export const addPhotographyDetails = async (req, res) => {
  try {
    const { vendorId, studioName, city, address, phone, categories, experience, shortDescription, images } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const photography = await Photography.create({
      vendorId,
      studioName,
      city,
      address,
      phone,
      categories,
      experience,
      shortDescription,
      images,
    });

    vendor.businessDetails = photography._id;
    vendor.vendorTypeDetails = "Photography";
    await vendor.save();

    res.status(201).json({ message: "Photography details added", photography });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Photography Details
export const updatePhotographyDetails = async (req, res) => {
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
    const requiredFields = ["studioName", "city"];
    for (const field of requiredFields) {
      if (!updatedData[field]) {
        return res.status(400).json({ message: `${field} is required` });
      }
    }

    let photography = await Photography.findOne({ vendorId });
    if (!photography) {
      try {
        photography = await Photography.create({ vendorId, ...updatedData });
      } catch (err) {
        return res.status(400).json({ message: "Validation failed", error: err.message });
      }
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: photography._id,
        vendorTypeDetails: "Photography",
      });
      return res.status(201).json({ message: "Photography created", photography });
    }

    photography = await Photography.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    if (!photography) {
      return res.status(404).json({ message: "Photography not found" });
    }
    res.status(200).json({ message: "Photography updated successfully", photography });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Photography
export const getAllPhotography = async (req, res) => {
  try {
    const photographies = await Photography.find().populate("vendorId");
    res.status(200).json(photographies);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Upload Photography Image
export const uploadPhotographyImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "photography";

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
    let updatedPhotography = null;
    if (vendorId) {
      updatedPhotography = await Photography.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, photography: updatedPhotography });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

// ✅ Delete Photography Image
export const deletePhotographyImage = async (req, res) => {
  try {
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    const photography = await Photography.findOne({ vendorId });
    if (!photography) {
      return res.status(404).json({ message: "Photography not found" });
    }

    // Remove image from MongoDB
    photography.images = photography.images.filter((img) => img !== imageUrl);
    await photography.save();

    // Delete from MinIO
    try {
      const bucketName = process.env.MINIO_BUCKET || "photography";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean);
      const objectName = segments[segments.length - 1];
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO:", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: photography.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
