CREATE TABLE IF NOT EXISTS Users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL CHECK (role IN ('admin_general', 'admin_education_entity', 'professor', 'student')),
    token_version INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    terms_and_conditions_accepted BOOLEAN NOT NULL DEFAULT FALSE,
    terms_and_conditions_accepted_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Education_entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Admin_general (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW() 
);

CREATE TABLE IF NOT EXISTS admin_education_entity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    education_entity_id UUID NOT NULL REFERENCES Education_entities(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Professors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    education_entity_id UUID NOT NULL REFERENCES Education_entities(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    educational_department VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    education_entity_id UUID NOT NULL REFERENCES Education_entities(id) ON DELETE CASCADE,
    professor_id UUID NOT NULL REFERENCES Professors(id) ON DELETE CASCADE,
    class_code VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    class_day VARCHAR(20) NOT NULL CHECK (class_day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    classroom VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    education_entity_id UUID NOT NULL REFERENCES Education_entities(id) ON DELETE CASCADE,
    educational_program VARCHAR(100) NOT NULL,
    identification_number VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Students_Classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    students_id UUID NOT NULL REFERENCES Students(id) ON DELETE CASCADE,
    class_id UUID NOT NULL REFERENCES Classes(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(students_id, class_id)
);

CREATE TABLE IF NOT EXISTS student_biometrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    students_id UUID NOT NULL REFERENCES Students(id) ON DELETE CASCADE,
    template_data BYTEA NOT NULL,
    device_info VARCHAR(200),
    registered_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Assistance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES Classes(id) ON DELETE CASCADE,
    professor_id UUID NOT NULL REFERENCES Professors(id) ON DELETE CASCADE,
    date_assistance DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    method VARCHAR(100) NOT NULL CHECK (method IN ('QR', 'QR_BIOMETRIC', 'MANUAL')),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE (class_id, date_assistance, method)
);

CREATE TABLE IF NOT EXISTS Attendance_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assistance_id UUID NOT NULL REFERENCES Assistance(id) ON DELETE CASCADE,
    students_id UUID NOT NULL REFERENCES Students(id) ON DELETE CASCADE,
    state_attendance VARCHAR(100) NOT NULL CHECK (state_attendance IN ('attended', 'no_attended', 'no_attended_excuse')),
    mac_address VARCHAR(100),
    geolocation_lat DECIMAL(10, 8),
    geolocation_lng DECIMAL(11, 8),
    biometric_verified BOOLEAN,
    possible_impersonation BOOLEAN DEFAULT FALSE,
    impersonation_reason VARCHAR(200),
    observations TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(assistance_id, students_id)
);

CREATE TABLE IF NOT EXISTS Tokens_recovery (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Terms_and_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    version VARCHAR(100) NOT NULL,
    accepted BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS Error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES Users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    error_message TEXT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);





