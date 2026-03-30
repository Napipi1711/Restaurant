import ServeSession from "../models/serveModel.js";
import Reservation from "../models/reservationModel.js";
import Table from "../models/tableModel.js";
import Food from "../models/foodModels.js";
import Summary from "../models/summaryModel.js";
import mongoose from "mongoose";


const getCurrentSessionByReservation = async (reservationId) => {
  if (!mongoose.Types.ObjectId.isValid(reservationId)) return null;

  const session = await ServeSession.findOne({
    reservation: reservationId,
    status: "serving"
  });
  return session;
};

export const addFoodToSession = async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { foodId, quantity = 1 } = req.body;
    const waiterId = req.user.id;

    if (!foodId) return res.status(400).json({ message: "Missing foodId" });

    const session = await getCurrentSessionByReservation(reservationId);
    if (!session) return res.status(404).json({ message: "Serving session not found" });

    if (!session.waiters.includes(waiterId))
      return res.status(403).json({ message: "You are not assigned to this session." });

    const food = await Food.findById(foodId);
    if (!food) return res.status(404).json({ message: "Dish not found" });

    const existedItem = session.items.find(item => item.food.toString() === foodId);
    if (existedItem) {
      existedItem.quantity += quantity;
    } else {
      session.items.push({
        food: food._id,
        name: food.name,
        price: food.price,
        quantity
      });
    }

    session.totalPrice = session.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    await session.save();

    res.json({ message: "Added item successfully", session });
  } catch (error) {
    console.error("ADD FOOD ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};


export const getServeSessionDetail = async (req, res) => {
  try {
    const { reservationId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(reservationId)) {
      return res.status(400).json({ message: "Invalid reservationId" });
    }

    const session = await ServeSession.findOne({ reservation: reservationId })
      .populate("table", "tableNumber") // <- thêm populate tên bàn
      .populate("items.food") // populate food nếu muốn
      .populate("waiters", "username"); // populate tên waiter nếu muốn

    if (!session) return res.status(404).json({ message: "Serving session not found" });

    res.json({ message: "ServeSession detail", session });
  } catch (error) {
    console.error("GET SERVE SESSION DETAIL ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};


export const removeFoodFromSession = async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { foodId } = req.body;
    const waiterId = req.user.id;

    if (!foodId) return res.status(400).json({ message: "Missing foodId" });

    const session = await getCurrentSessionByReservation(reservationId);
    if (!session) return res.status(404).json({ message: "Serving session not found" });

    if (!session.waiters.includes(waiterId))
      return res.status(403).json({ message: "You are not assigned to this session." });

    const index = session.items.findIndex(item => item.food.toString() === foodId);
    if (index === -1) return res.status(404).json({ message: "The item does not exist in the session." });

    session.items.splice(index, 1);
    session.totalPrice = session.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    await session.save();

    res.json({ message: "Item deleted successfully.", session });
  } catch (error) {
    console.error("REMOVE FOOD ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateFoodQuantity = async (req, res) => {
  try {
    const { reservationId } = req.params;
    const { foodId, quantity } = req.body;
    const waiterId = req.user.id;

    if (!foodId || typeof quantity !== "number")
      return res.status(400).json({ message: "Missing foodId or quantity" });

    const session = await getCurrentSessionByReservation(reservationId);
    if (!session) return res.status(404).json({ message: "Serving session not found" });

    if (!session.waiters.includes(waiterId))
      return res.status(403).json({ message: "You are not assigned to this session." });

    const item = session.items.find(i => i.food.toString() === foodId);
    if (!item) return res.status(404).json({ message: "The item does not exist in the session." });

    if (quantity <= 0) {
      session.items = session.items.filter(i => i.food.toString() !== foodId);
    } else {
      item.quantity = quantity;
    }

    session.totalPrice = session.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
    await session.save();

    res.json({ message: "Update successful", session });
  } catch (error) {
    console.error("UPDATE FOOD QUANTITY ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const checkoutSession = async (req, res) => {
  try {
    const { reservationId } = req.params;
    const waiterId = req.user.id;

    
    const session = await ServeSession.findOne({ reservation: reservationId }).populate("items.food");

    if (!session) {
      return res.status(404).json({ message: "Serving session not found" });
    }

    // Chỉ waiter được gán mới checkout được
    if (!session.waiters.map(w => w.toString()).includes(waiterId)) {
      return res.status(403).json({ message: "You are not assigned to this session" });
    }

   
    if (session.status !== "serving") {
      return res.status(400).json({ message: `Cannot checkout session with status ${session.status}` });
    }

  
    if (!session.totalPrice || session.totalPrice === 0) {
      session.totalPrice = session.items.reduce(
        (sum, item) => sum + (item.price || 0) * (item.quantity || 0),
        0
      );
    }
    session.status = "completed";
    session.endTime = new Date();
    await session.save();

    await Reservation.findByIdAndUpdate(reservationId, { status: "completed" });

    const summary = new Summary({
      waiter: waiterId,
      reservation: reservationId,
      totalAmount: session.totalPrice,
      status: "active"
    });

    await summary.save();

    return res.status(200).json({
      message: "Checkout successful",
      session,
      summary
    });
  } catch (error) {
    console.error("CHECKOUT ERROR:", error);
    return res.status(500).json({ message: "Server error" });
  }
};