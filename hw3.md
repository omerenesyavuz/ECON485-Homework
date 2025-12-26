
```markdown


---

## Task 1 – List Students and Their Registered Sections

```
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
```

| StudentFirstName | StudentLastName | SubjectCode | SectionID |
|------------------|-----------------|------------|-----------|
| Omer             | Altin           | ECN150     | A         |
| Omer             | Altin           | ECN260     | A         |
| Mert             | Aydin           | QTM110     | A         |
| Ayse             | Balci           | ECN150     | B         |
| Ayse             | Balci           | ECN260     | A         |
| Emre             | Celik           | ECN260     | A         |
| Zeynep           | Demir           | ECN150     | A         |
| Zeynep           | Demir           | QTM110     | A         |
| Nazli            | Gunes           | ECN150     | B         |
| Sila             | Karaca          | ECN150     | A         |
| Ece              | Ozkan           | ECN150     | A         |
| Ece              | Ozkan           | ECN260     | A         |
| Bora             | Sezer           | QTM110     | A         |
| Can              | Yildiz          | ECN150     | A         |
| Can              | Yildiz          | ECN150     | B         |

**15 rows in set (0.002 sec)**

---

## Task 2 – Show Courses with Total Student Counts

```
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
```

| SubjectCode | SubjectTitle             | TotalStudents |
|------------|--------------------------|---------------|
| ECN150     | Intro to Economic Ideas  | 7             |
| ECN260     | Market Analysis          | 4             |
| QTM110     | Quantitative Methods I   | 3             |

**3 rows in set (0.003 sec)**

---

## Task 3 – List All Prerequisites for Each Course

```
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
```

| TargetSubjectCode | TargetSubjectTitle     | PrerequisiteSubjectCode | PrerequisiteSubjectTitle   | MinimumResult |
|-------------------|------------------------|--------------------------|----------------------------|---------------|
| ECN150            | Intro to Economic Ideas| NULL                     | NULL                       | NULL          |
| ECN260            | Market Analysis        | ECN150                   | Intro to Economic Ideas    | C             |
| ECN260            | Market Analysis        | QTM110                   | Quantitative Methods I     | D             |
| QTM110            | Quantitative Methods I | NULL                     | NULL                       | NULL          |

**4 rows in set (0.001 sec)**

---

## Task 4 – Identify Students Eligible to Take a Course (SubjectID = 502)

```
SELECT
  p.AccountID,
  p.GivenName,
  p.Surname,
  main.SubjectCode AS TargetSubjectCode,
  req.SubjectCode  AS PrerequisiteSubjectCode,
  req.SubjectTitle AS PrerequisiteSubjectTitle,
  sp.MinimumResult,
  sc.GradeCode     AS LearnerGrade,
  CASE
    WHEN sc.GradeCode IS NULL THEN 'MISSING'
    WHEN sc.GradeCode >= sp.MinimumResult THEN 'OK'
    ELSE 'BELOW MINIMUM'
  END AS PrereqStatus
FROM PersonAccounts p
JOIN SubjectPrerequisites sp
       ON sp.MainSubjectID = 502
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
WHERE er_target.EnrollmentID IS NULL
ORDER BY p.AccountID, req.SubjectCode;
```

*(Result set depends on the current data in `SubjectCompletions` and `EnrollmentRecords`. In the sample data, all students fail at least one prerequisite, so no fully eligible students are returned.)*

**0 rows in set (0.00 sec)**

---

## Task 5 – Detect Students Who Registered Without Meeting Prerequisites (SubjectID = 502)

```
SELECT
  p.GivenName,
  p.Surname,
  main.SubjectCode AS TargetSubjectCode,
  req.SubjectCode  AS MissingOrFailedPrereqCode,
  req.SubjectTitle AS MissingOrFailedPrereqTitle,
  sc.GradeCode     AS LearnerGrade,
  sp.MinimumResult AS RequiredMinimumGrade
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
WHERE main.SubjectID = 502
  AND (
       sc.GradeCode IS NULL
       OR sc.GradeCode < sp.MinimumResult
      )
ORDER BY
  p.Surname,
  p.GivenName,
  req.SubjectCode;
```
