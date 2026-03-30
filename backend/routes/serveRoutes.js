import express from "express";
import {
  addFoodToSession,
  checkoutSession,
  getServeSessionDetail,
  removeFoodFromSession,
  updateFoodQuantity
} from "../controllers/serveController.js";

import {
  verifyToken,
  authorizeRoles
} from "../middlewares/userMiddleware.js";

const router = express.Router();

router.post(
  "/:reservationId/add-food",
  verifyToken,
  authorizeRoles("waiter"),
  addFoodToSession
);


router.delete(
  "/:reservationId/remove-food",
  verifyToken,
  authorizeRoles("waiter"),
  removeFoodFromSession
);

router.patch(
  "/:reservationId/update-food",
  verifyToken,
  authorizeRoles("waiter"),
  updateFoodQuantity
);

// Xem chi tiết session
router.get(
  "/:reservationId/detail",
  verifyToken,
  authorizeRoles("waiter"),
  getServeSessionDetail
);

// Checkout session
router.post(
  "/:reservationId/checkout",
  verifyToken,
  authorizeRoles("waiter"),
  checkoutSession
);

export default router;
