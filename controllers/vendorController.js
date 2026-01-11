import Vendor from "../models/Vendor.js";

// ✅ Register Vendor
export const registerVendor = async (req, res) => {
  try {
    const { vendorType, name, businessName, gstin, fssai, city, mobile, email } = req.body;

    if (!vendorType || !name || !businessName || !gstin || !city || !mobile || !email) {
      return res.status(400).json({ message: "All fields are required" });
    }

    if (vendorType === "Catering" && !fssai) {
      return res.status(400).json({ message: "FSSAI is required for Catering vendors" });
    }

    const existingVendor = await Vendor.findOne({ email, vendorType });
    if (existingVendor) {
      return res.status(400).json({ message: "Vendor already exists with this email & type" });
    }

    const vendor = new Vendor({
      vendorType,
      name,
      businessName,
      gstin,
      fssai,
      city,
      mobile: String(mobile),
      email,
      vendorTypeDetails: vendorType,
    });

    await vendor.save();
    res.status(201).json({ message: "Vendor registered successfully", vendor });
  } catch (error) {
    console.error("❌ Error in registerVendor:", error.message);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Get All Vendors
export const getVendors = async (req, res) => {
  try {
    const vendors = await Vendor.find().populate("businessDetails");
    res.status(200).json(vendors);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};

// ✅ Vendor Login
export const loginVendor = async (req, res) => {
  try {
    const { vendorType, email, mobile } = req.body;

    if (!vendorType) return res.status(400).json({ message: "Vendor type required" });
    if (!email && !mobile) return res.status(400).json({ message: "Email or mobile required" });

    const query = { vendorType };
    if (email) query.email = email;
    if (mobile) query.mobile = String(mobile);

    console.log("🔍 Vendor login query:", query);
    const vendor = await Vendor.findOne(query).populate("businessDetails");
    console.log("🔍 Vendor login result:", vendor);
    if (!vendor) return res.status(404).json({ message: "Vendor not found", query });

    res.status(200).json({ message: "Login successful", vendor });
  } catch (error) {
    console.error("❌ Error in loginVendor:", error.message);
    res.status(500).json({ message: "Server Error", error: error.message });
  }
};
