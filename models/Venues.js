import mongoose from "mongoose";

const venueSchema = new mongoose.Schema(
  {
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
    venueName: { type: String, required: true },
    city: { type: String, required: true },
    address: { type: String, required: true },
    phone: { type: String },
    price: { type: Number },
    seats: { type: Number }, 
    shortDescription: { type: String }, 
    images: [{ type: String }], // Cloudinary / MinIO URLs
    subcategory: { type: String, default: "" },
    availableDates: [{ type: Date }],
    unavailableDates: [{ type: Date }],
  },
  { timestamps: true }
);

const Venue = mongoose.model("Venue", venueSchema);
export default Venue;
