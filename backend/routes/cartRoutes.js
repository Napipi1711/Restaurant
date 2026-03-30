import express from "express";
import {
    getCart,
    addItem,
    updateItem,
    removeItem,
    checkout
} from "../controllers/cartController.js";
import { verifyToken } from "../middlewares/userMiddleware.js";

const router = express.Router();


router.get("/", verifyToken, getCart);


router.post("/add", verifyToken, addItem);


router.put("/update", verifyToken, updateItem);


router.delete("/remove", verifyToken, removeItem);


router.post("/checkout", verifyToken, checkout);

export default router;
