import { DayWeek } from "../auth/auth.enums.js";

export interface Class {
    id: string;
    educationEntityId: string;
    professorId: string;
    classCode: string;
    name: string
    classDay: DayWeek;
    startTime: string;
    endTime: string;
    classroom: string;
    isActive: boolean;
    createdAt: Date;
    updateAt: Date;
}

export interface CreateClassDTO {
    educationEntityId: string;
    professorId: string;
    classCode: string;
    name: string
    classDay: DayWeek;
    startTime: string;
    endTime: string;
    classroom: string;
}

export interface UpdateClassDTO{
    name?: string
    classCode?: string;
    classDay?: DayWeek;
    startTime?: string;
    endTime?: string;
    classroom?: string;
}

export interface ClassFilters {
    educationEntityId?: string;
    classDay?: string;
    search?: string; 
}

