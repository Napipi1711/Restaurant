import mongoose from "mongoose";

const shiftSchema = new mongoose.Schema({
  dayStr: {
    type: String,
    required: true,
    match: /^\d{4}-\d{2}-\d{2}$/
  },
  startTime: {
    type: String,
    required: true,
    match: /^([01]\d|2[0-3]):([0-5]\d)$/
  },
  endTime: {
    type: String,
    required: true,
    match: /^([01]\d|2[0-3]):([0-5]\d)$/
  },

  
  waitersStatus: [
    {
      waiter: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
      status: { type: String, enum: ["pending", "working", "complete"], default: "pending" }
    }
  ]
}, { timestamps: true });

const Shift = mongoose.models.Shift || mongoose.model("Shift", shiftSchema);
export default Shift;
