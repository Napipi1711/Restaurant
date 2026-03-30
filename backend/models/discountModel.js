import mongoose from "mongoose";

const discountSchema = new mongoose.Schema({
    code: {
        type: String,
        required: true,
        unique: true, 
        uppercase: true,
        trim: true
    },
    description: { type: String, default: "" }, 
    discountType: {
        type: String,
        enum: ["percentage", "fixed"], 
        required: true
    },
    value: {
        type: Number,
        required: true 
    },
    minOrderAmount: {
        type: Number,
        default: 0 
    },
    usageLimit: {
        type: Number,
        default: 1 
    },
    usedCount: {
        type: Number,
        default: 0 
    },
    active: {
        type: Boolean,
        default: true
    },
    expireAt: {
        type: Date 
    }
}, { timestamps: true });

const Discount = mongoose.models.Discount || mongoose.model("Discount", discountSchema);

export default Discount;
