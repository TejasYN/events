import mongoose from "mongoose";

const cateringSchema = new mongoose.Schema(
  {
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
    cateringName: { type: String, required: true },
    city: { type: String, required: true },
    address: { type: String, required: true },
    phone: { type: String },
    maxPlates: { type: Number },
    minPlates: { type: Number },
    shortDescription: { type: String },
    images: [{ type: String }], // Cloudinary / MinIO URLs
    categories: { type: Map, of: Number, default: {} }, // category name to price mapping
    availableDates: [{ type: Date }],
    unavailableDates: [{ type: Date }],
    vegMeals: [
      {
        mealName: { type: String, required: true },
        items: [{ type: String }],
        price: { type: Number, required: true },
      },
    ],
    nonVegMeals: [
      {
        mealName: { type: String, required: true },
        items: [{ type: String }],
        price: { type: Number, required: true },
      },
    ],
  },
  { timestamps: true }
);

const Catering = mongoose.model("Catering", cateringSchema);
export default Catering;
