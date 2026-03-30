import mongoose from "mongoose";

const tableSchema = new mongoose.Schema({
  tableNumber: {
    type: Number,
    required: true,
    unique: true
  },
  seats: {
    type: Number,
    default: 2
  },
  status: {
    type: String,
    enum: ["available", "unavailable"],
    default: "available"
  },
  isActive: {
    type: Boolean,
    default: true 
  },
  note: {
    type: String,
    default: ""
  },
  currentOrder: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Order",
    default: null
  }
}, { timestamps: true });

const tableModel = mongoose.models.Table || mongoose.model("Table", tableSchema);

export default tableModel;
