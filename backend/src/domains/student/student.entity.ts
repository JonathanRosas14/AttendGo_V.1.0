export interface Student {
    id: string;
    userId: string;
    educationEntityId: string;
    educationalProgram: string;
    identificationNumber: string;
    name: string;
    phone: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}

export interface CreateStudentDTO{
    userId: string;
    educationEntityId: string;
    educationalProgram: string;
    identificationNumber: string;
    name: string;
    phone: string;
}

export interface UpdateStudentDTO {
    name?: string;
    phone?: string;
    educationalProgram?: string;
}

export interface StudentFilters {
    educationEntityId?: string;
    educationalProgram?: string;
    search?: string;
}
