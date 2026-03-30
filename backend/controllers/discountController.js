import Discount from "../models/discountModel.js";
import Cart from "../models/cartModel.js";

export const createDiscount = async (req, res) => {
    try {
        const { code, description, discountType, value, minOrderAmount, usageLimit, expireAt } = req.body;

   
        const existing = await Discount.findOne({ code: code.toUpperCase() });
        if (existing) return res.status(400).json({ message: "Discount code already exists" });

        const discount = await Discount.create({
            code: code.toUpperCase(),
            description,
            discountType,
            value,
            minOrderAmount: minOrderAmount || 0,
            usageLimit: usageLimit || 1,
            expireAt
        });

        res.status(201).json(discount);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

export const getDiscounts = async (req, res) => {
    try {
        const discounts = await Discount.find().sort({ createdAt: -1 });
        res.status(200).json(discounts);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

export const getDiscountByCode = async (req, res) => {
    try {
        const { code } = req.params;
        const discount = await Discount.findOne({ code: code.toUpperCase(), active: true });

        if (!discount) return res.status(404).json({ message: "Discount code not found or inactive" });

        const now = new Date();
        if (discount.expireAt && discount.expireAt < now) {
            return res.status(400).json({ message: "Discount code has expired" });
        }

        if (discount.usedCount >= discount.usageLimit) {
            return res.status(400).json({ message: "Discount code usage limit reached" });
        }

        res.status(200).json(discount);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

export const applyDiscount = async (discountId) => {
    try {
        const discount = await Discount.findById(discountId);
        if (!discount) throw new Error("Discount not found");

        discount.usedCount += 1;
        if (discount.usedCount >= discount.usageLimit) discount.active = false;

        await discount.save();
        return discount;
    } catch (err) {
        throw new Error(err.message);
    }
};

export const checkDiscount = async (req, res) => {
    try {
        const { discountCode } = req.body;
        if (!discountCode) return res.status(400).json({ message: "No discount code provided" });

        const discount = await Discount.findOne({ code: discountCode });
        if (!discount) return res.status(404).json({ message: "Discount not found" });

        
        const now = new Date();
        const isActive = discount.active && (!discount.expireAt || discount.expireAt >= now);

        res.json({
            ...discount.toObject(),
            isActive
        });
    } catch (err) {
        console.error("Check discount error:", err);
        res.status(500).json({ message: "Server error" });
    }
};