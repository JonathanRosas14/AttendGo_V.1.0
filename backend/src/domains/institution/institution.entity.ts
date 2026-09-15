export interface EducationEntity {
    id: string;
    name: string;
    country: string;
    city: string; 
    address: string;
    phone: string;
    email: string; 
    is_active: boolean;
    created_at: Date; 
    updated_at: Date;
}

export interface CreateEducationEntityDTO {
    name: string;
    country: string;
    city: string; 
    address: string;
    phone: string;
    email: string;
}

export interface UpdatedEducationEntityDTO {
    name?: string;
    country?: string;
    city?: string; 
    address?: string;
    phone?: string;
    email?: string;
}

export interface EducationEntityFilters {
    country?: string;
    city?: string;
    search?: string; 
}