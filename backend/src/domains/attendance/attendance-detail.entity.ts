import { AttendanceStatus } from "../auth/auth.enums.js";

export interface AttendanceDetail {
    id: string;
    assistanceId: string;
    studentsId: string;
    stateAttendance: AttendanceStatus;
    macAddress: string | null;
    geolocationLat: number | null;
    geolocationLng: number | null;
    biometricVerified: boolean | null;
    possibleImpersonation: boolean;
    impersonationReason: string | null;
    observations: string | null;
    createdAt: Date;
    updateAt: Date;
}

export interface RegisterQRAttendanceDTO {
    assistanceId: string;
    studentsId: string;
    macAddress?: string;
    geolocationLat: number;
    geolocationLng: number;
    biometricVerified?: boolean;
}

export interface RegisterManualAttendanceDTO {
    classId: string;
    records: {
        studentsId: string;
        state: AttendanceStatus;
    }
}