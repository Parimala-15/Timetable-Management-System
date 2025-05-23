-- Create database
CREATE DATABASE IF NOT EXISTS timetable_db;
USE timetable_db;
SET FOREIGN_KEY_CHECKS = 0;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'faculty', 'student') NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Faculty table
CREATE TABLE IF NOT EXISTS faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    designation VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    specialization VARCHAR(100),
    available_days SET('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') NOT NULL
) ENGINE=InnoDB;

-- Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    subject_code VARCHAR(20) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    slot CHAR(1) NOT NULL,
    lecture_hours INT NOT NULL DEFAULT 3,
    tutorial_hours INT NOT NULL DEFAULT 0,
    practical_hours INT NOT NULL DEFAULT 0,
    credits INT NOT NULL,
    department VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Rooms table
CREATE TABLE IF NOT EXISTS rooms (
    room_id VARCHAR(20) PRIMARY KEY,
    building VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    room_type ENUM('Lecture', 'Lab', 'Tutorial', 'Seminar') NOT NULL,
    equipment TEXT,
    is_air_conditioned BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB;

-- Class groups table
CREATE TABLE IF NOT EXISTS class_groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    class_in_charge_id INT,
    FOREIGN KEY (class_in_charge_id) REFERENCES faculty(faculty_id)
) ENGINE=InnoDB;

-- Timetable slots table
CREATE TABLE IF NOT EXISTS timetable_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') NOT NULL,
    period INT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_lunch BOOLEAN DEFAULT FALSE,
    is_break BOOLEAN DEFAULT FALSE,
    UNIQUE KEY (day, period)
) ENGINE=InnoDB;

-- Timetable entries table
CREATE TABLE IF NOT EXISTS timetable_entries (
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    slot_id INT NOT NULL,
    subject_code VARCHAR(20) NOT NULL,
    faculty_id INT NOT NULL,
    room_id VARCHAR(20) NOT NULL,
    group_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL DEFAULT '2023-2024',
    notes TEXT,
    FOREIGN KEY (slot_id) REFERENCES timetable_slots(slot_id),
    FOREIGN KEY (subject_code) REFERENCES subjects(subject_code),
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (group_id) REFERENCES class_groups(group_id)
) ENGINE=InnoDB;

