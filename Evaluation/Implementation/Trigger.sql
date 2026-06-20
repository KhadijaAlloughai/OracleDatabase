--**********09 Triggers **************

--Task 1: BEFORE INSERT — Auto-Assign emp_ID

-- إنشاء الـ Sequence بالاسم المطلوبة �?ي السؤال (يبدأ من 200 ليكون آمن تماماً)
CREATE SEQUENCE emp_seq START WITH 200 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_emp_id
BEFORE INSERT ON employee
FOR EACH ROW
WHEN (NEW.emp_id IS NULL) -- تم إزالة النقطتين الرأسيتين من هنا لتتوا�?ق مع قواعد أوراكل
BEGIN
    :NEW.emp_id := emp_seq.NEXTVAL; -- تم التعديل ليتوا�?ق مع اسم الـ Sequence المطلوب �?ي السؤال
END;
/

-- إدخال موظ�? جديد دون تحديد عمود الـ emp_id تماماً كما طلب السؤال
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Auto', 'Assigned', 'F', 26, 'auto.assigned@ems.com', 'pass123', 2);

-- استعلام للتحقق من النتيجة ورؤية الرقم التلقائي
SELECT emp_id, fname, lname 
FROM employee 
WHERE fname = 'Auto';

-- Task 2: AFTER INSERT — Welcome Log

-- 1. إنشاء جدول السجلات
CREATE TABLE employee_log (
    log_id        NUMBER          NOT NULL,
    emp_id        NUMBER,
    action        VARCHAR2(50)    NOT NULL,
    log_timestamp DATE            DEFAULT SYSDATE,
    CONSTRAINT pk_employee_log PRIMARY KEY (log_id)
);

-- 2. إنشاء الـ Sequence الخاص بالجدول الجديد
CREATE SEQUENCE employee_log_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- 3. بناء التريجر الذي يسجل حركة الموظ�?ين الجدد
CREATE OR REPLACE TRIGGER trg_emp_welcome_log
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_log (log_id, emp_id, action, log_timestamp)
    VALUES (employee_log_seq.NEXTVAL, :NEW.emp_id, 'NEW HIRE', SYSDATE);
END;

-- إدخال الموظ�? الأول
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'One', 'M', 30, 'hire.one@ems.com', 'pass123', 3);

-- إدخال الموظ�? الثاني
INSERT INTO employee (fname, lname, gender, age, emp_email, emp_pass, job_id)
VALUES ('Hire', 'Two', 'F', 31, 'hire.two@ems.com', 'pass123', 3);

-- الاستعلام عن السجلات للتأكد من عمل التريجر
SELECT * FROM employee_log WHERE action = 'NEW HIRE';


-- ********* TASK 3: BEFORE UPDATE - Prevent Salary Decrease

CREATE OR REPLACE TRIGGER trg_prevent_salary_cut
BEFORE UPDATE ON salary_bonus
FOR EACH ROW
BEGIN
    IF :NEW.amount < :OLD.amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary decrease is not allowed.');
    END IF;
END;



UPDATE salary_bonus SET amount = amount - 500 WHERE salary_id = 1;
--ORA-20001: Salary decrease is not allowed.

SELECT salary_id, amount FROM salary_bonus WHERE salary_id = 1;


UPDATE salary_bonus SET amount = amount + 500 WHERE salary_id = 1;


SELECT salary_id, amount FROM salary_bonus WHERE salary_id = 1;



-- ********** TASK 4: AFTER DELETE - Archive Deleted Employees

CREATE TABLE employee_archive (
    emp_id        NUMBER,
    fname         VARCHAR2(50),
    lname         VARCHAR2(50),
    gender        CHAR(1),
    age           NUMBER(3),
    emp_email     VARCHAR2(100),
    emp_pass      VARCHAR2(100),
    job_id        NUMBER,
    salary_id     NUMBER,
    manager_id    NUMBER,
    archived_at   DATE            DEFAULT SYSDATE,
    archived_by   VARCHAR2(50)
);

CREATE OR REPLACE TRIGGER trg_archive_employee
AFTER DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO employee_archive (
        emp_id, fname, lname, gender, age, emp_email, emp_pass,
        job_id, salary_id, manager_id, archived_at, archived_by
    )
    VALUES (
        :OLD.emp_id, :OLD.fname, :OLD.lname, :OLD.gender, :OLD.age,
        :OLD.emp_email, :OLD.emp_pass, :OLD.job_id, :OLD.salary_id,
        :OLD.manager_id, SYSDATE, USER
    );

DELETE FROM pay_roll WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM leave WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM qualification WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');
DELETE FROM salary_bonus WHERE emp_id = (SELECT emp_id FROM employee WHERE fname = 'Auto' AND lname = 'Assigned');


DELETE FROM employee WHERE fname = 'Auto' AND lname = 'Assigned';



SELECT * FROM employee_archive;








