import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VendorPrefs {
  static Future<void> saveVendorData(Map<String, dynamic> vendorData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("vendor_id", vendorData["_id"] ?? vendorData["id"] ?? "");
    await prefs.setString("vendor_username", vendorData["name"] ?? "");
    await prefs.setString("vendor_businessName", vendorData["businessName"] ?? "");
    await prefs.setString("vendor_gstin", vendorData["gstin"] ?? "");
    await prefs.setString("vendor_city", vendorData["city"] ?? "");
    await prefs.setString("vendor_mobile", vendorData["mobile"] ?? "");
    await prefs.setString("vendor_email", vendorData["email"] ?? "");
    await prefs.setString("vendor_vendorType", vendorData["vendorType"] ?? "");
    await prefs.setString("vendor_fssai", vendorData["fssai"] ?? "");
    await prefs.setString("vendor_address", vendorData["address"] ?? "");
    await prefs.setInt("vendor_price", vendorData["price"] ?? 0);
    await prefs.setInt("vendor_seats", vendorData["seats"] ?? 0);
    await prefs.setString("vendor_shortDesc", vendorData["shortDescription"] ?? "");
    await prefs.setInt("vendor_maxPlates", vendorData["maxPlates"] ?? 0);
    await prefs.setInt("vendor_minPlates", vendorData["minPlates"] ?? 0);
    await prefs.setString("vendor_subcategory", vendorData["subcategory"] ?? "");

    // ✅ Add experience
    await prefs.setInt("vendor_experience", vendorData["experience"] ?? 0);

    // ✅ Save lists/maps as JSON string
    await prefs.setString("vendor_availableDates", jsonEncode(vendorData["availableDates"] ?? []));
    await prefs.setString("vendor_unavailableDates", jsonEncode(vendorData["unavailableDates"] ?? []));
    await prefs.setString("vendor_images", jsonEncode(vendorData["images"] ?? []));
    await prefs.setString("vendor_vegMeals", jsonEncode(vendorData["vegMeals"] ?? []));
    await prefs.setString("vendor_nonVegMeals", jsonEncode(vendorData["nonVegMeals"] ?? []));
    await prefs.setString("vendor_categories", jsonEncode(vendorData["categories"] ?? {}));
  }

  static Future<Map<String, dynamic>> getVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "id": prefs.getString("vendor_id"),
      "name": prefs.getString("vendor_username"),
      "businessName": prefs.getString("vendor_businessName"),
      "gstin": prefs.getString("vendor_gstin"),
      "city": prefs.getString("vendor_city"),
      "mobile": prefs.getString("vendor_mobile"),
      "email": prefs.getString("vendor_email"),
      "vendorType": prefs.getString("vendor_vendorType"),
      "fssai": prefs.getString("vendor_fssai"),
      "address": prefs.getString("vendor_address"),
      "shortDescription": prefs.getString("vendor_shortDesc"),

      
      "experience": prefs.getInt("vendor_experience") ?? 0,
      "subcategory": prefs.getString("vendor_subcategory") ?? "",

      "availableDates": jsonDecode(prefs.getString("vendor_availableDates") ?? "[]"),
      "unavailableDates": jsonDecode(prefs.getString("vendor_unavailableDates") ?? "[]"),
      "images": jsonDecode(prefs.getString("vendor_images") ?? "[]"),
      
      "price": prefs.getInt("vendor_price"),
      "seats": prefs.getInt("vendor_seats"),
      
      "maxPlates": prefs.getInt("vendor_maxPlates"),
      "minPlates": prefs.getInt("vendor_minPlates"),
      "vegMeals": jsonDecode(prefs.getString("vendor_vegMeals") ?? "[]"),
      "nonVegMeals": jsonDecode(prefs.getString("vendor_nonVegMeals") ?? "[]"),
      "categories": jsonDecode(prefs.getString("vendor_categories") ?? "{}"),
    };
  }

  static Future<void> clearVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clears everything vendor
  }
}
