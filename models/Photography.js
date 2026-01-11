import mongoose from "mongoose";

const photographySchema = new mongoose.Schema(
  {
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
    studioName: { type: String, required: true },
    city: { type: String, required: true },
    phone: { type: String },
    shortDescription: { type: String },
    experience: { type: Number, default: 0 },
    images: [{ type: String }], // MinIO/Cloudinary URLs
    categories: { type: Map, of: Number, default: {} }, // category name to price mapping
    availableDates: [{ type: Date }],
    unavailableDates: [{ type: Date }],
  },
  { timestamps: true }
);

const Photography = mongoose.model("Photography", photographySchema);
export default Photography;
