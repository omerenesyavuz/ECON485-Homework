

CREATE DATABASE IF NOT EXISTS econ485_omer;
USE econ485_omer;

-------------------------------------------------
-- Part 1a – Create base tables
-------------------------------------------------

CREATE TABLE PersonAccounts (
  AccountID    INT PRIMARY KEY,
  StudentNumber VARCHAR(20) NOT NULL,
  GivenName    VARCHAR(50) NOT NULL,
  Surname      VARCHAR(50) NOT NULL,
  ProgramLabel VARCHAR(50),
  IntakeYear   INT
);

CREATE TABLE SubjectCatalog (
  SubjectID        INT PRIMARY KEY,
  SubjectCode      VARCHAR(20) NOT NULL,
  SubjectTitle     VARCHAR(100) NOT NULL,
  LocalCreditUnits INT,
  EctsCreditUnits  INT
);

CREATE TABLE ScheduledClasses (
  ClassID           INT PRIMARY KEY,
  SubjectID         INT NOT NULL,
  TermCode          VARCHAR(10) NOT NULL,
  AcademicYearValue INT NOT NULL,
  SectionID         VARCHAR(10) NOT NULL,
  MaximumCapacity   INT,
  LeadLecturer      VARCHAR(100),
  CONSTRAINT fk_scheduled_subject
    FOREIGN KEY (SubjectID) REFERENCES SubjectCatalog(SubjectID)
);

CREATE TABLE EnrollmentRecords (
  EnrollmentID INT PRIMARY KEY,
  AccountID    INT NOT NULL,
  ClassID      INT NOT NULL,
  DateEnrolled DATE,
  CONSTRAINT fk_enroll_account
    FOREIGN KEY (AccountID) REFERENCES PersonAccounts(AccountID),
  CONSTRAINT fk_enroll_class
    FOREIGN KEY (ClassID) REFERENCES ScheduledClasses(ClassID)
);

-------------------------------------------------
-- Part 1b – Insert example data
-- At least 3 subjects, 1+ section each, 10 learners, 15+ final enrollments
-------------------------------------------------

INSERT INTO SubjectCatalog (SubjectID, SubjectCode, SubjectTitle, LocalCreditUnits, EctsCreditUnits) VALUES
  (501, 'ECN150', 'Intro to Economic Ideas', 3, 6),
  (502, 'ECN260', 'Market Analysis',         3, 6),
  (503, 'QTM110', 'Quantitative Methods I',  4, 7);

INSERT INTO ScheduledClasses (ClassID, SubjectID, TermCode, AcademicYearValue, SectionID, MaximumCapacity, LeadLecturer) VALUES
  (5001, 501, 'Fall', 2025, 'A',  60, 'Dr. Kaya'),
  (5002, 501, 'Fall', 2025, 'B',  60, 'Dr. Korkmaz'),
  (5003, 502, 'Fall', 2025, 'A',  45, 'Dr. Gurel'),
  (5004, 503, 'Fall', 2025, 'A',  50, 'Dr. Algan');

INSERT INTO PersonAccounts (AccountID, StudentNumber, GivenName, Surname, ProgramLabel, IntakeYear) VALUES
  (1,  '20253001', 'Omer',    'Altin',     'Economics',     2025),
  (2,  '20253002', 'Zeynep',  'Demir',     'Economics',     2025),
  (3,  '20253003', 'Can',     'Yildiz',    'Management',    2024),
  (4,  '20253004', 'Ayse',    'Balcı',     'Economics',     2023),
  (5,  '20253005', 'Mert',    'Aydin',     'Statistics',    2025),
  (6,  '20253006', 'Sila',    'Karaca',    'Economics',     2024),
  (7,  '20253007', 'Nazli',   'Gunes',     'Computer Eng',  2023),
  (8,  '20253008', 'Emre',    'Celik',     'Economics',     2022),
  (9,  '20253009', 'Bora',    'Sezer',     'Management',    2024),
  (10, '20253010', 'Ece',     'Ozkan',     'Economics',     2025);

INSERT INTO EnrollmentRecords (EnrollmentID, AccountID, ClassID, DateEnrolled) VALUES
  (1,  1, 5001, '2025-09-01'),
  (2,  1, 5004, '2025-09-01'),
  (3,  2, 5001, '2025-09-01'),
  (4,  2, 5003, '2025-09-01'),
  (5,  3, 5001, '2025-09-02'),
  (6,  3, 5004, '2025-09-02'),
  (7,  4, 5002, '2025-09-02'),
  (8,  4, 5003, '2025-09-02'),
  (9,  5, 5004, '2025-09-02'),
  (10, 6, 5001, '2025-09-03'),
  (11, 7, 5002, '2025-09-03'),
  (12, 8, 5003, '2025-09-03'),
  (13, 9, 5004, '2025-09-03'),
  (14,10, 5001, '2025-09-03'),
  (15,10, 5003, '2025-09-03');

-------------------------------------------------
-- Part 1c – Demonstrate add and drop actions
-------------------------------------------------

-- Add actions
-- Omer (AccountID = 1) adds Market Analysis (ClassID 5003)
INSERT INTO EnrollmentRecords (EnrollmentID, AccountID, ClassID, DateEnrolled)
VALUES (16, 1, 5003, '2025-09-04');

-- Zeynep (AccountID = 2) adds Quantitative Methods I (ClassID 5004)
INSERT INTO EnrollmentRecords (EnrollmentID, AccountID, ClassID, DateEnrolled)
VALUES (17, 2, 5004, '2025-09-04');

