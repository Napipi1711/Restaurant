import Reservation from "../models/reservationModel.js";
import Table from "../models/tableModel.js";
import mongoose from "mongoose";
import { buildDateRange } from "../utils/dateHelper.js";
import ServeSession from "../models/serveModel.js";
const normalizeDate = (date) => {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
};

const validFlow = {
  pending: ["confirmed", "cancelled"],
  confirmed: ["seated", "cancelled"],
  seated: ["completed"],
  completed: [],
  cancelled: []
};

// Tạo reservation
export const createReservation = async (req, res) => {
  try {
    const { tableId, reservationDate, expectedArrivalTime, numberOfGuests, note } = req.body;
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ message: "Unauthorized" });
    if (!tableId || !reservationDate || !numberOfGuests) return res.status(400).json({ message: "Missing required data" });

    const { start, end } = buildDateRange(reservationDate);
    const today = new Date(); today.setHours(0, 0, 0, 0);
    if (end < today) return res.status(400).json({ message: "Cannot book a date in the past" });

    const table = await Table.findById(tableId);
    if (!table || !table.isActive) return res.status(400).json({ message: "Table does not exist or is locked." });

    const existed = await Reservation.findOne({
      table: tableId,
      reservationDate: { $gte: start, $lte: end },
      status: { $in: ["pending", "confirmed", "seated"] }
    });
    if (existed) return res.status(409).json({ message: "Tables have been reserved for today." });

    const reservation = await Reservation.create({
      user: userId,
      table: tableId,
      reservationDate: start,
      expectedArrivalTime,
      numberOfGuests,
      note
    });

    res.status(201).json({ message: "Reservation created successfully", reservation });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// Xem reservations của chính user
export const getMyReservations = async (req, res) => {
  try {
    const reservations = await Reservation.find({ user: req.user.id })
      .populate("table")
      .sort({ reservationDate: -1 });
    res.json(reservations);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// Xem tất cả reservations
export const getAllReservations = async (req, res) => {
  try {
    const reservations = await Reservation.find()
      .populate("user", "username phone")
      .populate("table")
      .sort({ reservationDate: 1 });
    res.json(reservations);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// Xác nhận reservation
export const confirmReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const reservation = await Reservation.findById(id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });
    if (reservation.status !== "pending") return res.status(400).json({ message: "Only pending reservations can be confirmed" });

    reservation.status = "confirmed";
    await reservation.save();

    res.json({ message: "Reservation confirmed.", reservation });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};


export const updateReservationStatus = async (req, res) => {
  try {
    const { status, actualNumberOfGuests, servedByWaiters } = req.body;
    const { id } = req.params;

    const reservation = await Reservation.findById(id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });
    if (!validFlow[reservation.status].includes(status)) return res.status(400).json({ message: `Cannot change status from ${reservation.status} to ${status}` });

    reservation.status = status;
    if (actualNumberOfGuests) reservation.actualNumberOfGuests = actualNumberOfGuests;
    if (servedByWaiters) reservation.servedByWaiters = servedByWaiters; 

    await reservation.save();

    if (status === "seated") await Table.findByIdAndUpdate(reservation.table, { status: "unavailable" });
    if (status === "completed") await Table.findByIdAndUpdate(reservation.table, { status: "available" });

    res.json({ message: "Status update successful", reservation });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// Hủy reservation
export const cancelReservation = async (req, res) => {
  try {
    const { id } = req.params;
    const reservation = await Reservation.findById(id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });
    if (reservation.user.toString() !== req.user.id && req.user.role !== "manager")
      return res.status(403).json({ message: "You do not have the right to cancel this reservation." });
    if (reservation.status === "completed") return res.status(400).json({ message: "Completed reservations cannot be canceled." });

    reservation.status = "cancelled";
    await reservation.save();
    await Table.findByIdAndUpdate(reservation.table, { status: "available" });

    res.json({ message: "Reservation cancelled successfully.", reservation });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// Lấy bàn còn trống theo ngày
export const getAvailableTablesByDate = async (req, res) => {
  try {
    const { date } = req.query;
    if (!date) return res.status(400).json({ message: "Missing date" });

    const { start, end } = buildDateRange(date);
    const reservedTables = await Reservation.find({
      reservationDate: { $gte: start, $lte: end },
      status: { $in: ["pending", "confirmed", "seated"] }
    }).distinct("table");

    const tables = await Table.find({ _id: { $nin: reservedTables }, isActive: true });
    res.json(tables);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};
export const seatReservation = async (req, res) => {
  try {
    const { id } = req.params; // reservation id
    const { actualNumberOfGuests, waiterIds } = req.body;

    if (!actualNumberOfGuests || !waiterIds || !Array.isArray(waiterIds) || waiterIds.length === 0) {
      return res.status(400).json({ message: "Missing actualNumberOfGuests or waiterIds" });
    }

    const reservation = await Reservation.findById(id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });
    if (reservation.status !== "confirmed") return res.status(400).json({ message: "Only confirmed reservations can be seated" });

    // Cập nhật reservation
    reservation.actualNumberOfGuests = actualNumberOfGuests;
    reservation.servedByWaiters = waiterIds;
    reservation.status = "seated";
    await reservation.save();

    // Cập nhật table
    await Table.findByIdAndUpdate(reservation.table, { status: "unavailable" });

    
    const existedSession = await ServeSession.findOne({
      reservation: reservation._id,
      status: "serving"
    });

    let session;
    if (!existedSession) {
      session = await ServeSession.create({
        reservation: reservation._id,
        table: reservation.table,
        waiters: waiterIds,
        items: [],
        totalPrice: 0,
        status: "serving"
      });

      reservation.servedBySession = session._id;
      await reservation.save();

      await Table.findByIdAndUpdate(reservation.table, { currentOrder: session._id });
    } else {
      session = existedSession;
    }

    res.status(201).json({
      message: "Reservation is now seated and session created",
      reservation,
      session
    });
  } catch (err) {
    console.error("SEAT RESERVATION ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};



export const getMyServings = async (req, res) => {
  try {
    const waiterId = req.user.id;

    const reservations = await Reservation.find({
      servedByWaiters: waiterId,
      status: "seated"
    })
      .populate("table", "tableNumber")
      .populate("user", "username phone")
      .sort({ reservationDate: 1 });

    res.json(reservations);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};





