export interface ErrorLog{
    id: string;
    userId: string | null;
    action: string;
    errorMessage: string;
    ipAddress: string | null;
    userAgent: string | null;
    createdAt: Date;
}