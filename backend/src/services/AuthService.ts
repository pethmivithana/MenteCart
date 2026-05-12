import jwt from 'jsonwebtoken';
import { env } from '../config/env';
import { userRepository } from '../repositories/UserRepository';
import { ConflictError, UnauthorizedError } from '../utils/ApiError';
import { IUser } from '../models/User';
import { JwtPayload } from '../types';

export interface SignupDto {
  name: string;
  email: string;
  password: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export interface AuthResult {
  user: IUser;
  accessToken: string;
}

/**
 * Handles all authentication business logic.
 * Password hashing is delegated to the User model pre-save hook.
 */
export class AuthService {
  /**
   * Register a new user. Throws ConflictError if email already exists.
   */
  async signup(dto: SignupDto): Promise<AuthResult> {
    const exists = await userRepository.existsByEmail(dto.email);
    if (exists) {
      throw new ConflictError('An account with this email already exists', 'EMAIL_TAKEN');
    }

    // The model's pre-save hook will bcrypt-hash passwordHash
    const user = await userRepository.create({
      name: dto.name,
      email: dto.email,
      passwordHash: dto.password, // Raw password — hashed in pre-save
    });

    const accessToken = this.generateToken(user);
    return { user, accessToken };
  }

  /**
   * Validate credentials and return a JWT.
   */
  async login(dto: LoginDto): Promise<AuthResult> {
    const user = await userRepository.findByEmail(dto.email, true);
    if (!user) {
      throw new UnauthorizedError('Invalid email or password');
    }

    const isMatch = await user.comparePassword(dto.password);
    if (!isMatch) {
      throw new UnauthorizedError('Invalid email or password');
    }

    if (!user.isActive) {
      throw new UnauthorizedError('Your account has been deactivated');
    }

    const accessToken = this.generateToken(user);
    return { user, accessToken };
  }

  /**
   * Fetch the authenticated user's profile.
   */
  async getMe(userId: string): Promise<IUser> {
    const user = await userRepository.findById(userId);
    if (!user) throw new UnauthorizedError('User not found');
    return user;
  }

  private generateToken(user: IUser): string {
    const payload: JwtPayload = {
      userId: user._id.toString(),
      email: user.email,
      role: user.role,
    };
    return jwt.sign(payload, env.JWT_SECRET, {
      expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'],
    });
  }
}

export const authService = new AuthService();
