import mongoose from "mongoose";

const cartSchema = new mongoose.Schema({
    customer: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
        unique: true 
    },
    items: [
        {
            food: { type: mongoose.Schema.Types.ObjectId, ref: "Food", required: true },
            quantity: { type: Number, required: true, default: 1 },
            price: { type: Number, required: true } 
        }
    ],
    totalAmount: { type: Number, default: 0 } 
}, { timestamps: true });

const Cart = mongoose.models.Cart || mongoose.model("Cart", cartSchema);

export default Cart;
