import express from "express";
import {
  createShift,
  getAllShifts,
  getMyShifts,
  getShiftDetail,
  updateShift,
  deleteShift,
  confirmShift,
  endShift,
  getTodaySummary  
} from "../controllers/shiftController.js";

import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";

const router = express.Router();

router.post("/", verifyToken, authorizeRoles("manager"), createShift);

router.get("/", verifyToken, getAllShifts);
router.get("/my-shifts", verifyToken, authorizeRoles("waiter"), getMyShifts);


router.get("/:id", verifyToken, getShiftDetail);

router.put("/:id", verifyToken, authorizeRoles("manager"), updateShift);


router.delete("/:id", verifyToken, authorizeRoles("manager"), deleteShift);


router.put("/:id/confirm", verifyToken, authorizeRoles("waiter"), confirmShift);


router.put("/:id/end", verifyToken, authorizeRoles("waiter"), endShift);


router.get("/today-summary", verifyToken, authorizeRoles("waiter"), getTodaySummary);

export default router;