-- Can (AccountID = 3) adds ECN150 section B (ClassID 5002)
INSERT INTO EnrollmentRecords (EnrollmentID, AccountID, ClassID, DateEnrolled)
VALUES (18, 3, 5002, '2025-09-04');

-- Drop actions
-- Omer drops Quantitative Methods I (EnrollmentID = 2)
DELETE FROM EnrollmentRecords
WHERE EnrollmentID = 2;

-- Zeynep drops Market Analysis (EnrollmentID = 4)
DELETE FROM EnrollmentRecords
WHERE EnrollmentID = 4;

-- Can drops Quantitative Methods I (EnrollmentID = 6)
DELETE FROM EnrollmentRecords
WHERE EnrollmentID = 6;

-- Check current registrations
SELECT * FROM EnrollmentRecords ORDER BY EnrollmentID;

-------------------------------------------------
-- Part 1d – Final registration listing
-------------------------------------------------

SELECT
  p.GivenName,
  p.Surname,
  s.SubjectCode,
  c.SectionID,
  c.TermCode,
  c.AcademicYearValue,
  e.DateEnrolled
FROM EnrollmentRecords e
JOIN PersonAccounts   p ON e.AccountID = p.AccountID
JOIN ScheduledClasses c ON e.ClassID   = c.ClassID
JOIN SubjectCatalog   s ON c.SubjectID = s.SubjectID
ORDER BY p.Surname, p.GivenName, s.SubjectCode, c.SectionID;

-------------------------------------------------
-- Part 2 – Prerequisite support
-------------------------------------------------

CREATE TABLE SubjectPrerequisites (
  RuleID          INT PRIMARY KEY,
  MainSubjectID   INT NOT NULL,
  RequiredSubjectID INT NOT NULL,
  MinimumResult   CHAR(2) NOT NULL,
  CONSTRAINT fk_subjprereq_main
    FOREIGN KEY (MainSubjectID)     REFERENCES SubjectCatalog(SubjectID),
  CONSTRAINT fk_subjprereq_required
    FOREIGN KEY (RequiredSubjectID) REFERENCES SubjectCatalog(SubjectID)
);

CREATE TABLE SubjectCompletions (
  CompletionID INT PRIMARY KEY,
  AccountID    INT NOT NULL,
  SubjectID    INT NOT NULL,
  GradeCode    CHAR(2) NOT NULL,
  CONSTRAINT fk_completion_account
    FOREIGN KEY (AccountID) REFERENCES PersonAccounts(AccountID),
  CONSTRAINT fk_completion_subject
    FOREIGN KEY (SubjectID) REFERENCES SubjectCatalog(SubjectID)
);

-- Example rules: ECN260 (502) requires ECN150 (501) and QTM110 (503)
INSERT INTO SubjectPrerequisites (RuleID, MainSubjectID, RequiredSubjectID, MinimumResult) VALUES
  (1, 502, 501, 'C'),
  (2, 502, 503, 'D');

-- Example completed subjects and grades
INSERT INTO SubjectCompletions (CompletionID, AccountID, SubjectID, GradeCode) VALUES
  (1, 1, 501, 'B'),   -- Omer: ECN150 B
  (2, 1, 503, 'C'),   -- Omer: QTM110 C

  (3, 2, 501, 'D'),   -- Zeynep: ECN150 D
  (4, 2, 503, 'B'),   -- Zeynep: QTM110 B

  (5, 3, 501, 'C'),   -- Can: ECN150 C
  -- Can has not taken QTM110

  (6, 4, 501, 'A'),   -- Ayse: ECN150 A
  (7, 4, 503, 'B');   -- Ayse: QTM110 B

-------------------------------------------------
-- Part 2c – Assistive SQL queries
-------------------------------------------------

-- 1) List all prerequisites of a course (example: ECN260, SubjectID = 502)

SELECT
  main.SubjectCode    AS TargetSubjectCode,
  main.SubjectTitle   AS TargetSubjectTitle,
  req.SubjectCode     AS RequiredSubjectCode,
  req.SubjectTitle    AS RequiredSubjectTitle,
  sp.MinimumResult
FROM SubjectPrerequisites sp
JOIN SubjectCatalog main ON sp.MainSubjectID     = main.SubjectID
JOIN SubjectCatalog req  ON sp.RequiredSubjectID = req.SubjectID
WHERE sp.MainSubjectID = 502;

-- 2) Check whether a specific student has passed the prerequisites
-- Example: AccountID = 1, target SubjectID = 502

SELECT
  p.AccountID,
  p.GivenName,
  p.Surname,
  main.SubjectCode    AS TargetSubjectCode,
  req.SubjectCode     AS RequiredSubjectCode,
  req.SubjectTitle    AS RequiredSubjectTitle,
  sp.MinimumResult,
  sc.GradeCode        AS LearnerGrade,
  CASE
    WHEN sc.GradeCode IS NULL THEN 'NOT COMPLETED'
    WHEN sc.GradeCode >= sp.MinimumResult THEN 'OK'
    ELSE 'BELOW MINIMUM'
  END AS PrereqStatus
FROM SubjectPrerequisites sp
JOIN SubjectCatalog main ON sp.MainSubjectID     = main.SubjectID
JOIN SubjectCatalog req  ON sp.RequiredSubjectID = req.SubjectID
LEFT JOIN SubjectCompletions sc
       ON sc.SubjectID = sp.RequiredSubjectID
      AND sc.AccountID = 1              -- parameter: AccountID
JOIN PersonAccounts p
       ON p.AccountID = 1               -- same AccountID
WHERE sp.MainSubjectID = 502;           -- parameter: target SubjectID
