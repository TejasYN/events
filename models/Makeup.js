import mongoose from "mongoose";

const makeupSchema = new mongoose.Schema(
  {
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
    makeupName: { type: String, required: true },
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

const Makeup = mongoose.model("Makeup", makeupSchema);
export default Makeup;
