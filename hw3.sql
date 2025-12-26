-- Task 1: List Students and Their Registered Sections
SELECT
    p.GivenName  AS StudentFirstName,
    p.Surname    AS StudentLastName,
    s.SubjectCode,
    c.SectionID
FROM EnrollmentRecords e
JOIN PersonAccounts   p ON e.AccountID = p.AccountID
JOIN ScheduledClasses c ON e.ClassID   = c.ClassID
JOIN SubjectCatalog   s ON c.SubjectID = s.SubjectID
ORDER BY p.Surname, p.GivenName, s.SubjectCode, c.SectionID;
-- Task 2: Show Courses with Total Student Counts
SELECT
    s.SubjectCode,
    s.SubjectTitle,
    COUNT(DISTINCT e.AccountID) AS TotalStudents
FROM SubjectCatalog s
LEFT JOIN ScheduledClasses c
       ON c.SubjectID = s.SubjectID
LEFT JOIN EnrollmentRecords e
       ON e.ClassID = c.ClassID
GROUP BY
    s.SubjectID,
    s.SubjectCode,
    s.SubjectTitle
ORDER BY s.SubjectCode;
-- Task 3: List All Prerequisites for Each Course
SELECT
    main.SubjectCode  AS TargetSubjectCode,
    main.SubjectTitle AS TargetSubjectTitle,
    req.SubjectCode   AS PrerequisiteSubjectCode,
    req.SubjectTitle  AS PrerequisiteSubjectTitle,
    sp.MinimumResult
FROM SubjectCatalog main
LEFT JOIN SubjectPrerequisites sp
       ON sp.MainSubjectID = main.SubjectID
LEFT JOIN SubjectCatalog req
       ON sp.RequiredSubjectID = req.SubjectID
ORDER BY
    main.SubjectCode,
    req.SubjectCode;
-- Task 4: Identify Students Eligible to Take a Course (example: SubjectID = 502)

SELECT
    p.AccountID,
    p.GivenName,
    p.Surname,
    main.SubjectCode   AS TargetSubjectCode,
    req.SubjectCode    AS PrerequisiteSubjectCode,
    req.SubjectTitle   AS PrerequisiteSubjectTitle,
    sp.MinimumResult,
    sc.GradeCode       AS LearnerGrade,
    CASE
        WHEN sc.GradeCode IS NULL THEN 'MISSING'
        WHEN sc.GradeCode >= sp.MinimumResult THEN 'OK'
        ELSE 'BELOW MINIMUM'
    END AS PrereqStatus
FROM PersonAccounts p
JOIN SubjectPrerequisites sp
       ON sp.MainSubjectID = 502              -- hedef ders
JOIN SubjectCatalog main
       ON main.SubjectID = sp.MainSubjectID
JOIN SubjectCatalog req
       ON req.SubjectID = sp.RequiredSubjectID
LEFT JOIN SubjectCompletions sc
       ON sc.AccountID = p.AccountID
      AND sc.SubjectID = sp.RequiredSubjectID
LEFT JOIN EnrollmentRecords er_target
       ON er_target.AccountID = p.AccountID
      AND er_target.ClassID IN (
           SELECT ClassID
           FROM ScheduledClasses
           WHERE SubjectID = 502
      )
WHERE er_target.EnrollmentID IS NULL         -- zaten kayıtlı olmasın
GROUP BY
    p.AccountID,
    p.GivenName,
    p.Surname,
    main.SubjectCode,
    req.SubjectCode,
    req.SubjectTitle,
    sp.MinimumResult,
    sc.GradeCode
HAVING MIN(
    CASE
        WHEN sc.GradeCode IS NULL THEN 0
        WHEN sc.GradeCode >= sp.MinimumResult THEN 1
        ELSE 0
    END
) = 1;
-- Task 5: Detect Students Who Registered Without Meeting Prerequisites (example: SubjectID = 502)

SELECT
    p.GivenName,
    p.Surname,
    main.SubjectCode        AS TargetSubjectCode,
    req.SubjectCode         AS MissingOrFailedPrereqCode,
    req.SubjectTitle        AS MissingOrFailedPrereqTitle,
    sc.GradeCode            AS LearnerGrade,
    sp.MinimumResult        AS RequiredMinimumGrade
FROM EnrollmentRecords er
JOIN PersonAccounts p
       ON p.AccountID = er.AccountID
JOIN ScheduledClasses c
       ON c.ClassID = er.ClassID
JOIN SubjectCatalog main
       ON main.SubjectID = c.SubjectID
JOIN SubjectPrerequisites sp
       ON sp.MainSubjectID = main.SubjectID
JOIN SubjectCatalog req
       ON req.SubjectID = sp.RequiredSubjectID
LEFT JOIN SubjectCompletions sc
       ON sc.AccountID = p.AccountID
      AND sc.SubjectID = sp.RequiredSubjectID
WHERE main.SubjectID = 502                     -- hedef ders
  AND (
       sc.GradeCode IS NULL                    -- prerequisite hiç yok
       OR sc.GradeCode < sp.MinimumResult      -- veya minimumun altında
  )
ORDER BY
    p.Surname,
    p.GivenName,
    req.SubjectCode;