DELETE FROM users WHERE username = 'admin'; 
-- Insert initial data
INSERT INTO users (username, password, name, role, email) VALUES 
('admin', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Admin User', 'admin', 'admin@college.edu');

INSERT INTO faculty (name, designation, department, email, phone, specialization, available_days) VALUES
('Mr. R. Sudharsanan', 'Assistant Professor', 'IT', 'sudharsanan@college.edu', '9876543210', 'Image Processing, AI', 'Monday,Tuesday,Wednesday,Thursday,Friday'),
('Dr. R. Kiruthiga', 'Professor', 'CSE', 'kiruthiga@college.edu', '8765432109', 'Algorithms, Data Structures', 'Monday,Wednesday,Friday'),
('Mrs. S. Padmapriya', 'Assistant Professor', 'Mathematics', 'padmapriya@college.edu', '7654321098', 'Probability, Statistics', 'Tuesday,Thursday'),
('Dr. B. Dwarakanathan', 'Associate Professor', 'IT', 'dwarakanathan@college.edu', '6543210987', 'Databases, Big Data', 'Monday,Friday'),
('Dr. Kulijeet Kaur', 'Assistant Professor', 'Humanities', 'kulijeet@college.edu', '5432109876', 'Human Values, Ethics', 'Thursday');

INSERT INTO subjects (subject_code, subject_name, slot, lecture_hours, tutorial_hours, practical_hours, credits, department) VALUES
('21MAB204T', 'Probability and Queuing Theory', 'A', 3, 1, 0, 4, 'Mathematics'),
('21CSC204J', 'Design and Analysis of Algorithms', 'E', 3, 0, 2, 4, 'IT'),
('21CSC205P', 'Database Management Systems', 'B', 3, 1, 0, 4, 'IT'),
('21CSE251T', 'Digital Image Processing', 'D', 2, 1, 0, 3, 'IT'),
('21LEM202T', 'Universal Human Values', 'P', 3, 0, 0, 3, 'Humanities'),
('21PDH201T', 'Social Engineering', 'P', 3, 0, 0, 3, 'Humanities'), -- Added missing subject
('21CSE267T', 'Statistics for ML', 'C', 3, 0, 0, 3, 'IT'), -- Added missing subject
('21CSE268T', 'Bio Inspired Computing', 'F', 3, 0, 0, 3, 'IT'), -- Added missing subject
('21CSC206T', 'Artificial Intelligence', 'G', 3, 0, 0, 3, 'IT'); -- Added missing subject

INSERT INTO rooms (room_id, building, capacity, room_type, equipment, is_air_conditioned) VALUES
('BMS/804', 'IT Block', 60, 'Lecture', 'Projector, Whiteboard', TRUE),
('MATH/301', 'Math Block', 50, 'Lecture', 'Whiteboard', FALSE),
('LAB/702', 'IT Block', 30, 'Lab', 'Computers, Projector', TRUE),
('HUM/101', 'Humanities Block', 40, 'Seminar', 'Whiteboard', FALSE);

INSERT INTO class_groups (group_name, department, academic_year, class_in_charge_id) VALUES
('IT-A', 'IT', '2023-2024', 1);

-- Timetable slots (8 periods per day, Monday to Friday)
INSERT INTO timetable_slots (day, period, start_time, end_time, is_lunch) VALUES
-- Monday
('Monday', 1, '08:00:00', '08:50:00', FALSE),
('Monday', 2, '08:50:00', '09:40:00', FALSE),
('Monday', 3, '09:50:00', '10:40:00', FALSE),
('Monday', 4, '10:40:00', '11:30:00', FALSE),
('Monday', 5, '12:20:00', '13:10:00', TRUE), -- Lunch
('Monday', 6, '13:10:00', '14:00:00', FALSE),
('Monday', 7, '14:00:00', '14:50:00', FALSE),
('Monday', 8, '14:50:00', '15:40:00', FALSE),

-- Tuesday to Friday (similar pattern)
('Tuesday', 1, '08:00:00', '08:50:00', FALSE),
('Tuesday', 2, '08:50:00', '09:40:00', FALSE),
('Tuesday', 3, '09:50:00', '10:40:00', FALSE),
('Tuesday', 4, '10:40:00', '11:30:00', FALSE),
('Tuesday', 5, '12:20:00', '13:10:00', TRUE),
('Tuesday', 6, '13:10:00', '14:00:00', FALSE),
('Tuesday', 7, '14:00:00', '14:50:00', FALSE),
('Tuesday', 8, '14:50:00', '15:40:00', FALSE),

('Wednesday', 1, '08:00:00', '08:50:00', FALSE),
('Wednesday', 2, '08:50:00', '09:40:00', FALSE),
('Wednesday', 3, '09:50:00', '10:40:00', FALSE),
('Wednesday', 4, '10:40:00', '11:30:00', FALSE),
('Wednesday', 5, '12:20:00', '13:10:00', TRUE),
('Wednesday', 6, '13:10:00', '14:00:00', FALSE),
('Wednesday', 7, '14:00:00', '14:50:00', FALSE),
('Wednesday', 8, '14:50:00', '15:40:00', FALSE),

('Thursday', 1, '08:00:00', '08:50:00', FALSE),
('Thursday', 2, '08:50:00', '09:40:00', FALSE),
('Thursday', 3, '09:50:00', '10:40:00', FALSE),
('Thursday', 4, '10:40:00', '11:30:00', FALSE),
('Thursday', 5, '12:20:00', '13:10:00', TRUE),
('Thursday', 6, '13:10:00', '14:00:00', FALSE),
('Thursday', 7, '14:00:00', '14:50:00', FALSE),
('Thursday', 8, '14:50:00', '15:40:00', FALSE),

('Friday', 1, '08:00:00', '08:50:00', FALSE),
('Friday', 2, '08:50:00', '09:40:00', FALSE),
('Friday', 3, '09:50:00', '10:40:00', FALSE),
('Friday', 4, '10:40:00', '11:30:00', FALSE),
('Friday', 5, '12:20:00', '13:10:00', TRUE),
('Friday', 6, '13:10:00', '14:00:00', FALSE),
('Friday', 7, '14:00:00', '14:50:00', FALSE),
('Friday', 8, '14:50:00', '15:40:00', FALSE);

-- Timetable entries (fixed version)
INSERT INTO timetable_entries (slot_id, subject_code, faculty_id, room_id, group_id, notes) VALUES
-- Monday
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=1), '21CSE251T', 1, 'BMS/804', 1, 'Digital Image Processing'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=2), '21CSC206T', 4, 'LAB/702', 1, 'AI Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=3), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Practical'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=4), '21MAB204T', 3, 'MATH/301', 1, 'Probability Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=6), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=7), '21MAB204T', 3, 'MATH/301', 1, 'Probability Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Monday' AND period=8), '21CSC206T', 4, 'BMS/804', 1, 'AI Theory'),

