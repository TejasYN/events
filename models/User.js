import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    username: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    birthdate: { type: Date, required: true }, 
    mobile: { type: String, required: true },  
    city: { type: String, required: true },    
    otp: { type: String },
    otpExpires: { type: Date },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
