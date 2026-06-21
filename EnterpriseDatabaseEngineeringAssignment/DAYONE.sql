--Scenario 1
--The HR department should only see:
--• Employee Name
--• Department Name
--They should not see salary information.


SELECT * FROM hr.vw_hr_employee_departments;

CREATE OR REPLACE VIEW hr.vw_hr_employee_departments AS
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name
FROM hr.employees e
LEFT JOIN hr.departments d ON e.department_id = d.department_id;

--Scenario 2
--Every salary update must automatically be recorded for auditing purposes.

CREATE OR REPLACE TRIGGER hr.trg_audit_salary_update
AFTER UPDATE OF salary ON hr.employees
FOR EACH ROW
BEGIN
    INSERT INTO hr.hr_salary_history (
        employee_id,
        old_salary,
        new_salary,
        changed_by,
        changed_at
    ) VALUES (
        :OLD.employee_id,
        :OLD.salary,
        :NEW.salary,
        USER,
        CURRENT_TIMESTAMP
    );
END;

SELECT * FROM hr.hr_salary_history 
ORDER BY changed_at DESC;


--Scenario 3
--Management wants a report generated automatically every Friday at 4:00 PM.

BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'HR.WEEKLY_MANAGEMENT_REPORT_JOB',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'HR.GENERATE_WEEKLY_REPORT', -- Name of your reporting procedure
        start_date      => TRUNC(SYSDATE) + 16/24,       -- Starts at 4:00 PM
        repeat_interval => 'FREQ=WEEKLY; BYDAY=FRI; BYHOUR=16; BYMINUTE=0; BYSECOND=0',
        end_date        => NULL,
        enabled         => TRUE,
        comments        => 'Automatically generates the management report every Friday at 4:00 PM'
    );
END;
GRANT CREATE JOB TO hr;

--Scenario 4
--The Finance department wants one reusable process that calculates annual bonuses.

CREATE OR REPLACE PROCEDURE hr.sp_calculate_annual_bonus (
    p_employee_id   IN  hr.employees.employee_id%TYPE,
    p_bonus_percent IN  NUMBER, -- e.g., 0.10 for 10%
    p_bonus_amount  OUT NUMBER
) AS
    v_salary hr.employees.salary%TYPE;
BEGIN
    -- Fetch the employee's current monthly salary
    SELECT salary 
    INTO v_salary
    FROM hr.employees
    WHERE employee_id = p_employee_id;

    -- Calculate annual bonus: (Monthly Salary * 12) * Bonus Percentage
    p_bonus_amount := (v_salary * 12) * p_bonus_percent;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_bonus_amount := 0; -- Handle cases where the employee ID doesn't exist
END;


--Scenario 
--The company wants a notification whenever an employee's salary is modified.

CREATE OR REPLACE TRIGGER hr.trg_salary_change_notification
AFTER UPDATE OF salary ON hr.employees
FOR EACH ROW
BEGIN
    -- Only send notification if the salary actually changed to a different amount
    IF :OLD.salary <> :NEW.salary THEN
        
        -- Example using Oracle's built-in mail utility (requires SMTP setup)
        UTL_MAIL.SEND(
            sender     => 'database-alerts@company.com',
            recipients => 'finance-alerts@company.com',
            subject    => 'Alert: Employee Salary Modified',
            message    => 'Salary change detected for Employee ID: ' || :OLD.employee_id || 
                          '. Old Salary: ' || :OLD.salary || 
                          ', New Salary: ' || :NEW.salary
        );
        
    END IF;
END;


--Scenario 6
--Management wants a dashboard displaying employee information without exposing underlying tables.

CREATE OR REPLACE VIEW hr.vw_management_dashboard AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.email,
    e.hire_date,
    j.job_title,
    d.department_name,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name
FROM hr.employees e
LEFT JOIN hr.jobs j         ON e.job_id = j.job_id
LEFT JOIN hr.departments d  ON e.department_id = d.department_id
LEFT JOIN hr.locations l    ON d.location_id = l.location_id
LEFT JOIN hr.countries c    ON l.country_id = c.country_id
LEFT JOIN hr.regions r      ON c.region_id = r.region_id;

