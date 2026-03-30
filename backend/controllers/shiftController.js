import Shift from "../models/shiftModel.js";
import ServeSession from "../models/serveModel.js";
import Summary from "../models/summaryModel.js";
// ===== CREATE SHIFT =====
export const createShift = async (req, res) => {
  try {
    const { dayStr, startTime, endTime, waiters } = req.body;

    
    const waitersStatus = waiters.map(w => ({ waiter: w, status: "pending" }));

    const shift = new Shift({
      dayStr,
      startTime,
      endTime,
      waitersStatus
    });

    const savedShift = await shift.save();
    await savedShift.populate("waitersStatus.waiter", "username");

    res.status(201).json(savedShift);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const getAllShifts = async (req, res) => {
  try {
    const { day } = req.query;
    const query = {};
    if (day) query.dayStr = day;

    const shifts = await Shift.find(query).populate("waitersStatus.waiter", "username");
    res.status(200).json(shifts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getShiftDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const shift = await Shift.findById(id).populate("waitersStatus.waiter", "username");
    if (!shift) return res.status(404).json({ message: "Shift not found" });
    res.status(200).json(shift);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ===== UPDATE SHIFT =====
export const updateShift = async (req, res) => {
  try {
    const { id } = req.params;
    const { dayStr, startTime, endTime, waiters } = req.body;

    const shift = await Shift.findById(id);
    if (!shift) return res.status(404).json({ message: "Shift not found" });

    if (dayStr) shift.dayStr = dayStr;
    if (startTime) shift.startTime = startTime;
    if (endTime) shift.endTime = endTime;
    if (waiters) {
    
      shift.waitersStatus = waiters.map(w => ({ waiter: w, status: "pending" }));
    }

    const updatedShift = await shift.save();
    await updatedShift.populate("waitersStatus.waiter", "username");
    res.status(200).json(updatedShift);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};


export const deleteShift = async (req, res) => {
  try {
    const { id } = req.params;
    const shift = await Shift.findByIdAndDelete(id);
    if (!shift) return res.status(404).json({ message: "Shift not found" });
    res.status(200).json({ message: "Shift deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const getMyShifts = async (req, res) => {
  try {
    const userId = req.user.id;
    const { day } = req.query;
    if (!day) return res.status(400).json({ message: "Day is required" });

    const shifts = await Shift.find({
      dayStr: day,
      "waitersStatus.waiter": userId
    }).populate("waitersStatus.waiter", "username");

    if (!shifts.length) return res.status(200).json({ message: "Today is not your day!" });

    res.status(200).json(shifts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const confirmShift = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const shift = await Shift.findById(id).populate("waitersStatus.waiter", "username");
    if (!shift) return res.status(404).json({ message: "Shift not found" });

    const waiterEntry = shift.waitersStatus.find(ws => ws.waiter._id.toString() === userId);
    if (!waiterEntry) return res.status(403).json({ message: "You are not assigned to this shift" });
    if (waiterEntry.status === "complete") return res.status(400).json({ message: "You have already confirmed this shift" });

    waiterEntry.status = "working";
    await shift.save();

   
    await ServeSession.create({
      shift: shift._id,
      waiter: userId,
      reservations: [] 
    });

    res.status(200).json({ message: "Shift confirmed", shift });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


export const endShift = async (req, res) => {
  try {
    const { id: shiftId } = req.params;
    const waiterId = req.user.id;

    const shift = await Shift.findById(shiftId).populate("waitersStatus.waiter");
    if (!shift) return res.status(404).json({ message: "Shift not found" });

   
    let waiterEntry = shift.waitersStatus.find(ws => ws.waiter._id.toString() === waiterId);
    if (!waiterEntry) return res.status(403).json({ message: "You are not assigned to this shift" });

   
    if (waiterEntry.status !== "complete") {
      waiterEntry.status = "complete";
      await shift.save();
    }

   
    const todayStr = shift.dayStr;
    const sessions = await ServeSession.find({
      waiter: waiterId,
      status: "completed",
      createdAt: {
        $gte: new Date(todayStr + "T00:00:00Z"),
        $lte: new Date(todayStr + "T23:59:59Z")
      }
    });

    const totalSessions = sessions.length;
    const totalAmount = sessions.reduce((sum, s) => sum + s.totalPrice, 0);

   
    let summary = await Summary.findOne({ waiter: waiterId, date: todayStr });
    if (!summary) {
      summary = await Summary.create({
        waiter: waiterId,
        date: todayStr,
        sessions: sessions.map(s => s._id),
        totalSessions,
        totalAmount,
        status: "submitted"
      });
    } else {
      summary.sessions = sessions.map(s => s._id);
      summary.totalSessions = totalSessions;
      summary.totalAmount = totalAmount;
      summary.status = "submitted";
      await summary.save();
    }

    res.status(200).json({ message: "Shift ended, summary updated", shift, summary });
  } catch (error) {
    console.error("END SHIFT ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};



export const getTodaySummary = async (req, res) => {
  try {
    const waiterId = req.user.id;
    const todayStr = new Date().toISOString().slice(0, 10); // 'YYYY-MM-DD'

    
    let summary = await Summary.findOne({ waiter: waiterId, date: todayStr });

    if (!summary) {
      
      const sessions = await ServeSession.find({
        waiter: waiterId,
        status: "completed",
        createdAt: {
          $gte: new Date(todayStr + "T00:00:00Z"),
          $lte: new Date(todayStr + "T23:59:59Z")
        }
      });

      const totalSessions = sessions.length;
      const totalAmount = sessions.reduce((sum, s) => sum + s.totalPrice, 0);

      summary = {
        waiter: waiterId,
        date: todayStr,
        totalSessions,
        totalAmount,
        sessions: sessions.map(s => s._id)
      };
    }

    res.status(200).json({ message: "Summary today", summary });
  } catch (error) {
    console.error("GET TODAY SUMMARY ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};