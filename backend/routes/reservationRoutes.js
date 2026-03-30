import express from "express";
import {
  createReservation,
  getMyReservations,
  getAllReservations,
  confirmReservation,
  updateReservationStatus,
  cancelReservation,
  getAvailableTablesByDate,
  seatReservation,
  getMyServings
} from "../controllers/reservationController.js";

import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";

const router = express.Router();


router.get("/available", getAvailableTablesByDate);


router.post("/", verifyToken, createReservation);
router.get("/my", verifyToken, getMyReservations);
router.get("/my-servings", verifyToken, authorizeRoles("waiter"), getMyServings);
router.put("/:id/cancel", verifyToken, cancelReservation);
router.patch(
  "/:id/seat",
  verifyToken,
  authorizeRoles("manager"),
  seatReservation
);

router.get("/", verifyToken, authorizeRoles("manager"), getAllReservations);
router.put("/:id/confirm", verifyToken, authorizeRoles("manager"), confirmReservation);


router.put("/:id/status", verifyToken, authorizeRoles("manager"), updateReservationStatus);

export default router;