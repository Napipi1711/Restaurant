import express from "express";
import { addTable, listTables, updateTable, removeTable } from "../controllers/tableController.js";

const tableRoutes = express.Router();


tableRoutes.post("/add", addTable);


tableRoutes.get("/list", listTables);


tableRoutes.put("/update/:id", updateTable);


tableRoutes.delete("/remove/:id", removeTable);

export default tableRoutes;
