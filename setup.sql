-- Step 1: Create the Database
CREATE DATABASE IF NOT EXISTS timetable_db;
USE timetable_db;

-- Step 2: Create the Teachers Table
CREATE TABLE IF NOT EXISTS teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL
);

-- Step 3: Create the Subjects Table
CREATE TABLE IF NOT EXISTS subjects (
    code VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    mne VARCHAR(10),
    periods_as_per_syllabus INT NOT NULL,
    credits INT NOT NULL,
    lecture_hours INT NOT NULL,
    lab_hours INT NOT NULL
);

-- Step 4: Create the Timetable Table
CREATE TABLE IF NOT EXISTS timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day VARCHAR(10) NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    subject_code VARCHAR(20),
    teacher_id INT,
    room_no VARCHAR(20),
    FOREIGN KEY (subject_code) REFERENCES subjects(code) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Step 5: Insert Sample Data into Teachers Table
INSERT INTO teachers (id, name, subject) VALUES
(1, 'Dr. R. Kiruthiga', 'Design and Analysis of Algorithms'),
(2, 'Dr. B. Dwarakanathan', 'Database Management Systems'),
(3, 'Dr. R. Deeptha', 'Artificial Intelligence'),
(4, 'Mrs. S. Padmapriya', 'Probability and Queuing Theory'),
(5, 'Dr. M. Latha', 'Digital Image Processing'),
(6, 'Mrs. MadhuLatha', 'Social Engineering'),
(7, 'Eda Evangilin', 'Critical & Creative Thinking Skills'),
(8, 'Kulijeet Kaur', 'Universal Human Values')
ON DUPLICATE KEY UPDATE name = VALUES(name), subject = VALUES(subject);



-- Step 6: Insert Sample Data into Subjects Table
INSERT INTO subjects (code, name, mne, periods_as_per_syllabus, credits, lecture_hours, lab_hours) VALUES
('21MAB204T', 'Probability and Queuing Theory', 'PQT', 3, 4, 3, 0),
('21CSE204J', 'Design and Analysis of Algorithms', 'DAA', 3, 4, 3, 0),
('21CSE205P', 'Database Management Systems', 'DBMS', 3, 4, 3, 0),
('21CSE206T', 'Artificial Intelligence', 'AI', 2, 3, 2, 1),
('21CSE251T', 'Digital Image Processing', 'DIP', 2, 3, 2, 1),
('21PDH201T', 'Social Engineering', 'SE', 2, 2, 0, 2),
('21PDM202L', 'Critical & Creative Thinking Skills', 'CCT', 0, 2, 0, 2),
('21LEM202T', 'Universal Human Values', 'UHV', 3, 3, 3, 0)
ON DUPLICATE KEY UPDATE name = VALUES(name), mne = VALUES(mne), periods_as_per_syllabus = VALUES(periods_as_per_syllabus), credits = VALUES(credits), lecture_hours = VALUES(lecture_hours), lab_hours = VALUES(lab_hours);


-- Step 7: Insert Sample Data into Timetable Table
INSERT IGNORE INTO timetable (day, time_slot, subject_code, teacher_id, room_no) VALUES
('Monday', '08:00-08:50', '21CSE204J', 1, 'BMS/804'),
('Monday', '08:50-09:40', '21CSE205P', 2, 'BMS/804'),
('Monday', '09:50-10:40', '21CSE206T', 3, 'BMS/804'),
('Monday', '10:40-11:30', '21MAB204T', 4, 'BMS/804'),
('Monday', '12:20-02:00', '21PDM202L', 7, 'BMS/804'),
('Monday', '02:00-02:50', '21CSE206T', 3, 'BMS/804'),
('Tuesday', '08:00-08:50', '21CSE205P', 2, 'BMS/804'),
('Tuesday', '08:50-09:40', '21LEM202T', 8, 'BMS/804'),
('Tuesday', '09:50-10:40', '21CSE204J', 1, 'BMS/804'),
('Tuesday', '10:40-11:30', '21CSE206T', 3, 'BMS/804'),
('Tuesday', '12:20-02:00', '21CSE206T', 3, 'BMS/804'),
('Wednesday', '08:00-08:50', '21MAB204T', 4, 'BMS/804'),
('Wednesday', '08:50-09:40', '21CSE251T', 5, 'BMS/804'),
('Wednesday', '09:50-10:40', '21LEM202T', 8, 'BMS/804'),
('Wednesday', '10:40-11:30', '21CSE205P', 2, 'BMS/804'),
('Wednesday', '12:20-02:00', '21CSE204J', 1, 'BMS/804'),
('Thursday', '08:00-08:50', '21CSE204J', 1, 'BMS/804'),
('Thursday', '08:50-09:40', '21PDH201T', 6, 'BMS/804'),
('Thursday', '09:50-10:40', '21PDM202L', 7, 'BMS/804'),
('Thursday', '10:40-11:30', '21CSE205P', 2, 'BMS/804'),
('Thursday', '12:20-02:00', '21CSE205P', 2, 'BMS/804'),
('Friday', '08:00-08:50', '21LEM202T', 8, 'BMS/804'),
('Friday', '08:50-09:40', '21CSE204J', 1, 'BMS/804'),
('Friday', '09:50-10:40', '21CSE206T', 3, 'BMS/804'),
('Friday', '10:40-11:30', '21PDM202L', 7, 'BMS/804'),
('Friday', '12:20-02:00', '21CSE251T', 5, 'BMS/804');
