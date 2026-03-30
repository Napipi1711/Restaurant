import jwt from 'jsonwebtoken';
import Shift from "../models/shiftModel.js";
import mongoose from "mongoose";

export const verifyToken = (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ msg: "No token" });
    }

    const token = authHeader.split(' ')[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // { id, role }
        next();
    } catch (err) {
        return res.status(401).json({ msg: "Invalid token" });
    }
};


export const authorizeRoles = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ msg: "Access denied" });
        }
        next();
    };
};

export const requireWorkingWaiter = async (req, res, next) => {
    try {
        if (!req.user?.id) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        const today = new Date().toISOString().slice(0, 10);

        const shift = await Shift.findOne({
            dayStr: today,
            waitersStatus: {
                $elemMatch: {
                    waiter: new mongoose.Types.ObjectId(req.user.id),
                    status: "working"
                }
            }
        });

        if (!shift) {
            return res.status(400).json({ message: "Nhân viên không đang làm việc" });
        }

        next();
    } catch (err) {
        console.error("requireWorkingWaiter ERROR:", err);
        res.status(500).json({ message: "Server error" });
    }
};