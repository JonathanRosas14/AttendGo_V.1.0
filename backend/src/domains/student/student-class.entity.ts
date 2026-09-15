export interface StudentClass{
    id: string;
    studentsId: string;
    classId: string;
    addedAt: Date;
}

export interface EnrollStudentDTO{
    studentId: string;
    classId: string[];
}

