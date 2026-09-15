export interface Professor {
    id: string;
    userId: string
    educationEntityId: string;
    name: string;
    phone: string;
    educationalDepartment: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}

export interface CreateProfessorDTO {
    userId: string
    educationEntityId: string;
    name: string;
    phone: string;
    educationalDepartment: string;
}

export interface updatedProfessorDTO {
    name?: string;
    phone?: string;
    educationalDepartment?: string;
}

export interface ProfessorFilters {
    educationEntityId?: string;
    search?: string;
}