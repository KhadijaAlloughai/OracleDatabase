--************************* Day 2 – Oracle Implementation ******************************

--Part 5 – View Implementation
--Task 1
--Create a View displaying:
--• Employee ID
--• Employee Name
--• Department ID
--• Salary

CREATE OR REPLACE VIEW hr.vw_employee_salary_summary AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department_id,
    e.salary
FROM hr.employees e;
SELECT * FROM hr.vw_employee_salary_summary;

SELECT * FROM Employees;
--Task 2
--Create a View displaying:
--• Employee Name
--• Department Name
--• Job Title
--• Salary
CREATE  OR REPLACE VIEW hr.vw_employees AS 
SELECT
e.first_name || ' ' || e.last_name AS Employee_Name,
d.department_name,
j.job_title,
e.salary
FROM hr.employees e
LEFT JOIN hr.departments d  ON e.department_id = d.department_id
LEFT JOIN hr.jobs j         ON e.job_id = j.job_id;

SELECT * FROM hr.vw_employees;


--Task 3
--Using the View created above:
--Display employees earning more than 10000.
SELECT 
    employee_name,
    department_name,
    job_title,
    salary
FROM hr.vw_employees
WHERE salary > 10000;

--Task 4
--Explain:
--Why would management prefer querying the View instead of querying EMPLOYEES directly?

--First:
--1. Fast Access to Specific Information: Managers don't have time to type long lines and join tables every time they want to find employee information. 
--The View gathers everything in one place, like a single, integrated master table.

--2. Privacy and Security: Employee tables contain personal details that managers may not need to see all the time (such as email addresses, phone numbers, or commissions). The View focuses only on what's important (name, department, salary).

--Second: Real Benefits for Enterprise Companies
--1. Standardized Executive Reporting
--Explanation: In large companies, a branch manager might create a report, and another branch manager might create a similar report.
--If each manager were to retrieve data directly from the tables in their own way, the figures and results might differ due to errors in how the tables are linked.

--Benefit: The View ensures that all management personnel across all branches see the same data in the same way and with the same accurate calculations,
-- preventing discrepancies in sensitive reports presented to the board of directors.
--2. Principle of Least Privilege

--Explanation: In corporate governance and security compliance, 
--granting direct access to the core database tables to anyone outside the IT or finance department is strictly prohibited to protect them from accidental modification or deletion.

--Benefit: The View provides an ingenious solution; the company grants management "read-only" (SELECT) access to the View.
-- This allows managers to see everything they need to manage the business, while the company's original database tables remain 
--completely locked and protected behind this layer of security.


--*****************************************************************************************************************************************************
--Part 6 – Procedure Implementation

--Task 5
--Create a Procedure that accepts:
--• Department ID
--and displays:
--• Employee Name
--• Salary
--for employees belonging to that department.

CREATE OR REPLACE PROCEDURE display_emp_by_dept (
    p_department_id IN HR.EMPLOYEES.DEPARTMENT_ID%TYPE
)
IS
 
    v_emp_name  VARCHAR2(46);
    v_salary    HR.EMPLOYEES.SALARY%TYPE;
    v_found     BOOLEAN := FALSE;
BEGIN

    FOR emp_rec IN (
        SELECT FIRST_NAME, LAST_NAME, SALARY
        FROM HR.EMPLOYEES
        WHERE DEPARTMENT_ID = p_department_id
    ) LOOP
        v_found := TRUE;
        v_emp_name := emp_rec.FIRST_NAME || ' ' || emp_rec.LAST_NAME;
        v_salary   := emp_rec.SALARY;

        DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_emp_name || '   Salary: ' || v_salary);
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No employees found for Department ID: ' || p_department_id);
    END IF;
END display_emp_by_dept;
/

SET SERVEROUTPUT ON;

BEGIN
    display_emp_by_dept(60);
END;
/

UPDATE hr.employees SET salary = 4900 WHERE employee_id = 196;



--Task 6
--Modify the Procedure so it only returns employees whose salary is above the department average salary.

CREATE OR REPLACE PROCEDURE display_emp_above_avg (
    p_department_id IN HR.EMPLOYEES.DEPARTMENT_ID%TYPE
)
IS
    v_avg_salary  NUMBER(8,2);
    v_found       BOOLEAN := FALSE;
