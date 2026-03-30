import express from 'express';
import dotenv from 'dotenv';
import bodyParser from 'body-parser';
import cors from 'cors';
import connectDB from './config/db.js';

// Routes
import staffRoutes from './routes/staffRoutes.js';
import userRoutes from './routes/userRoutes.js';
import foodRoutes from './routes/foodRoutes.js';
import tableRoutes from './routes/tableRoutes.js';
import cartRoutes from "./routes/cartRoutes.js";
import discountRoutes from "./routes/discountRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import reservationRoutes from "./routes/reservationRoutes.js";
import shiftRoutes from './routes/shiftRoutes.js';
import serveRoutes from "./routes/serveRoutes.js";
import summaryRoutes from "./routes/summaryRoutes.js";
import dashboardRouter from "./routes/dashboardRouter.js";
dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads'));

// Connect to MongoDB
connectDB();

// Test endpoint
app.get('/', (req, res) => {
  res.send('Server is running');
});

// Routes
app.use('/api/staff', staffRoutes);
app.use('/api/users', userRoutes);
app.use('/api/foods', foodRoutes);
app.use('/api/tables', tableRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/discounts", discountRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/reservations", reservationRoutes);
app.use('/api/shifts', shiftRoutes);
app.use("/api/serve-sessions", serveRoutes);
app.use("/api/summary", summaryRoutes);
app.use("/api/dashboard", dashboardRouter);

// Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on '0.0.0.0' port ${PORT}`);
});
