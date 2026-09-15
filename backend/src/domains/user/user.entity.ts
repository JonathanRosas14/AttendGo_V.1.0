import { Role } from '../auth/auth.enums.js';

export interface User {
    id: string; //UUID
    email: string;
    password: string; //bycript hash
    role: Role;
    tokenVersion: number;
    isActive: boolean;
    mustChangePassword: boolean;
    termsAndConditionsAccepted: boolean;
    termsAndConditionsAcceted: Date | null;
    createdAt: Date;
    updatedAt: Date;
}

export interface CreateUserDTO {
    email: string;
    password: string; //bycript hash
    role: Role;
}

export interface UserResponse {
    id: string; //UUID
    email: string;
    role: Role;
    isActive: boolean;
    mustChangePassword: boolean;
    termsAndConditionsAccepted: boolean;
}

