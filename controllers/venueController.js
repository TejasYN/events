import Venue from "../models/Venues.js";
import Vendor from "../models/Vendor.js";
import minioClient from "../config/minioClient.js";
import fs from "fs";
import mongoose from "mongoose";

// ✅ Add Venue Details
export const addVenueDetails = async (req, res) => {
  try {
    const { vendorId, venueName, city, address, phone, price, seats, shortDescription, images } = req.body;

    const vendor = await Vendor.findById(vendorId);
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    const venue = await Venue.create({
      vendorId,
      venueName,
      city,
      address,
      phone,
      price,
      seats,
      shortDescription,
      images,
      subcategory,
    });

    vendor.businessDetails = venue._id;
    vendor.vendorTypeDetails = "Venue";
    await vendor.save();

    res.status(201).json({ message: "Venue details added", venue });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Update Venue Details
export const updateVenueDetails = async (req, res) => {
  try {
    const { vendorId, ...updatedData } = req.body;

    let venue = await Venue.findOne({ vendorId });
    if (!venue) {
      venue = await Venue.create({ vendorId, ...updatedData });
      await Vendor.findByIdAndUpdate(vendorId, {
        businessDetails: venue._id,
        vendorTypeDetails: "Venue",
      });
      return res.status(201).json({ message: "Venue created", venue });
    }

    venue = await Venue.findOneAndUpdate({ vendorId }, updatedData, { new: true });
    res.status(200).json({ message: "Venue updated successfully", venue });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Venues
export const getAllVenues = async (req, res) => {
  try {
    const venues = await Venue.find().populate("vendorId");
    res.status(200).json(venues);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};


// ✅ Upload Venue Image
export const uploadVenueImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const vendorId = req.body.vendorId || req.query.vendorId || null;
    const bucketName = process.env.MINIO_BUCKET || "venues";

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

    // Delete temp file (best-effort)
    try { fs.unlinkSync(req.file.path); } catch (_) {}

    // Optionally update DB if vendorId is known
    let updatedVenue = null;
    if (vendorId) {
      updatedVenue = await Venue.findOneAndUpdate(
        { vendorId },
        { $push: { images: fileUrl } },
        { new: true }
      ).catch(() => null);
    }

    res.status(200).json({ message: "Image uploaded", url: fileUrl, venue: updatedVenue });
  } catch (error) {
    console.error("Upload error:", error);
    res.status(500).json({ message: "Upload failed", error: error.message });
  }
};

export const deleteVenueImage = async (req, res) => {
  try {
    // Accept vendorId and imageUrl from body, params, or query to support different clients
    const vendorId = req.body.vendorId || req.params.vendorId || req.query.vendorId || null;
    const imageUrl = req.body.imageUrl || req.query.imageUrl || null;

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }
    // Validate vendorId shape to avoid ObjectId cast errors
    const vStr = String(vendorId).trim().toLowerCase();
    if (vStr === "null" || vStr === "undefined" || !mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({ message: "Invalid vendorId" });
    }

    // Find venue linked to vendor
    const venue = await Venue.findOne({ vendorId });
    if (!venue) {
      return res.status(404).json({ message: "Venue not found" });
    }

    // Remove image from MongoDB
    venue.images = venue.images.filter((img) => img !== imageUrl);
    await venue.save();

    // ✅ Delete from MinIO (best-effort)
    try {
      const bucketName = process.env.MINIO_BUCKET || "venues";
      const u = new URL(imageUrl);
      const segments = u.pathname.split("/").filter(Boolean); // ["venues", "<file>"]
      const objectName = segments[segments.length - 1]; // "<file>"
      await minioClient.removeObject(bucketName, objectName);
    } catch (err) {
      console.warn("⚠️ Failed to delete from MinIO (maybe already deleted or wrong URL):", err.message);
    }

    res.status(200).json({ message: "Image deleted successfully", images: venue.images });
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
