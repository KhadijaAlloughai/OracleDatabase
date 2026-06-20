--************06 Subqueries***********

--Task 1: Single-Row Subquery
--(a) Find all employees whose salary is greater than the average salary of the entire company.
SELECT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > (SELECT AVG(amount) FROM salary_bonus);

--(b) Retrieve the department with the highest total payroll amount.
SELECT d.name, payroll_totals.total_payroll
FROM job_department d
JOIN (
    SELECT job_id, SUM(total_amount) AS total_payroll
    FROM pay_roll
    GROUP BY job_id
) payroll_totals ON d.job_id = payroll_totals.job_id
WHERE payroll_totals.total_payroll = (
    SELECT MAX(dept_total)
    FROM (
        SELECT SUM(total_amount) AS dept_total
        FROM pay_roll
        GROUP BY job_id
    )
);

--Task 2: Multi-Row Subquery with IN / ANY / ALL

--(a)List all employees who work in departments that have at least one salary record with a bonus greater than 500.

SELECT e.emp_id, e.fname, e.lname, e.job_id
FROM employee e
WHERE e.job_id IN (
    SELECT emp.job_id
    FROM employee emp
    JOIN SALARY_BONUS sb ON emp.emp_id = sb.emp_id  
    WHERE sb.amount > 500                           
);

--(b) Find employees whose salary is greater than ALL salaries in the 'Maintenance' department. Use ALL.
--  �?الحل هو اغير اسم القسم واحط قسم موجود معي (Maintenance) لكن هنا ما عندس قسم 

SELECT job_id, name 
FROM job_department; 

SELECT DISTINCT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > ALL (
    SELECT sb2.amount
    FROM salary_bonus sb2
    JOIN employee e2 ON sb2.emp_id = e2.emp_id
    JOIN job_department d2 ON e2.job_id = d2.job_id
    WHERE d2.name = 'HR Manager' 
);

--sb (in the outer query): represents the financial record of any employee in the company. The database wants to check their current salary to see if it's higher than everyone else's or not.

--sb2 (in the inner query): represents the financial record of employees in the Maintenance department only.

--If a single employee (like 'Ahmed Al-Balushi') has more than one financial record in the salary_bonus table with the same value (for example: January salary of 1600, and February salary of 1600), the database will create a separate row for each financial record it finds.
-- THIS way bellow will remove the repeated result.

--(c)Find employees whose salary is greater than ANY salary in the 'HR' department.

SELECT e.emp_id, e.fname, e.lname, sb.amount
FROM employee e
JOIN salary_bonus sb ON e.emp_id = sb.emp_id
WHERE sb.amount > ANY (
    SELECT sb2.amount
    FROM salary_bonus sb2
    JOIN employee e2 ON sb2.emp_id = e2.emp_id
    JOIN job_department d2 ON e2.job_id = d2.job_id
    WHERE d2.name = 'HR Manager'
);

--*******************Task 3: Correlated Subquery

--*********(a) For each employee, show their name and the number of payroll records they have � without using a JOIN. Use
--(a) correlated subquery in the SELECT clause.

SELECT 
    e.fname || ' ' || e.lname AS full_name,
    (
        SELECT COUNT(*) 
        FROM pay_roll p 
        WHERE p.emp_id = e.emp_id
    ) AS total_payroll_records
FROM employee e;


-- (b) Find all employees who have taken more leave days than the average leave count across all employees. (Hint:
--count LEAVE rows per employee in the subquery.
SELECT 
    e.emp_id, 
    e.fname || ' ' || e.lname AS full_name
FROM employee e
        WHERE 
    (
        SELECT COUNT(*) 
        FROM "LEAVE" l 
        WHERE l.emp_id = e.emp_id
    ) > 
 
    (
        SELECT AVG(leave_count) 
        FROM (
            SELECT COUNT(*) AS leave_count 
            FROM "LEAVE" 
            GROUP BY emp_id
        )
    );
    
-- ************* Task 4: EXISTS and NOT EXISTS

--(a) List all departments for which EXISTS at least one payroll record with total_amount > 10,000.

SELECT d.job_id, d.job_dept AS department_name
FROM job_department d
WHERE EXISTS (
    SELECT 1 
    FROM pay_roll p
    WHERE p.job_id = d.job_id 
      AND p.total_amount > 10000
);


--(b) List all employees for whom NOT EXISTS any qualification record � i.e., employees with no recorded qualification.

SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM qualification q WHERE q.emp_id = e.emp_id
);

--(c) Compare the performance plan of EXISTS vs IN for query (b) by running both and checking the output of EXPLAIN PLAN. Paste the plan output as a SQL commen
  
EXPLAIN PLAN FOR
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE NOT EXISTS (
    SELECT 1 FROM qualification q WHERE q.emp_id = e.emp_id
); 

-- Version using NOT IN
EXPLAIN PLAN FOR
SELECT e.emp_id, e.fname, e.lname
FROM employee e
WHERE e.emp_id NOT IN (
SELECT q.emp_id FROM qualification q WHERE q.emp_id IS NOT NULL
);

--In NOT EXISTS: The query handles null values ??securely and automatically without requiring any intervention from you.

-- In NOT IN: If the Qualification table contains a single NULL value in the emp_id column and you haven't set the IS NOT NULL condition (which you have perfectly implemented), 
-- the query will logically fail and return no results at all. Therefore, it is always preferable to use NOT EXISTS in Oracle because it is more secure and less prone to logical errors.



