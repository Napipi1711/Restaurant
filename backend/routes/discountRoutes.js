import express from "express";
import {
    createDiscount,
    getDiscounts,
    getDiscountByCode,
    checkDiscount
} from "../controllers/discountController.js";
import { verifyToken, authorizeRoles } from "../middlewares/userMiddleware.js";

const router = express.Router();

router.post("/", verifyToken, authorizeRoles("manager"), createDiscount);


router.get("/", getDiscounts);
router.post("/check", checkDiscount);

router.get("/:code", getDiscountByCode);

export default router;
