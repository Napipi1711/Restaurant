import express from 'express';
import userController from '../controllers/staffController.js';
import { verifyToken, authorizeRoles } from '../middlewares/userMiddleware.js';

const router = express.Router();

// PUBLIC
router.post('/register', userController.register);
router.post('/login', userController.login);

// PROTECTED
router.get('/', verifyToken, authorizeRoles('manager'), userController.getAll);
router.get('/:id', verifyToken, userController.getUserById);
router.put('/:id', verifyToken, userController.update);
router.delete('/:id', verifyToken, authorizeRoles('manager'), userController.delete);

export default router;
