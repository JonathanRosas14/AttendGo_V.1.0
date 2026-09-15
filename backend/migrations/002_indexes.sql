CREATE INDEX IF NOT EXISTS idx_users_email ON Users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON Users(role);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON Users(is_active);

CREATE INDEX IF NOT EXISTS idx_ee_country ON Education_entities(country);
CREATE INDEX IF NOT EXISTS idx_ee_city ON Education_entities(city);
CREATE INDEX IF NOT EXISTS idx_ee_is_active ON Education_entities(is_active);

CREATE INDEX IF NOT EXISTS idx_ag_user_id ON Admin_general(user_id);

CREATE INDEX IF NOT EXISTS idx_aee_user_id ON admin_education_entity(user_id);
CREATE INDEX IF NOT EXISTS idx_aee_education_entity_id ON admin_education_entity(education_entity_id);

CREATE INDEX IF NOT EXISTS idx_p_user_id ON Professors(user_id);
CREATE INDEX IF NOT EXISTS idx_p_education_entity_id ON Professors(education_entity_id);
CREATE INDEX IF NOT EXISTS idx_p_is_active ON Professors(is_active);

CREATE INDEX IF NOT EXISTS idx_c_education_entity_id ON Classes(education_entity_id);
CREATE INDEX IF NOT EXISTS idx_c_professor_id ON Classes(professor_id);
CREATE INDEX IF NOT EXISTS idx_c_class_day ON Classes(class_day);
CREATE INDEX IF NOT EXISTS idx_c_class_code ON Classes(class_code);
CREATE INDEX IF NOT EXISTS idx_c_is_active ON Classes(is_active);

CREATE INDEX IF NOT EXISTS idx_s_user_id ON Students(user_id);
CREATE INDEX IF NOT EXISTS idx_s_education_entity_id ON Students(education_entity_id);
CREATE INDEX IF NOT EXISTS idx_s_identification_number ON Students(identification_number);
CREATE INDEX IF NOT EXISTS idx_s_is_active ON Students(is_active);

CREATE INDEX IF NOT EXISTS idx_sc_students_id ON Students_Classes(students_id);
CREATE INDEX IF NOT EXISTS idx_sc_class_id ON Students_Classes(class_id);

CREATE INDEX IF NOT EXISTS idx_sb_students_id ON student_biometrics(students_id);

CREATE INDEX IF NOT EXISTS idx_a_class_id ON Assistance(class_id);
CREATE INDEX IF NOT EXISTS idx_a_professor_id ON Assistance(professor_id);
CREATE INDEX IF NOT EXISTS idx_a_date_assistance ON Assistance(date_assistance);
CREATE INDEX IF NOT EXISTS idx_a_method ON Assistance(method);

CREATE INDEX IF NOT EXISTS idx_ad_assistance_id ON Attendance_details(assistance_id);
CREATE INDEX IF NOT EXISTS idx_ad_students_id ON Attendance_details(students_id);
CREATE INDEX IF NOT EXISTS idx_ad_state_attendance ON Attendance_details(state_attendance);
CREATE INDEX IF NOT EXISTS idx_ad_possible_impersonation ON Attendance_details(possible_impersonation);

CREATE INDEX IF NOT EXISTS idx_tr_user_id ON Tokens_recovery(user_id);
CREATE INDEX IF NOT EXISTS idx_tr_code ON Tokens_recovery(code);
CREATE INDEX IF NOT EXISTS idx_tr_expires_at ON Tokens_recovery(expires_at);

CREATE INDEX IF NOT EXISTS idx_ses_user_id ON Sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_ses_token_hash ON Sessions(token_hash);
CREATE INDEX IF NOT EXISTS idx_ses_expires_at ON Sessions(expires_at);

CREATE INDEX IF NOT EXISTS idx_tc_user_id ON Terms_and_conditions(user_id);

CREATE INDEX IF NOT EXISTS idx_el_user_id ON Error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_el_action ON Error_logs(action);
CREATE INDEX IF NOT EXISTS idx_el_created_at ON Error_logs(created_at);