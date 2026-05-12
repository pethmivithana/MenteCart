import { User, IUser } from '../models/User';
import mongoose from 'mongoose';

/**
 * Data access layer for User collection.
 * All DB queries are isolated here — services never touch models directly.
 */
export class UserRepository {
  async findByEmail(email: string, withPassword = false): Promise<IUser | null> {
    const query = User.findOne({ email: email.toLowerCase() });
    if (withPassword) query.select('+passwordHash');
    return query.exec();
  }

  async findById(id: string): Promise<IUser | null> {
    if (!mongoose.Types.ObjectId.isValid(id)) return null;
    return User.findById(id).exec();
  }

  async create(data: { name: string; email: string; passwordHash: string }): Promise<IUser> {
    const user = new User(data);
    return user.save();
  }

  async existsByEmail(email: string): Promise<boolean> {
    const count = await User.countDocuments({ email: email.toLowerCase() });
    return count > 0;
  }
}

export const userRepository = new UserRepository();
