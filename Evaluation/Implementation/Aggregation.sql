--********04 Aggregation Functions************

--Task 1: Basic Aggregation

--(a) Total number of employees in each department.

SELECT d.name AS department_name, COUNT(e.emp_id) AS total_employees
FROM job_department d
LEFT JOIN employee e ON d.job_id = e.job_id
GROUP BY d.name;

--(b) Minimum, maximum, and average salary (amount) across all salary records.

SELECT MIN(amount) AS min_salary,
MAX(amount) AS max_salary, AVG(amount) AS avg_salary
FROM salary_bonus;

--(c) Total bonus paid out across the entire company.
SELECT * FROM salary_bonus;

SELECT SUM(Bouns) AS total_bonus
FROM Salary_Bonus;


--Task 2: GROUP BY with HAVING

--(a) List departments where the average employee age exceeds 30.

SELECT d.name AS department_name, AVG(e.age) AS avg_age
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
GROUP BY d.name
HAVING AVG(e.age) > 30;

--(b) Show all job titles where more than 2 employees share that qualification position.

SELECT q.position, COUNT(q.emp_id) AS employee_count
FROM qualification q
GROUP BY q.position
HAVING COUNT(q.emp_id) > 2;

--(c) Find months (from PAYROLL.date) where the total payroll amount exceeds 20,000.
SELECT p."DATE" AS pay_day, SUM(p.total_amount) AS day_total
FROM Pay_roll p
GROUP BY p."DATE"
HAVING SUM(p.total_amount) > 20000;

--Task 3: Aggregation with Multiple Functions
--(a) Department name.
--(b) Total number of employees (COUNT).
--(c) Total payroll amount paid out (SUM of total_amount from PAYROLL).
--(d) Average salary of employees in that department (AVG of SALARY_BONUS.amount).
--(e) Highest salary in the department (MAX) and lowest salary (MIN).
--Join the necessary tables and group by department. Order results by total payroll descending.

SELECT
    d.name                              AS department_name,
    COUNT(DISTINCT e.emp_id)            AS total_employees,
    SUM(p.total_amount)                 AS total_payroll_paid,
    AVG(sb.amount)                      AS avg_salary,
    MAX(sb.amount)                      AS highest_salary,
    MIN(sb.amount)                      AS lowest_salary
FROM job_department d
LEFT JOIN employee e   ON d.job_id = e.job_id
LEFT JOIN salary_bonus sb ON e.emp_id = sb.emp_id
LEFT JOIN pay_roll p    ON d.job_id = p.job_id
GROUP BY d.name
ORDER BY total_payroll_paid DESC;

--*****Task 4: Filtered Aggregation — HAVING with Multiple Conditions
--(a) List departments where the total payroll (SUM) exceeds 15,000 AND the average salary (AVG) is above 3,000.
--(b) Find qualification positions where more than 2 employees hold that position (COUNT) AND the average age of
--those employees exceeds 28 (AVG).
--(c) Show all employees who have more than 1 leave record (COUNT of LEAVE rows per emp_ID). Display their full
--name, department, and leave count.

SELECT
    d.name AS department_name,
    SUM(p.total_amount) AS total_payroll,
    AVG(sb.amount) AS avg_salary
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
JOIN pay_roll p ON d.job_id = p.job_id
GROUP BY d.name
HAVING SUM(p.total_amount) > 15000 AND AVG(sb.amount) > 3000;


-- **********TASK 5: Aggregation Across the Full Schema

--(a) For each department, show: department name, total employees (COUNT), total bonus paid (SUM of bonus),
--and the difference between the highest and lowest salary (MAX - MIN). Only include departments with at least 2
--employees.
--1. FROM , JOIN --> 2- WHERE --> 3- GROUP BY --> 4- GROUP BY --> 5- SELECT --> 6- ORDER BY
SELECT
    d.job_dept AS department_name,                     
    COUNT(DISTINCT e.emp_id) AS total_employees,      
    SUM(sb.Bouns) AS total_bonus_paid,                
    MAX(sb.amount) - MIN(sb.amount) AS salary_spread   
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
GROUP BY d.job_dept                                   


--(b) Find the employee with the highest total payroll amount across all their payroll records (SUM per emp_ID).
--Show the employee's full name, department, and their total

SELECT *
FROM (
    SELECT
        e.emp_id,
        e.fname || ' ' || e.lname AS full_name,
        d.job_dept AS department_name, 
        SUM(p.total_amount) AS total_payroll
    FROM employee e
    JOIN job_department d ON e.job_id = d.job_id
    JOIN pay_roll p ON e.emp_id = p.emp_id 
    GROUP BY e.emp_id, e.fname, e.lname, d.job_dept
    ORDER BY total_payroll DESC
)
WHERE ROWNUM = 1;
 
 --This example i just want to see the hieghest salary >3500 just to insure about the result is correct for the previous question
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    d.job_dept AS department_name,
    SUM(p.total_amount) AS total_payroll
FROM employee e
JOIN job_department d ON e.job_id = d.job_id
JOIN pay_roll p ON e.emp_id = p.emp_id
GROUP BY e.emp_id, e.fname, e.lname, d.job_dept
HAVING SUM(p.total_amount) >= 3500 
ORDER BY total_payroll DESC;

--(c) Produce a leave summary: for each department, show the total number of leave records taken by its employees
--(COUNT), the average number of leave records per employee (AVG), and the department with the most leave
--records ranked firs

SELECT
    d.job_dept AS department_name,
    COUNT(l.leave_id) AS total_leave_records,
    COUNT(l.leave_id) / COUNT(DISTINCT e.emp_id) AS avg_leave_per_employee 
FROM job_department d
JOIN employee e ON d.job_id = e.job_id
LEFT JOIN leave l ON e.emp_id = l.emp_id
GROUP BY d.job_dept
ORDER BY total_leave_records DESC;