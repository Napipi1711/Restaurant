import Summary from "../models/summaryModel.js";

import ServeSession from "../models/serveModel.js";
import Reservation from "../models/reservationModel.js";
import Table from "../models/tableModel.js";

export const getMySummaries = async (req, res) => {
  try {
    const waiterId = req.user.id;

    const summaries = await Summary.find({ waiter: waiterId })
      .populate({
        path: "reservation",
        populate: { path: "table", select: "tableNumber" }
      })
      .sort({ createdAt: -1 });

    res.json({ summaries });
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
};


export const getSubmitted = async (req, res) => {
  try {
    const summaries = await Summary.find({ status: "active" })
      .populate("waiter", "username")
      .populate({
        path: "reservation",
        populate: { path: "table", model: "Table" }
      });

    res.status(200).json({
      message: "List of active summaries",
      summaries,
    });
  } catch (error) {
    console.error("GET ACTIVE SUMMARIES ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};


export const approveSummary = async (req, res) => {
  try {
    const { summaryId } = req.params;

    const summary = await Summary.findById(summaryId);
    if (!summary) return res.status(404).json({ message: "Summary not found" });

    if (summary.status !== "active") {
      return res.status(400).json({ message: "Summary has already been approved." });
    }

    summary.status = "approved";
    summary.checkedByManager = true;
    await summary.save();

    res.status(200).json({ message: "Summary has been approved", summary });
  } catch (error) {
    console.error("APPROVE SUMMARY ERROR:", error);
    res.status(500).json({ message: "Server error" });
  }
};
