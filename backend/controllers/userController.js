import User from "../models/UserModels.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";


export const register = async (req, res) => {
  try {
    console.log(" REGISTER BODY:", req.body);

    const { username, email, password, phone } = req.body;

    if (!username || !email || !password) {
      console.warn(" Missing fields in register:", req.body);
      return res.status(400).json({ msg: "Missing required fields" });
    }

    const exist = await User.findOne({ email });
    if (exist) {
      console.warn(" User already exists:", email);
      return res.status(400).json({ msg: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    console.log(" Hashed password:", hashedPassword);

    const user = await User.create({
      username,
      email,
      password: hashedPassword,
      phone,
      role: "user",
    });

    console.log(" User created:", user);

    res.status(201).json({
      msg: "User created successfully",
      user: {
        id: user._id,
        username: user.username,
        role: user.role,
      },
    });
  } catch (err) {
    console.error(" USER REGISTER ERROR:", err);
    res.status(500).json({ msg: "Server error" });
  }
};


export const login = async (req, res) => {
  try {
    console.log(" LOGIN BODY:", req.body);

    const { email, password } = req.body;

    if (!email || !password) {
      console.warn(" Missing email or password:", req.body);
      return res.status(400).json({ msg: "Missing email or password" });
    }

    // Bỏ role cứng, login mọi loại user
    const user = await User.findOne({ email });
    if (!user) {
      console.warn(" User not found:", email);
      return res.status(400).json({ msg: "User not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    console.log(" Password match:", isMatch);

    if (!isMatch) {
      console.warn(" Invalid password for user:", email);
      return res.status(400).json({ msg: "Invalid credentials" });
    }

    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    console.log(" User logged in:", user._id);
    console.log(" JWT token:", token);
    console.log(" User role:", user.role);

    res.status(200).json({
      msg: "Login successful",
      token,
      user: {
        id: user._id,
        username: user.username,
        role: user.role,
      },
    });
  } catch (err) {
    console.error(" USER LOGIN ERROR:", err);
    res.status(500).json({ msg: "Server error" });
  }
};


export const getMe = async (req, res) => {
  try {
    console.log(" GET ME USER ID from token:", req.user?.id);

    const user = await User.findById(req.user?.id).select("-password");
    if (!user) {
      console.warn(" User not found:", req.user?.id);
      return res.status(404).json({ msg: "User not found" });
    }

    console.log(" GET ME result:", user);
    res.status(200).json(user);
  } catch (err) {
    console.error(" GET ME ERROR:", err);
    res.status(500).json({ msg: "Server error" });
  }
};
