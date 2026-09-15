export interface AdminGeneral {
    id: string;
    userId: string;
    name: string;
    phone: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface CreateAdminGeneralDTO {
    userId: string;
    name: string;
    phone: string;
}