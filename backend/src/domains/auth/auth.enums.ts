export enum Role {
    ADMIN_GENERAL = 'admin_general',
    ADMIN_EDUCATION_ENTITY = 'admin_education_entity',
    PROFESSOR = "professor",
    STUDENT = 'student',
}

export enum DayWeek{
    MONDAY = 'Monday',
    TUESDAY = 'Tuesday',
    WEDNESDAY = 'Wednesday',
    THURSDAY = 'Thursday',
    FRIDAY = 'Friday',
    SATURDAY = 'Saturday',
    SUNDAY = 'Sunday',
}

export enum AssistanceMethod{
    QR = 'QR',
    QR_BIOMETRIC = 'QR_BIOMETRIC',
    MANUAL = 'MANUAL'
}

export enum AttendanceStatus{
    ATTENDED = 'attended',
    NO_ATTENDED = 'no_attended',
    NO_ATTENDED_EXCUSE = 'no_attended_excuse'
}
