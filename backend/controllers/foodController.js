import foodModel from "../models/foodModels.js";

// Add food
const addFood = async (req, res) => {
     try {
          console.log(" [DEBUG] addFood called");

          console.log(" [DEBUG] Headers:", req.headers);

          console.log(" [DEBUG] Body:", req.body);

          // In file
          console.log(" [DEBUG] File:", req.file);

          if (!req.file) {
               console.log(" [DEBUG] No file received!");
               return res.json({ success: false, message: "Image is required" });
          }

          const { name, description, price, category } = req.body;

          if (!name || !price || !category) {
               console.log(" [DEBUG] Missing required fields");
               return res.json({ success: false, message: "Missing required fields" });
          }

          const food = new foodModel({
               name,
               description: description || "",
               price: Number(price),
               image: req.file.filename,
               category
          });

          await food.save();
          console.log(" Food added successfully:", food);
          res.json({ success: true, message: "Food item added" });

     } catch (error) {
          console.error(" [ERROR] addFood error:", error);
          res.status(500).json({ success: false, message: "Server error", error });
     }
};


const listFood = async (req, res) => {
     try {
          console.log("📌 [DEBUG] listFood called, query:", req.query);
          const { category } = req.query;

          const foods = category
               ? await foodModel.find({ category })
               : await foodModel.find();

          console.log("📌 [DEBUG] Foods found:", foods.length);
          res.json({ success: true, data: foods });
     } catch (error) {
          console.error("🔥 [ERROR] listFood error:", error);
          res.status(500).json({ success: false, message: "Error fetching food list", error });
     }
};

// Remove food
const removeFood = async (req, res) => {
     try {
          console.log(" [DEBUG] removeFood called, params:", req.params, "body:", req.body);
          const { id } = req.body; 

          if (!id) {
               console.log(" Missing id to delete");
               return res.json({ success: false, message: "Missing id" });
          }

          const deleted = await foodModel.findByIdAndDelete(id);
          if (!deleted) {
               console.log(" Food not found with id:", id);
               return res.json({ success: false, message: "Food not found" });
          }

          console.log(" Food deleted successfully:", deleted);
          res.json({ success: true, message: "Deleted successfully" });
     } catch (err) {
          console.error(" [ERROR] removeFood error:", err);
          res.status(500).json({ success: false, message: "Delete failed", error: err });
     }
};

export { addFood, listFood, removeFood };
