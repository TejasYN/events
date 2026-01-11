import Catering from "../models/Catering.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Catering
export const addCateringDetails = async (req, res) => {
  try {
    const {
      vendorId,
      cateringName,
      city,
      address,
      phone,
      maxPlates,
      minPlates,
      shortDescription,
      images,
      availableDates,
      unavailableDates,
      vegMeals,
      nonVegMeals,
      categories, // <-- ensure categories comes from body
    } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const catering = await Catering.create({
      vendorId,
      cateringName,
      city,
      address,
      phone,
      maxPlates,
      minPlates,
      shortDescription,
      images,
      categories, // use incoming categories
      availableDates,
      unavailableDates,
      vegMeals,
      nonVegMeals,
    });

    vendor.businessDetails = catering._id;
    vendor.vendorTypeDetails = "Catering";
    await vendor.save();

    res.status(201).json({ message: "Catering details added", catering });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Catering
export const updateCateringDetails = async (req, res) => {
  try {
    const { vendorId, ...updatedData } = req.body;

    let catering = await Catering.findOne({ vendorId });
    if (!catering) {
      catering = await Catering.create({ vendorId, ...updatedData });
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: catering._id,
        vendorTypeDetails: "Catering",
      });
      return res.status(201).json({ message: "Catering created", catering });
    }

    catering = await Catering.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    res.status(200).json({ message: "Catering updated successfully", catering });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Catering
export const getAllCatering = async (req, res) => {
  try {
    const caterings = await Catering.find().populate("vendorId");
    res.status(200).json(caterings);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Upload Catering Image
export const uploadCateringImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "caterings";

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

    try { fs.unlinkSync(req.file.path); } catch (_) {}

    let updatedCatering = null;
    if (vendorId) {
      updatedCatering = await Catering.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, catering: updatedCatering });
  } catch (error) {
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

// ✅ Delete Catering Image
export const deleteCateringImage = async (req, res) => {
  try {
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    const catering = await Catering.findOne({ vendorId });
    if (!catering) return res.status(404).json({ message: "Catering not found" });

    catering.images = catering.images.filter((img) => img !== imageUrl);
    await catering.save();

    try {
      const bucketName = process.env.MINIO_BUCKET || "caterings";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean);
      const objectName = segments[segments.length - 1];
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO:", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: catering.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
