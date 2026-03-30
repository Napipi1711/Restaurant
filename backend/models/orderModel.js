import mongoose from "mongoose";

const orderSchema = new mongoose.Schema({
    customer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    items: [
        {
            food: { type: mongoose.Schema.Types.ObjectId, ref: "Food", required: true },
            quantity: { type: Number, required: true },
            price: { type: Number, required: true }
        }
    ],
    totalAmount: { type: Number, required: true },
    deliveryAddress: { type: String, required: true },

    paymentMethod: {
        type: String,
        enum: ["cash"],
        default: "cash",
    },

    status: {
        type: String,
        enum: ["pending", "confirmed", "delivering", "completed", "cancelled"],
        default: "pending"
    },

    discount: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Discount",
        default: null
    },
    approvedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    approvedRole: { type: String, enum: ["manager", "waiter"], default: null },
    approvedAt: { type: Date, default: null },
    servedBySession: { type: mongoose.Schema.Types.ObjectId, ref: "ServeSession", default: null }

}, { timestamps: true });

const Order = mongoose.models.Order || mongoose.model("Order", orderSchema);

export default Order;
