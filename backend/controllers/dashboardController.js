import ServeSession from "../models/serveModel.js";

export const getRevenueSummary = async (req, res) => {
  try {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0);
    const endOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
    const day = now.getDay(); 
    const diffToMonday = day === 0 ? 6 : day - 1; 
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - diffToMonday);
    startOfWeek.setHours(0, 0, 0, 0);
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
    const sessionsToday = await ServeSession.find({
      status: "completed",
      createdAt: { $gte: startOfToday, $lte: endOfToday }
    });

    const sessionsWeek = await ServeSession.find({
      status: "completed",
      createdAt: { $gte: startOfWeek, $lte: endOfWeek }
    });

    const sessionsMonth = await ServeSession.find({
      status: "completed",
      createdAt: { $gte: startOfMonth, $lte: endOfMonth }
    });
    const calcTotal = (arr) => arr.reduce((sum, s) => sum + s.totalPrice, 0);
    res.status(200).json({
      today: calcTotal(sessionsToday),
      week: calcTotal(sessionsWeek),
      month: calcTotal(sessionsMonth),
    });

  } catch (error) {
    console.error("GET REVENUE SUMMARY ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};
