import Cart from "../models/cartModel.js";
import Food from "../models/foodModels.js";
import Order from "../models/orderModel.js";
import Discount from "../models/discountModel.js";


export const getCart = async (req, res) => {
    try {
        const cart = await Cart.findOne({ customer: req.user.id })
            .populate("items.food");

        if (!cart) {
            return res.status(200).json({ items: [], totalAmount: 0 });
        }

        res.status(200).json(cart);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

export const addItem = async (req, res) => {
    try {
        const { foodId, quantity } = req.body;

        const food = await Food.findById(foodId);
        if (!food) {
            return res.status(404).json({ message: "Food not found" });
        }

        let cart = await Cart.findOne({ customer: req.user.id });

        if (!cart) {
            cart = new Cart({
                customer: req.user.id,
                items: []
            });
        }

        const existingItem = cart.items.find(
            item => item.food.toString() === foodId
        );

        if (existingItem) {
            existingItem.quantity += quantity;
            existingItem.price = food.price;
        } else {
            cart.items.push({
                food: foodId,
                quantity,
                price: food.price
            });
        }

        cart.totalAmount = cart.items.reduce(
            (sum, item) => sum + item.quantity * item.price,
            0
        );

        await cart.save();
        const populatedCart = await Cart.findById(cart._id).populate("items.food");
        res.status(200).json(populatedCart);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


export const updateItem = async (req, res) => {
    try {
        const { foodId, quantity } = req.body;

        const cart = await Cart.findOne({ customer: req.user.id });
        if (!cart) {
            return res.status(404).json({ message: "Cart not found" });
        }

        const item = cart.items.find(
            item => item.food.toString() === foodId
        );
        if (!item) {
            return res.status(404).json({ message: "Item not found" });
        }

        item.quantity = quantity;

        cart.totalAmount = cart.items.reduce(
            (sum, item) => sum + item.quantity * item.price,
            0
        );

        await cart.save();
        const populatedCart = await Cart.findById(cart._id).populate("items.food");

        res.status(200).json(populatedCart);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


export const removeItem = async (req, res) => {
    try {
        const { foodId } = req.body;

        const cart = await Cart.findOne({ customer: req.user.id });
        if (!cart) {
            return res.status(404).json({ message: "Cart not found" });
        }

        cart.items = cart.items.filter(
            item => item.food.toString() !== foodId
        );

        cart.totalAmount = cart.items.reduce(
            (sum, item) => sum + item.quantity * item.price,
            0
        );

        await cart.save();
        const populatedCart = await Cart.findById(cart._id).populate("items.food");
        res.status(200).json(populatedCart);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};


export const checkout = async (req, res) => {
    try {
        console.log("📥 CHECKOUT BODY:", req.body);
        console.log("📥 CHECKOUT HEADERS:", req.headers.authorization);
        console.log("👤 CHECKOUT USER:", req.user);

        const { deliveryAddress, discountCode } = req.body;

        const cart = await Cart.findOne({ customer: req.user.id })
            .populate("items.food");

        console.log("🛒 CART FOUND:", cart ? cart.items.length : 0);

        if (!cart || cart.items.length === 0) {
            return res.status(400).json({ message: "Cart is empty" });
        }

        cart.items.forEach((item, index) => {
            console.log(`🍔 ITEM ${index}:`, {
                food: item.food,
                quantity: item.quantity,
                price: item.price
            });
        });

        let totalAmount = cart.totalAmount;
        console.log("💰 TOTAL AMOUNT (BEFORE):", totalAmount);

        let discountApplied = null;

        if (discountCode) {
            console.log("🏷 DISCOUNT CODE:", discountCode);

            const discount = await Discount.findOne({
                code: discountCode.toUpperCase(),
                active: true
            });

            console.log("🏷 DISCOUNT FOUND:", discount);

            if (!discount) {
                return res.status(400).json({ message: "Invalid discount code" });
            }

            console.log("📊 DISCOUNT USED / LIMIT:", discount.usedCount, "/", discount.usageLimit);

            const now = new Date();
            if (discount.expireAt && discount.expireAt < now) {
                return res.status(400).json({ message: "Discount expired" });
            }

            if (discount.usedCount >= discount.usageLimit) {
                return res.status(400).json({ message: "Usage limit reached" });
            }

            if (discount.minOrderAmount > totalAmount) {
                return res.status(400).json({
                    message: `Minimum order ${discount.minOrderAmount}`
                });
            }

            if (discount.discountType === "percentage") {
                totalAmount -= (totalAmount * discount.value) / 100;
            } else {
                totalAmount -= discount.value;
                if (totalAmount < 0) totalAmount = 0;
            }

            console.log("💰 TOTAL AFTER DISCOUNT:", totalAmount);

            discount.usedCount += 1;
            if (discount.usedCount >= discount.usageLimit) {
                discount.active = false;
            }

            await discount.save();
            discountApplied = discount;
        }

        const orderItems = cart.items.map(item => ({
            food: item.food?._id,
            quantity: item.quantity,
            price: item.price
        }));

        console.log("📦 ORDER ITEMS:", orderItems);

        const order = await Order.create({
            customer: req.user.id,
            items: orderItems,
            totalAmount,
            deliveryAddress,
            paymentMethod: req.body.paymentMethod,
            discount: discountApplied ? discountApplied._id : null
        });

        cart.items = [];
        cart.totalAmount = 0;
        await cart.save();

        res.status(200).json({
            message: "Order placed successfully",
            order,
            discountApplied
        });
    } catch (err) {
        console.error("🔥 CHECKOUT ERROR:", err);
        res.status(500).json({ message: err.message });
    }
};

