export interface StudentBiometric {
    id: string;
    studentId: string;
    templateData: Buffer;
    deviceInfo: string | null;
    registeredAt: Date;
}