BEGIN
SELECT AVG(SALARY)
    INTO v_avg_salary
    FROM HR.EMPLOYEES
    WHERE DEPARTMENT_ID = p_department_id;
    
    IF v_avg_salary IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('--- Department ID: ' || p_department_id || ' (Average Salary: ' || ROUND(v_avg_salary, 2) || ') ---');
        FOR emp_rec IN (
            SELECT FIRST_NAME || ' ' || LAST_NAME AS full_name, SALARY
            FROM HR.EMPLOYEES
            WHERE DEPARTMENT_ID = p_department_id
              AND SALARY > v_avg_salary
        ) LOOP
        
        v_found := TRUE;
            DBMS_OUTPUT.PUT_LINE('Employee Name: ' || emp_rec.full_name || ' | Salary: ' || emp_rec.SALARY);
        END LOOP;
    END IF;
    
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No employees found with a salary above the department average for Dept ID: ' || p_department_id);
    END IF;

END display_emp_above_avg;
/
--Task 7
--Explain:
--Why is a Procedure better than rewriting the query repeatedly?
--1. Performance and Speed: The code is checked and compiled only once when it is 
--created and saved in the database. When called, the engine immediately reuses the saved execution plan, saving CPU power and memory.
--2. Reduced Network Traffic: The application sends a single-line command over the network (e.g., EXECUTE proc(60);). The server performs all
-- calculations internally and returns only the final result directly.
--3. Maintainability: You update the code in one place only (inside the Procedure itself within the database), and the logic updates across all
--10 pages instantly without touching the application code.
--4. Security and Data Protection 5. Reusability and Modularity.

CREATE TABLE hr.salary_audit (
    employee_id   NUMBER(6),
    old_salary    NUMBER(8,2),
    new_salary    NUMBER(8,2),
    update_date   DATE DEFAULT SYSDATE
);
-- Part 7 – Trigger Implementation
--Task 8
CREATE OR REPLACE TRIGGER hr.trg_salary_change_notification
AFTER UPDATE OF salary ON hr.employees
FOR EACH ROW
BEGIN
    INSERT INTO hr.salary_audit (employee_id, old_salary, new_salary, update_date)
    VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/
-- Task 9
UPDATE hr.employees 
SET salary = salary + 500 
WHERE employee_id = 100;
-- Task 10
SELECT * FROM hr.salary_audit;


--Task 11
CREATE OR REPLACE TRIGGER hr.trg_salary_change_notification
AFTER UPDATE OF salary ON hr.employees
FOR EACH ROW
BEGIN
    INSERT INTO hr.salary_audit (
        employee_id, 
        old_salary, 
        new_salary, 
        update_date,
        changed_by,
        changed_at    
    ) VALUES (
        :OLD.employee_id, 
        :OLD.salary, 
        :NEW.salary, 
        SYSDATE,
        USER,         
        SYSTIMESTAMP  
    );
END;
/

-- I faced an error --> ORA-00904: "CHANGED_AT": invalid identifier
-- so i need to update the first
ALTER TABLE hr.salary_audit ADD (
    changed_by   VARCHAR2(50),
    changed_at   TIMESTAMP
);
UPDATE hr.employees 
SET salary = salary + 100 
WHERE employee_id = 100;

UPDATE hr.employees 
SET salary = salary + 80 
WHERE employee_id = 196;

SELECT employee_id, old_salary, new_salary, update_date, changed_by, changed_at 
FROM hr.salary_audit;

-- Part 8 – Scheduler Job Design
--Task 12 

--(Schedule)

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'DAILY_HIGH_SALARY_REPORT_JOB',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN 
                                FOR dept_rec IN (SELECT department_id FROM hr.departments) LOOP
                                    display_emp_above_avg(dept_rec.department_id);
                                END LOOP;
                            END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=20; BYMINUTE=0; BYSECOND=0;',
        enabled         => TRUE,
        comments        => 'Generates a daily report at 8:00 PM for employees earning above their department average salary.'
    );
END;
/

-- How to see the result 
--Execution History Log

SELECT job_name, 
       status, 
       actual_start_date, 
       run_duration, 
       additional_info
FROM all_scheduler_job_run_details
WHERE job_name = 'DAILY_HIGH_SALARY_REPORT_JOB'
ORDER BY actual_start_date DESC;

BEGIN
    DBMS_SCHEDULER.RUN_JOB('DAILY_HIGH_SALARY_REPORT_JOB');
END;
/
-- It shows ERROR 
--ORA-27486: insufficient privileges-- this way to solve is (GRANT CREATE JOB TO hr;)

--Task 13
--Job name
WEEKLY_TOP_DEPT_SALARY_REPORT_JOB
--Schedule
FREQ=WEEKLY; BYDAY=FRI; BYHOUR=16; BYMINUTE=0; BYSECOND=0;

