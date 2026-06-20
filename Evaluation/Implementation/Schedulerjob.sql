--***************10 Oracle Scheduler Jobs****************
BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_GREET_EMPLOYEES',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN
                                DBMS_OUTPUT.PUT_LINE(''Payroll System Initialized'');
                                INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
                                VALUES (employee_log_seq.NEXTVAL, NULL, ''SYSTEM_INIT'', SYSDATE);
                                COMMIT;
                             END;',
        start_date      => SYSTIMESTAMP + INTERVAL '2' MINUTE,
        enabled         => TRUE
    );
END;
/

-- 1. التأكد من حالة الجدولة وسجل التن�?يذ (هذا هو المطلوب للقطة الشاشة)
SELECT job_name, status, log_date, run_duration
FROM USER_SCHEDULER_JOB_LOG
WHERE job_name = 'JOB_GREET_EMPLOYEES'
ORDER BY log_date DESC;

-- 2. التأكد من أن البيانات ح�?قنت بنجاح �?ي جدول اللوج
SELECT * FROM employee_log WHERE action = 'SYSTEM_INIT';


SELECT job_name, status, log_date
FROM USER_SCHEDULER_JOB_LOG
WHERE job_name = 'JOB_GREET_EMPLOYEES'
ORDER BY log_date DESC;

--OR 

SELECT * FROM USER_SCHEDULER_JOB_LOG
WHERE job_name = 'JOB_GREET_EMPLOYEES'
ORDER BY log_date DESC;


-- *********** Task 2: Recurring Job � Daily Leave Report

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_DAILY_LEAVE_REPORT',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[
            BEGIN
                INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
                SELECT seq_log_id.NEXTVAL, NULL, 'DAILY_LEAVE_COUNT: ' || COUNT(*), SYSDATE
                FROM "LEAVE"
                WHERE TRUNC(leave_date) = TRUNC(SYSDATE);
                COMMIT;
            END;
        ]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=7; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE
    );
END;


SELECT job_name, job_type, repeat_interval, state, next_run_date
FROM USER_SCHEDULER_JOBS
WHERE job_name = 'JOB_DAILY_LEAVE_REPORT';