import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
    {
        username: { type: String, required: true, unique: true },
        email: { type: String, required: true, unique: true },
        password: {
            type: String, required: true,
        },
        role: {type: String, enum: ['waiter', 'manager', 'user'], required: true},
        phone: {type: String,default: '',
        },
        active: {type: Boolean,default: true,
        },
    },{ timestamps: true }
);
const User = mongoose.model('User', userSchema);
export default User;
