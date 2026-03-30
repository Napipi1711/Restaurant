import express from "express";

import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";
import {
  getSubmitted,
  approveSummary,
  getMySummaries
} from "../controllers/summaryController.js";
const router = express.Router();
router.get(
  "/my",
  verifyToken,
  authorizeRoles("waiter"),
  getMySummaries
);
router.get("/submitted", verifyToken, authorizeRoles("manager"), getSubmitted);

router.put("/approve/:summaryId", verifyToken, authorizeRoles("manager"), approveSummary);
export default router;
