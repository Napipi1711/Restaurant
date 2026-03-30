import mongoose from "mongoose";

const summarySchema = new mongoose.Schema(
  {
    waiter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    reservation: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Reservation",
      required: true,
      unique: true, 
    },

    totalAmount: {
      type: Number,
      required: true,
    },

    status: {
      type: String,
      enum: ["active", "approved"],
      default: "active",
    },

    checkedByManager: {
      type: Boolean,
      default: false,
    }
  },
  { timestamps: true }
);

const Summary =
  mongoose.models.Summary || mongoose.model("Summary", summarySchema);

export default Summary;
