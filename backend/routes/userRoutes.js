import express from "express";
import { register, login, getMe } from "../controllers/userController.js";
import { verifyToken } from "../middlewares/userMiddleware.js";
const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", verifyToken, getMe);

export default router;
