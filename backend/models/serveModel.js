import mongoose from "mongoose";

const serveSessionSchema = new mongoose.Schema(
  {
    reservation: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Reservation",
      required: true
    },

    table: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Table",
      required: true
    },

    waiters: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],


    items: [
      {
        food: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Food",
          required: true
        },


        name: {
          type: String,
          required: true
        },

        price: {
          type: Number,
          required: true
        },

        quantity: {
          type: Number,
          default: 1,
          min: 1
        }
      }
    ],

    totalPrice: {
      type: Number,
      default: 0
    },

    status: {
      type: String,
      enum: ["assigned", "serving", "completed", "cancelled"],
      default: "assigned"
    },


    startTime: {
      type: Date,
      default: Date.now
    },

    endTime: {
      type: Date
    }
  },
  { timestamps: true }
);

export default mongoose.model("ServeSession", serveSessionSchema);
