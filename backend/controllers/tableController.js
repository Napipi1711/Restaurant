import tableModel from "../models/tableModel.js";


const addTable = async (req, res) => {
  try {
    console.log(" [DEBUG] addTable called");
    console.log(" [DEBUG] Body:", req.body);

    const { tableNumber, seats, note } = req.body;

    if (!tableNumber) {
      console.log(" [DEBUG] Table number missing");
      return res.json({ success: false, message: "Table number is required" });
    }

    const existing = await tableModel.findOne({ tableNumber });
    if (existing) {
      console.log(" [DEBUG] Table number already exists");
      return res.json({ success: false, message: "Table number already exists" });
    }

    const table = new tableModel({
      tableNumber,
      seats: seats || 2,
      note: note || "",
    });

    await table.save();
    console.log(" [DEBUG] Table added:", table);
    res.json({ success: true, message: "Table added", data: table });
  } catch (err) {
    console.error(" [ERROR] addTable exception:", err);
    res.status(500).json({ success: false, message: "Server error" });
  }
};


const listTables = async (req, res) => {
  try {
    console.log(" [DEBUG] listTables called");
    const tables = await tableModel.find().sort({ tableNumber: 1 });
    console.log(" [DEBUG] Tables fetched:", tables.length);
    res.json({ success: true, data: tables });
  } catch (err) {
    console.error(" [ERROR] listTables exception:", err);
    res.status(500).json({ success: false, message: "Error fetching tables" });
  }
};

const updateTable = async (req, res) => {
  try {
    console.log(" [DEBUG] updateTable called");
    console.log(" [DEBUG] Params:", req.params);
    console.log(" [DEBUG] Body:", req.body);

    const { id } = req.params;
    const { status, seats, note, isActive, currentOrder } = req.body;

    const table = await tableModel.findById(id);
    if (!table) {
      console.log(" [DEBUG] Table not found");
      return res.json({ success: false, message: "Table not found" });
    }

    if (status) table.status = status;
    if (seats !== undefined) table.seats = seats;
    if (note !== undefined) table.note = note;
    if (isActive !== undefined) table.isActive = isActive;
    if (currentOrder !== undefined) table.currentOrder = currentOrder;

    await table.save();
    console.log(" [DEBUG] Table updated:", table);
    res.json({ success: true, message: "Table updated", data: table });
  } catch (err) {
    console.error(" [ERROR] updateTable exception:", err);
    res.status(500).json({ success: false, message: "Update failed" });
  }
};

// Xóa bàn
const removeTable = async (req, res) => {
  try {
    console.log(" [DEBUG] removeTable called");
    console.log(" [DEBUG] Params:", req.params);

    const { id } = req.params;
    const deleted = await tableModel.findByIdAndDelete(id);
    if (!deleted) {
      console.log(" [DEBUG] Table not found");
      return res.json({ success: false, message: "Table not found" });
    }
    console.log(" [DEBUG] Table deleted:", deleted);
    res.json({ success: true, message: "Table deleted" });
  } catch (err) {
    console.error("[ERROR] removeTable exception:", err);
    res.status(500).json({ success: false, message: "Delete failed" });
  }
};

export { addTable, listTables, updateTable, removeTable };
