import mongoose from "mongoose";

const vendorSchema = new mongoose.Schema(
  {
    vendorType: {
      type: String,
      required: true,
      enum: ["Venue", "Catering", "Photography","Decorations","Music","Makeup"],
    },
    name: { type: String, required: true }, // Owner Name
    businessName: { type: String, required: true },
    gstin: { type: String, required: true },
    fssai: { type: String }, // Only required for Catering
    city: { type: String, required: true },
    mobile: { type: String, required: true },
    email: { type: String, required: true },

    // Link to business details (Venue or Catering)
    businessDetails: {
      type: mongoose.Schema.Types.ObjectId,
      refPath: "vendorTypeDetails",
    },

    vendorTypeDetails: {
      type: String,
      required: true,
      enum: ["Venue", "Catering", "Photography","Decorations","Music","Makeup"],
    },
  },
  { timestamps: true }
);

const Vendor = mongoose.model("Vendor", vendorSchema);
export default Vendor;
