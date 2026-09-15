import { AssistanceMethod } from "../auth/auth.enums.js";

export interface Assistance {
    id: string;
    classId: string;
    professorId: string;
    dateAssistance: Date;
    startTime: string;
    endTime: string | null;
    method: AssistanceMethod;
    createdAt: Date;
}

export interface CreatedAssistance {
    classId: string;
    professorId: string;
    dateAssistance: Date;
    startTime: string;
    method: AssistanceMethod;
}

