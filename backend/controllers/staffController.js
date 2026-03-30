import User from '../models/UserModels.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const register = async (req, res) => {
    try {
        const { username, email, password, phone } = req.body;

        if (!username || !email || !password) {
            return res.status(400).json({ msg: "Missing required fields" });
        }

        const exist = await User.findOne({ email });
        if (exist) {
            return res.status(400).json({ msg: "User already exists" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const user = await User.create({
            username,
            email,
            password: hashedPassword,
            phone,
            role: 'waiter'
        });

        res.status(201).json({
            msg: "User created successfully",
            user: {
                id: user._id,
                username: user.username,
                role: user.role
            }
        });
    } catch (err) {
        console.error("REGISTER ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

const login = async (req, res) => {
    try {
        console.log("LOGIN REQUEST");
        console.log("Headers:", req.headers);
        console.log("Body:", req.body);

        const { email, password } = req.body;

        if (!email || !password) {
            console.log(" Missing email or password");
            return res.status(400).json({ msg: "Email and password are required" });
        }

        const user = await User.findOne({ email }).select('+password');
        console.log(" FOUND USER:", user ? user.email : null);

        if (!user) {
            return res.status(401).json({ msg: "Invalid email or password" });
        }

        console.log(" USER ROLE:", user.role);
        console.log(" ACTIVE:", user.active);

        if (!user.active) {
            return res.status(403).json({ msg: "Account is disabled" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        console.log(" PASSWORD MATCH:", isMatch);

        if (!isMatch) {
            return res.status(401).json({ msg: "Invalid email or password" });
        }

        const token = jwt.sign(
            { id: user._id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        console.log("LOGIN SUCCESS");
        console.log("TOKEN:", token);

        res.json({
            token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                phone: user.phone
            }
        });
    } catch (err) {
        console.error(" LOGIN ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

const getAll = async (req, res) => {
    try {
        if (req.user.role !== 'manager') {
            return res.status(403).json({ msg: "Access denied" });
        }

        const users = await User.find({ role: 'waiter' }).select('-password');
        res.json(users);
    } catch (err) {
        console.error("GET ALL USERS ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

const getUserById = async (req, res) => {
    try {
        const { role, id: userId } = req.user;
        const targetId = req.params.id;

        if (role !== 'manager' && userId !== targetId) {
            return res.status(403).json({ msg: "Access denied" });
        }

        const user = await User.findById(targetId).select('-password');
        if (!user) {
            return res.status(404).json({ msg: "User not found" });
        }

        if (role === 'manager' && user.role !== 'waiter') {
            return res.status(403).json({ msg: "Access denied" });
        }

        res.json(user);
    } catch (err) {
        console.error("GET USER BY ID ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

const update = async (req, res) => {
    try {
        const { role: userRole, id: userId } = req.user;
        const targetId = req.params.id;

        if (userRole !== 'manager' && userId !== targetId) {
            return res.status(403).json({ msg: "Forbidden" });
        }

        const updates = {};
        const { username, email, phone, role, active } = req.body;

        if (username) updates.username = username;
        if (email) updates.email = email;
        if (phone) updates.phone = phone;

        if (userRole === 'manager') {
            if (role) updates.role = role;
            if (typeof active === 'boolean') updates.active = active;
        }

        const updatedUser = await User
            .findByIdAndUpdate(targetId, updates, { new: true, runValidators: true })
            .select('-password');

        if (!updatedUser) {
            return res.status(404).json({ msg: "User not found" });
        }

        res.json({ msg: "User updated successfully", user: updatedUser });
    } catch (err) {
        console.error("UPDATE USER ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

const deleteUser = async (req, res) => {
    try {
        if (req.user.role !== 'manager') {
            return res.status(403).json({ msg: "Forbidden" });
        }

        const deletedUser = await User.findByIdAndDelete(req.params.id);
        if (!deletedUser) {
            return res.status(404).json({ msg: "User not found" });
        }

        res.json({ msg: "User deleted successfully" });
    } catch (err) {
        console.error("DELETE USER ERROR:", err);
        res.status(500).json({ msg: "Server error" });
    }
};

export default {
    register,
    login,
    getAll,
    getUserById,
    update,
    delete: deleteUser
};
