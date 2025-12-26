

***


```markdown
# ECON485 – Homework 2 (Ömer)
## Database: econ485_omer  
### SQL Query Outputs

---

### 1. Course Prerequisites

```
SELECT
  main.SubjectCode AS TargetSubjectCode,
  main.SubjectTitle AS TargetSubjectTitle,
  req.SubjectCode AS RequiredSubjectCode,
  req.SubjectTitle AS RequiredSubjectTitle,
  sp.MinimumResult
FROM SubjectPrerequisites sp
JOIN SubjectCatalog main ON sp.MainSubjectID = main.SubjectID
JOIN SubjectCatalog req ON sp.RequiredSubjectID = req.SubjectID
WHERE sp.MainSubjectID = 502;
```

| TargetSubjectCode | TargetSubjectTitle     | RequiredSubjectCode | RequiredSubjectTitle       | MinimumResult |
|--------------------|------------------------|---------------------|----------------------------|----------------|
| ECN260             | Market Analysis        | ECN150              | Intro to Economic Ideas    | C              |
| ECN260             | Market Analysis        | QTM110              | Quantitative Methods I     | D              |

**2 rows in set (0.001 sec)**

---

### 2. Prerequisite Check for Student (AccountID = 1, Course = 502)

```
SELECT
  p.AccountID,
  p.GivenName,
  p.Surname,
  main.SubjectCode AS TargetSubjectCode,
  req.SubjectCode AS RequiredSubjectCode,
  req.SubjectTitle AS RequiredSubjectTitle,
  sp.MinimumResult,
  sc.GradeCode AS LearnerGrade,
  CASE
    WHEN sc.GradeCode IS NULL THEN 'NOT COMPLETED'
    WHEN sc.GradeCode >= sp.MinimumResult THEN 'OK'
    ELSE 'BELOW MINIMUM'
  END AS PrereqStatus
FROM SubjectPrerequisites sp
JOIN SubjectCatalog main ON sp.MainSubjectID = main.SubjectID
JOIN SubjectCatalog req ON sp.RequiredSubjectID = req.SubjectID
LEFT JOIN SubjectCompletions sc
  ON sc.SubjectID = sp.RequiredSubjectID
  AND sc.AccountID = 1
JOIN PersonAccounts p
  ON p.AccountID = 1
WHERE sp.MainSubjectID = 502;
```

| AccountID | GivenName | Surname | TargetSubjectCode | RequiredSubjectCode | RequiredSubjectTitle       | MinimumResult | LearnerGrade | PrereqStatus     |
|------------|------------|---------|-------------------|---------------------|----------------------------|----------------|---------------|------------------|
| 1          | Omer       | Altin   | ECN260            | ECN150              | Intro to Economic Ideas    | C              | B             | BELOW MINIMUM    |
| 1          | Omer       | Altin   | ECN260            | QTM110              | Quantitative Methods I     | D              | C             | BELOW MINIMUM    |

**2 rows in set (0.002 sec)**
```

***


```markdown
# ECON485 – Homework 3 (Ömer)
## Database: econ485_omer  
### SQL Query Outputs

---

### Task 1 – Students and Registered Sections

| StudentFirstName | StudentLastName | SubjectCode | SectionID |
|------------------|-----------------|--------------|------------|
| Omer             | Altin           | ECN150       | A |
| Omer             | Altin           | ECN260       | A |
| Mert             | Aydin           | QTM110       | A |
| Ayse             | Balci           | ECN150       | B |
| Ayse             | Balci           | ECN260       | A |
| Emre             | Celik           | ECN260       | A |
| Zeynep           | Demir           | ECN150       | A |
| Zeynep           | Demir           | QTM110       | A |
| Nazli            | Gunes           | ECN150       | B |
| Sila             | Karaca          | ECN150       | A |
| Ece              | Ozkan           | ECN150       | A |
| Ece              | Ozkan           | ECN260       | A |
| Bora             | Sezer           | QTM110       | A |
| Can              | Yildiz          | ECN150       | A |
| Can              | Yildiz          | ECN150       | B |

**15 rows in set (0.002 sec)**

---

### Task 2 – Total Students Per Course

| SubjectCode | SubjectTitle            | TotalStudents |
|--------------|------------------------|----------------|
| ECN150       | Intro to Economic Ideas | 7 |
| ECN260       | Market Analysis         | 4 |
| QTM110       | Quantitative Methods I  | 3 |

**3 rows in set (0.003 sec)**

---

### Task 3 – Prerequisites for Each Course

| TargetSubjectCode | TargetSubjectTitle     | PrerequisiteSubjectCode | PrerequisiteSubjectTitle   | MinimumResult |
|--------------------|------------------------|--------------------------|----------------------------|----------------|
| ECN150             | Intro to Economic Ideas| NULL                     | NULL                       | NULL           |
| ECN260             | Market Analysis        | ECN150                   | Intro to Economic Ideas    | C              |
| ECN260             | Market Analysis        | QTM110                   | Quantitative Methods I     | D              |
| QTM110             | Quantitative Methods I | NULL                     | NULL                       | NULL           |

**4 rows in set (0.001 sec)**
```

***