--Logic Executed
BEGIN 
    DBMS_OUTPUT.PUT_LINE('=== WEEKLY REPORT: DEPARTMENTS WITH HIGHEST AVERAGE SALARIES ===');
    DBMS_OUTPUT.PUT_LINE(RPAD('Department ID', 15) || ' | ' || RPAD('Department Name', 25) || ' | ' || 'Average Salary');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    
    FOR r IN (
        SELECT d.department_id, d.department_name, ROUND(AVG(e.salary), 2) AS avg_sal
        FROM hr.employees e
        JOIN hr.departments d ON e.department_id = d.department_id
        GROUP BY d.department_id, d.department_name
        ORDER BY avg_sal DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(r.department_id), 15) || ' | ' || 
            RPAD(r.department_name, 25) || ' | ' || 
            TO_CHAR(r.avg_sal, '$99,999.99')
        );
    END LOOP;
END;

--Task 14

--• Job Name
BEGIN
    DBMS_SCHEDULER.RUN_JOB('MONTHLY_STAGNANT_SALARY_REPORT_JOB');
END;
/
--• Schedule

FREQ=MONTHLY; BYMONTHDAY=1; BYHOUR=0; BYMINUTE=0; BYSECOND=0;

--• Logic Executed

BEGIN 
    DBMS_OUTPUT.PUT_LINE('=== MONTHLY REPORT: EMPLOYEES WITH NO SALARY UPDATES IN LAST 6 MONTHS ===');
    DBMS_OUTPUT.PUT_LINE(RPAD('Employee ID', 15) || ' | ' || RPAD('Name', 25) || ' | ' || 'Current Salary');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
    
    FOR emp IN (
        SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
        FROM hr.employees
        WHERE employee_id NOT IN (
            -- جلب الموظفين الذين تعدلت رواتبهم في آخر 6 أشهر واستثنائهم
            SELECT DISTINCT employee_id 
            FROM hr.salary_audit 
            WHERE update_date >= ADD_MONTHS(SYSDATE, -6)
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(emp.employee_id), 15) || ' | ' || 
            RPAD(emp.full_name, 25) || ' | ' || 
            TO_CHAR(emp.salary, '$99,999.99')
        );
    END LOOP;
END;

-- Part 9 – Enterprise Change Request

--Change Request 1

CREATE OR REPLACE VIEW hr.emp_details_view AS
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       j.job_title,          --Job name
       d.department_name,   -- Dept name
       l.city,                -- city name
       e.salary
FROM hr.employees e
JOIN hr.jobs j ON e.job_id = j.job_id
LEFT JOIN hr.departments d ON e.department_id = d.department_id
LEFT JOIN hr.locations l ON d.location_id = l.location_id;

SELECT employee_id, employee_name, job_title, department_name, city, salary 
FROM hr.emp_details_view;

--Change Request 2

CREATE OR REPLACE PROCEDURE hr.display_emp_above_avg (p_dept_id IN NUMBER) IS
    v_avg_salary NUMBER;
BEGIN
    -- avg calculation
    SELECT AVG(salary) INTO v_avg_salary 
    FROM hr.employees 
    WHERE department_id = p_dept_id;

  --Fetch the employees and sort them in descending order based on the highest salary
    FOR rec IN (
        SELECT employee_id, first_name || ' ' || last_name AS name, salary
        FROM hr.employees
        WHERE department_id = p_dept_id AND salary > v_avg_salary
        ORDER BY salary DESC --ordered by desc
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || rec.employee_id || ' | Name: ' || rec.name || ' | Salary: ' || rec.salary);
    END LOOP;
END;
/

--Change Request 3

CREATE OR REPLACE TRIGGER hr.trg_salary_change_notification
AFTER UPDATE OF salary ON hr.employees
FOR EACH ROW
BEGIN
    INSERT INTO hr.salary_audit (
        employee_id, 
        old_salary, 
        new_salary, 
        update_date,
        changed_by, 
        changed_at, 
        department_id
    ) VALUES (
        :OLD.employee_id, 
        :OLD.salary, 
        :NEW.salary, 
        SYSDATE,
        USER, 
        SYSTIMESTAMP, 
        :OLD.department_id
    );
END;
/

ALTER TABLE hr.salary_audit ADD (
    department_id NUMBER(4)
);

UPDATE hr.employees 
SET salary = salary + 200 
WHERE employee_id = 100;

SELECT employee_id, old_salary, new_salary, update_date, changed_by, changed_at, department_id 
FROM hr.salary_audit;

--Change Request 4
BEGIN
    DBMS_SCHEDULER.SET_ATTRIBUTE (
        name      => 'DAILY_HIGH_SALARY_REPORT_JOB',
        attribute => 'repeat_interval',
        value     => 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=16; BYMINUTE=0; BYSECOND=0;'
    );
END;
/

-- this way how to see the changes

SELECT job_name, 
       repeat_interval, 
       next_run_date, 
       enabled
FROM all_scheduler_jobs
WHERE job_name = 'DAILY_HIGH_SALARY_REPORT_JOB';