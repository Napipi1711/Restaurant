import mongoose from "mongoose";

const reservationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    table: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Table",
      required: true
    },

    reservationDate: {
      type: Date,
      required: true
    },

    expectedArrivalTime: {
      type: String,
      default: ""
    },

    numberOfGuests: {
      type: Number,
      required: true,
      min: 1
    },

    actualNumberOfGuests: {
      type: Number,
      default: 0
    },

    status: {
      type: String,
      enum: ["pending", "confirmed", "seated", "completed", "cancelled"],
      default: "pending"
    },

    note: {
      type: String,
      default: ""
    },

    servedByWaiters: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User"
      }
    ]
  },
  { timestamps: true }
);

const Reservation =
  mongoose.models.Reservation ||
  mongoose.model("Reservation", reservationSchema);

export default Reservation;