-- Tuesday
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=1), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Practical'),
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=2), '21LEM202T', 5, 'HUM/101', 1, 'Human Values'),
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=3), '21CSC204J', 2, 'LAB/702', 1, 'DAA Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=6), '21CSC204J', 2, 'BMS/804', 1, 'DAA Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=7), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),
((SELECT slot_id FROM timetable_slots WHERE day='Tuesday' AND period=8), '21CSC206T', 4, 'LAB/702', 1, 'AI Lab'),

-- Wednesday
((SELECT slot_id FROM timetable_slots WHERE day='Wednesday' AND period=1), '21CSC204J', 2, 'BMS/804', 1, 'DAA Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Wednesday' AND period=3), '21CSE251T', 1, 'BMS/804', 1, 'Image Processing'),
((SELECT slot_id FROM timetable_slots WHERE day='Wednesday' AND period=4), '21MAB204T', 3, 'MATH/301', 1, 'Probability Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Wednesday' AND period=6), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),
((SELECT slot_id FROM timetable_slots WHERE day='Wednesday' AND period=7), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),

-- Thursday
((SELECT slot_id FROM timetable_slots WHERE day='Thursday' AND period=1), '21CSC204J', 2, 'BMS/804', 1, 'DAA Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Thursday' AND period=3), '21PDH201T', 5, 'HUM/101', 1, 'Social Engineering'), -- Fixed with valid faculty and room
((SELECT slot_id FROM timetable_slots WHERE day='Thursday' AND period=4), '21MAB204T', 3, 'MATH/301', 1, 'Probability Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Thursday' AND period=6), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),
((SELECT slot_id FROM timetable_slots WHERE day='Thursday' AND period=7), '21CSC205P', 3, 'LAB/702', 1, 'DBMS Lab'),

-- Friday
((SELECT slot_id FROM timetable_slots WHERE day='Friday' AND period=1), '21LEM202T', 5, 'HUM/101', 1, 'Human Values'),
((SELECT slot_id FROM timetable_slots WHERE day='Friday' AND period=2), '21CSC204J', 2, 'BMS/804', 1, 'DAA Theory'),
((SELECT slot_id FROM timetable_slots WHERE day='Friday' AND period=6), '21CSC204J', 2, 'LAB/702', 1, 'DAA Lab'),
((SELECT slot_id FROM timetable_slots WHERE day='Friday' AND period=7), '21CSE251T', 1, 'BMS/804', 1, 'Image Processing');

SET FOREIGN_KEY_CHECKS = 1;