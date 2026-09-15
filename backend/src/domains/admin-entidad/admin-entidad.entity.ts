export interface AdminEducationEntity {
    id: string;
    userId: string;
    educationEntityId: string;
    name: string;
    phone: string;
    createdAt: Date;
    updatedAt: Date;
}

export interface CreateAdminEducationEntityDTO{
    userId: string;
    educationEntityId: string;
    name: string;
    phone: string;
}