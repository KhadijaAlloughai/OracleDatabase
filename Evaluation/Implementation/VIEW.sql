--*********07 Views**********
--Task 1: Simple Read-Only View

--Create a view named VW_EMPLOYEE_SUMMARY that returns:
--emp_ID, full name, gender, age, department name, and job title (from QUALIFICATION).
CREATE OR REPLACE VIEW vw_employee_summary AS
SELECT
    e.emp_id,
    e.fname || ' ' || e.lname AS full_name,
    e.gender,
    e.age,
    d.name AS department_name,
    q.position AS job_title
FROM employee e
JOIN job_department d ON e.job_id = d.job_id
LEFT JOIN qualification q ON e.emp_id = q.emp_id;

SELECT * FROM vw_employee_summary;
--(a) Query the view to list all female employees over 30.

SELECT * FROM vw_employee_summary
WHERE gender = 'F' AND age > 30;

-- (b) Try to INSERT a row through this view and document the Oracle error message you receive.
INSERT INTO vw_employee_summary (emp_id, full_name, gender, age, department_name, job_title)
VALUES (999, 'Test User', 'M', 28, 'Engineering', 'Tester');

---> Error report -
--SQL Error: ORA-01779: cannot modify a column which maps to a non key-preserved table

--*********Task 2: Payroll Dashboard View******
CREATE OR REPLACE VIEW vw_payroll_dashboard AS
SELECT
    p.payroll_id,
    e.fname || ' ' || e.lname AS full_name,
    d.name AS department_name,
    sb.amount AS salary_amount,
    l.reason AS leave_reason,
    p."DATE" AS payroll_date,
    p.total_amount
FROM pay_roll p
JOIN employee e ON p.emp_id = e.emp_id
JOIN job_department d ON p.job_id = d.job_id
JOIN salary_bonus sb ON p.salary_id = sb.salary_id
LEFT JOIN leave l ON p.payroll_id = l.payroll_id;


-- Top 5 payroll records by total_amount
SELECT *
FROM (
    SELECT * FROM vw_payroll_dashboard ORDER BY total_amount DESC
)
WHERE ROWNUM <= 5;


-- ********** Task 3: Updatable View with CHECK OPTION

--Create a view named VW_ACTIVE_EMPLOYEES that shows only employees whose age >= 18, with WITH CHECK OPTION.


CREATE OR REPLACE VIEW vw_active_employees AS
SELECT emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id
FROM employee
WHERE age >= 18
WITH CHECK OPTION;

--(a) Try to INSERT an employee with age = 15 through the view. Document the error.

INSERT INTO vw_active_employees (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (seq_emp_id.NEXTVAL, 'Sami', 'Al-Riyami', 'M', 15, 'sami.r@company.com', 'pass123', 1);

--(b) Successfully INSERT an employee with age = 25 through the view, then verify with SELECT.

-- insert in view
INSERT INTO vw_active_employees (emp_id, fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES (seq_emp_id.NEXTVAL, 'Nasser', 'Al-Hadi', 'M', 25, 'nasser.h@company.com', 'secure778', 2);

-- verify from view
SELECT * FROM vw_active_employees WHERE age = 25;

--(c) UPDATE an employee's contact address through the view. Verify the change in the base table.

-- insert view
UPDATE vw_active_employees
SET emp_email = 'nasser.updated@company.com'
WHERE fname = 'Nasser' AND lname = 'Al-Hadi';


-- verify from the employee table
SELECT emp_id, fname, emp_email FROM employee WHERE fname = 'Nasser';




