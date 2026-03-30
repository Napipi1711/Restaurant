import Order from "../models/orderModel.js";

export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("customer", "username email phone")
      .populate("items.food", "name price image")
      .populate("discount", "code value discountType");
    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


export const getOrdersByUser = async (req, res) => {
  try {
    const orders = await Order.find({ customer: req.user.id })
      .populate("items.food", "name price image")
      .populate("discount", "code value discountType")
      .sort({ createdAt: -1 });
    res.status(200).json(orders);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


export const getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("customer", "username email phone")
      .populate("items.food", "name price image")
      .populate("discount", "code value discountType");
    if (!order) return res.status(404).json({ message: "Order not found" });


    if (req.user.role === "user" && order.customer._id.toString() !== req.user.id) {
      return res.status(403).json({ message: "Access denied" });
    }

    res.status(200).json(order);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


export const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const userId = req.user.id;

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (!["confirmed", "delivering", "completed", "cancelled"].includes(status)) {
      return res.status(400).json({ message: "Invalid status" });
    }

    if (order.status === "completed" || order.status === "cancelled") {
      return res.status(400).json({ message: "Order already finalized" });
    }

    const allowedTransitions = {
      pending: ["confirmed", "cancelled"],
      confirmed: ["delivering", "cancelled"],
      delivering: ["completed"]
    };

    if (!allowedTransitions[order.status]?.includes(status)) {
      return res.status(400).json({
        message: `Cannot change status from ${order.status} to ${status}`
      });
    }

    order.status = status;
    order.approvedBy = userId;
    order.approvedRole = "manager";
    order.approvedAt = new Date();

    await order.save();

    res.status(200).json({
      message: "Order updated successfully",
      order
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
