export interface TokenRecovery{
    id: string;
    userId: string;
    code: string;
    expiresAt: Date;
    used: boolean;
    createdAt: Date;
}

