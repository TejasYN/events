import { Client as MinioClient } from "minio";
import Venue from "../models/Venues.js";
import Catering from "../models/Catering.js";
import Photography from "../models/Photography.js";
import Decorations from "../models/Decorations.js";
import Music from "../models/Music.js";
import Makeup from "../models/Makeup.js";

// MinIO client
const minioClient = new MinioClient({
  endPoint: process.env.MINIO_ENDPOINT || "10.13.29.36",
  port: parseInt(process.env.MINIO_PORT) || 9000,
  useSSL: false,
  accessKey: process.env.MINIO_ROOT_USER || "minioadmin",
  secretKey: process.env.MINIO_ROOT_PASSWORD || "minioadmin",
});

// ✅ Upload Venue Image
export const uploadVenueImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No file uploaded" });
    }

    const { vendorId } = req.body;
  const bucket = process.env.MINIO_VENUE_BUCKET || "venues";

    // Ensure bucket exists
    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) {
      await minioClient.makeBucket(bucket, "us-east-1");
    }

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    // Save to DB
    const updatedVenue = await Venue.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    return res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      venue: updatedVenue,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Venue Image
export const deleteVenueImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query; // ⬅️ now from query instead of body
  const bucket = process.env.MINIO_VENUE_BUCKET || "venues";

    console.log("Delete request params:", req.params);
    console.log("Delete request query:", req.query);

    if (!vendorId || !imageUrl) {
      return res.status(400).json({ message: "vendorId and imageUrl are required" });
    }

    // Extract filename
    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    // Remove from MinIO
    await minioClient.removeObject(bucket, fileName);

    // Remove from DB
    const updatedVenue = await Venue.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      venue: updatedVenue,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};

// ✅ Upload Catering Image
export const uploadCateringImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const { vendorId } = req.body;
  const bucket = process.env.MINIO_CATERING_BUCKET || "catering";

    // Ensure bucket exists
    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) await minioClient.makeBucket(bucket, "us-east-1");

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    // Save to DB
    const updatedCatering = await Catering.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      catering: updatedCatering,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Catering Image
export const deleteCateringImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query;
  const bucket = process.env.MINIO_CATERING_BUCKET || "catering";

    if (!vendorId || !imageUrl)
      return res.status(400).json({ message: "vendorId and imageUrl are required" });

    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    await minioClient.removeObject(bucket, fileName);

    const updatedCatering = await Catering.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      catering: updatedCatering,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};

// ✅ Upload Photography Image
export const uploadPhotographyImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const { vendorId } = req.body;
    const bucket = process.env.MINIO_PHOTOGRAPHY_BUCKET || "photography";

    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) await minioClient.makeBucket(bucket, "us-east-1");

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    const updatedPhotography = await Photography.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      photography: updatedPhotography,
    });
  } catch (err) {
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Photography Image
export const deletePhotographyImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query;
    const bucket = process.env.MINIO_PHOTOGRAPHY_BUCKET || "photography";

    if (!vendorId || !imageUrl)
      return res.status(400).json({ message: "vendorId and imageUrl are required" });

    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    await minioClient.removeObject(bucket, fileName);

    const updatedPhotography = await Photography.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      photography: updatedPhotography,
    });
  } catch (err) {
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};

// ✅ Upload Decoration Image
export const uploadDecorationImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const { vendorId } = req.body;
    const bucket = process.env.MINIO_DECORATION_BUCKET || "decorations";

    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) await minioClient.makeBucket(bucket, "us-east-1");

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    const updatedDecorations = await Decorations.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      Decorations: updatedDecorations,
    });
  } catch (err) {
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Decoration Image
export const deleteDecorationImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query;
    const bucket = process.env.MINIO_DECORATION_BUCKET || "decorations";

    if (!vendorId || !imageUrl)
      return res.status(400).json({ message: "vendorId and imageUrl are required" });

    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    await minioClient.removeObject(bucket, fileName);

    const updatedDecorations = await Decorations.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      Decorations: updatedDecorations,
    });
  } catch (err) {
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};

// ✅ Upload Music Image
export const uploadMusicImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const { vendorId } = req.body;
    const bucket = process.env.MINIO_MUSIC_BUCKET || "music";

    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) await minioClient.makeBucket(bucket, "us-east-1");

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    const updatedMusic = await Music.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      Music: updatedMusic,
    });
  } catch (err) {
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Music Image
export const deleteMusicImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query;
    const bucket = process.env.MINIO_MUSIC_BUCKET || "music";

    if (!vendorId || !imageUrl)
      return res.status(400).json({ message: "vendorId and imageUrl are required" });

    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    await minioClient.removeObject(bucket, fileName);

    const updatedMusic = await Music.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      Music: updatedMusic,
    });
  } catch (err) {
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};

// ✅ Upload Makeup Image
export const uploadMakeupImage = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const { vendorId } = req.body;
    const bucket = process.env.MINIO_MAKEUP_BUCKET || "makeup";

    const exists = await minioClient.bucketExists(bucket).catch(() => false);
    if (!exists) await minioClient.makeBucket(bucket, "us-east-1");

    const fileName = `${vendorId}_${Date.now()}_${req.file.originalname}`;
    await minioClient.putObject(bucket, fileName, req.file.buffer);

    const fileUrl = `http://${process.env.MINIO_ENDPOINT}:${process.env.MINIO_PORT}/${bucket}/${fileName}`;

    const updatedMakeup = await Makeup.findOneAndUpdate(
      { vendorId },
      { $push: { images: fileUrl } },
      { new: true }
    );

    res.status(200).json({
      message: "Upload successful",
      url: fileUrl,
      Makeup: updatedMakeup,
    });
  } catch (err) {
    res.status(500).json({ message: "Upload failed", error: err.message });
  }
};

// ✅ Delete Makeup Image
export const deleteMakeupImage = async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { imageUrl } = req.query;
    const bucket = process.env.MINIO_MAKEUP_BUCKET || "makeup";

    if (!vendorId || !imageUrl)
      return res.status(400).json({ message: "vendorId and imageUrl are required" });

    const parts = imageUrl.split("/");
    const fileName = parts[parts.length - 1];

    await minioClient.removeObject(bucket, fileName);

    const updatedMakeup = await Makeup.findOneAndUpdate(
      { vendorId },
      { $pull: { images: imageUrl } },
      { new: true }
    );

    res.json({
      message: "Image deleted successfully",
      Makeup: updatedMakeup,
    });
  } catch (err) {
    res.status(500).json({ message: "Failed to delete image", error: err.message });
  }
};