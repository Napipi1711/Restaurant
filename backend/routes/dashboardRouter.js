import express from "express";
import { getRevenueSummary } from "../controllers/dashboardController.js";
import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";

const router = express.Router();

router.get("/revenue-summary", verifyToken, authorizeRoles("manager"), getRevenueSummary);

export default router;
