--*******05 Joins*********

--Task 1: INNER JOIN - Employee Full Profile
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    q.position AS job_title,
    sb.amount AS salary_amount,
    MAX(l."DATE") AS latest_leave_date
FROM employee e
INNER JOIN job_department d ON e.job_id = d.job_id
INNER JOIN salary_bonus sb ON e.emp_id = sb.emp_id
INNER JOIN qualification q ON e.emp_id = q.emp_id
INNER JOIN pay_roll p ON e.emp_id = p.emp_id
LEFT JOIN leave l ON e.emp_id = l.emp_id
GROUP BY e.emp_id, e.fname, e.lname, d.name, q.position, sb.amount;

--Task 2: LEFT OUTER JOIN - Missing Records

-- (a) Employees who have never taken any leave
SELECT e.emp_id, e.fname, e.lname
FROM employee e
LEFT OUTER JOIN leave l ON e.emp_id = l.emp_id
WHERE l.leave_ID IS NULL;

-- (b) Departments with no salary/bonus records associated

SELECT d.job_id, d.name
FROM job_department d
LEFT OUTER JOIN employee e ON d.job_id = e.job_id
LEFT OUTER JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.salary_id IS NULL;

--Task 3: Multi-Table JOIN - Payroll Report

SELECT
    p.payroll_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    q.position,
    sb.amount AS salary_amount,
    sb.Bouns,
    l.reason AS leave_reason,
    p.total_amount
FROM pay_roll p
JOIN employee e ON p.emp_id = e.emp_id
JOIN job_department d ON p.job_id = d.job_id
JOIN salary_bonus sb ON p.salary_id = sb.salary_id
LEFT JOIN qualification q ON e.emp_id = q.emp_id
LEFT JOIN leave l ON p.payroll_id = l.payroll_id AND p.emp_id = l.emp_id 
ORDER BY d.name, p.total_amount DESC;


--******* Task 4: SELF JOIN — Employee Hierarchy 

ALTER TABLE employee ADD (manager_id NUMBER REFERENCES employee(emp_id));
---- (a) Assign managers to at least 5 employees
UPDATE employee SET manager_id = 1 WHERE emp_id IN (3, 7);
UPDATE employee SET manager_id = 2 WHERE emp_id IN (8);
UPDATE employee SET manager_id = 4 WHERE emp_id IN (9, 10);
UPDATE employee SET manager_id = 3 WHERE emp_id IN (5, 6);


