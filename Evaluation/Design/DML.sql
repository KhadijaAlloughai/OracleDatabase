--***********Conditional SELECT Queries*************
--Task2: Conditional SELECT Queries

--(a) List all employees whose age is between 25 and 40, ordered by last name ascending.
SELECT emp_id, fname, lname, age
FROM employee
WHERE age BETWEEN 25 AND 40
ORDER BY lname ASC;

SELECT * FROM Employee;

--(b) Retrieve all payroll records where total_amount exceeds 5000, showing employee name and department.

SELECT p.payroll_id, e.Fname || ' ' || e.Lname AS employee_name,
d.name AS department_name, p.total_amount
FROM Pay_roll p
JOIN employee e ON p.emp_id = e.emp_id
JOIN job_department d ON p.job_id = d.job_id
WHERE p.total_amount > 5000;

--(c) Find all employees who have taken leave with reason containing the word 'sick' (case-insensitive).

SELECT DISTINCT e.emp_id, e.fname, e.lname, l.reason
FROM employee e
JOIN leave l ON e.emp_id = l.emp_id
WHERE LOWER(l.reason) LIKE '%sick%';

--(d) List all departments that have no employees assigned. (Use outer join or NOT EXISTS.)
SELECT d.job_id, d.name
FROM job_department d
WHERE NOT EXISTS (
    SELECT 1 FROM employee e WHERE e.job_id = d.job_id
);

SELECT d.job_id, d.name
FROM job_department d
LEFT OUTER JOIN employee e ON d.job_id = e.job_id
WHERE e.job_id IS NULL;

--**********Task 3: Bulk UPDATE Scenarios*******

--(a) Give a 10% salary increase to all employees in the 'Engineering' department.

UPDATE salary_bonus sb
SET amount = amount * 0.10
WHERE sb.emp_id IN (
    SELECT e.emp_id
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    WHERE d.name = 'Financial Analyst'
);

--(b) Update the emp_email of all employees to lowercase using Oracle's LOWER() function.

UPDATE employee
SET emp_email = LOWER(emp_email);
--(c) Set the salary_range in JOB_DEPARTMENT to 'REVISED' for any department whose average total payroll
--exceeds 8000. 
UPDATE job_department d
SET d.salary_range = 'REVISED'
WHERE d.job_id IN (
    SELECT p.job_id
    FROM pay_roll p
    GROUP BY p.job_id
    HAVING AVG(p.total_amount) > 2000
);
--first will execute this to check the avg  then execute the above 
SELECT d.job_id, d.job_dept, d.name, AVG(p.total_amount) AS average_payroll
FROM job_department d
JOIN Pay_roll p ON d.job_id = p.job_id
GROUP BY d.job_id, d.job_dept, d.name
HAVING AVG(p.total_amount) > 2000;

--Task 4: Controlled DELETE with Safety Checks

--(a) Delete all LEAVE records older than 2 years from today.

DELETE FROM leave
WHERE "DATE" < ADD_MONTHS(SYSDATE, -24);
SELECT COUNT(*) AS leave_after_delete FROM leave;

--(b) Delete QUALIFICATION records for employees who no longer exist in the EMPLOYEE table.
--Before we delete, we want to tell Oracle: "Show me the qualifications that belong 
--to employee IDs that do not exist in the Employee table."
SELECT q.qual_ID, q.Position, q.emp_ID
FROM Qualification q
WHERE q.emp_ID NOT IN (SELECT e.emp_ID FROM Employee e);

--Step 2: Count records before deletion
SELECT COUNT(*) AS total_before_delete FROM Qualification;

-- Actual Deletion
DELETE FROM Qualification
WHERE emp_ID NOT IN (
    SELECT emp_ID 
    FROM Employee
);
--> the result 0 row deleted

--Count records after deletion (Verification)
SELECT COUNT(*) AS total_after_delete FROM Qualification;

--**************Task 5: Transaction Management & SAVEPOINT********

--1. Begin a transaction that inserts a new employee and their first payroll record.
--Transaction: It's the whole journey from start to the final save with COMMIT or the complete cancellation with ROLLBACK.

--SAVEPOINT: It's a stopover in the middle of this journey, allowing you to go back to it without having to return to the starting point.

--1. Begin a transaction that inserts a new employee and their first payroll record.
--Insert a new employee
INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Nasser', 'Al-Riyami', 22, 'M', 'nasser2026', 'nasser.r@company.com', 2);
--verify insertion
SELECT emp_ID, Fname, Lname, emp_email 
FROM Employee 
WHERE emp_email = 'nasser.r@company.com';

-- 2. Set a SAVEPOINT after the employee insert. 
--save the insertion (SAVEPOINT)
SAVEPOINT after_emp_insert;

--3. Insert an intentionally incorrect payroll record (e.g., negative total_amount).
INSERT INTO PAY_ROLL (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, SYSDATE, 'Bad Record - Negative Amount', -1500.00, 2, 2, seq_emp_id.CURRVAL);

--4. ROLLBACK to the savepoint — verify the bad payroll record is gone but the employee remains.
ROLLBACK TO SAVEPOINT after_emp_insert;

-- THIS for verify that the Nasser is inserted 

SELECT emp_ID, Fname, Lname 
FROM Employee 
WHERE emp_email = 'nasser.r@company.com';
--5. Insert the corrected payroll record and COMMIT the full transaction.
--Include a SELECT after each step to prove the state of the database at that point.

INSERT INTO PAY_ROLL (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, SYSDATE, 'Corrected First Payroll', 1500.00, 2, 2, seq_emp_id.CURRVAL);

--check the correct salary 
SELECT Payroll_ID, total_amount, 
report FROM PAY_ROLL 
WHERE report = 'Corrected First Payroll';

-- Save everything
COMMIT;
SELECT * FROM Employee;

SELECT emp_ID, total_amount, "DATE", report 
FROM PAY_ROLL 
ORDER BY emp_ID;


