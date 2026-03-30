import express from "express";
import {
    getAllOrders,
    getOrdersByUser,
    getOrderById,
    updateOrderStatus
} from "../controllers/orderController.js";
import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";

const router = express.Router();


router.get("/my-orders", verifyToken, getOrdersByUser);


router.get("/", verifyToken, authorizeRoles("manager"), getAllOrders);


router.get("/:id", verifyToken, getOrderById);


router.put("/:id/status", verifyToken, authorizeRoles("manager"), updateOrderStatus);

export default router;

