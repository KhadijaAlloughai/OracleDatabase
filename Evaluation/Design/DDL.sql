--*************** Task 3: Write the Full DDL CREATE Statements*****************************
CREATE TABLE JOB_DEPARTMENT (
    job_ID          NUMBER(10)      NOT NULL,
    job_dept        VARCHAR2(50)    NOT NULL,
    name            VARCHAR2(100)   NOT NULL,
    description     VARCHAR2(500),
    salary_range    VARCHAR2(50),

    CONSTRAINT PK_JOB_DEPARTMENT PRIMARY KEY (job_ID)
);
CREATE SEQUENCE seq_job_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Employee (
    emp_ID        NUMBER,
    Fname         VARCHAR2(50) NOT NULL,
    Lname         VARCHAR2(50) NOT NULL,
    age           NUMBER(3),
    Gender        CHAR(1) NOT NULL,
    emp_pass      VARCHAR2(100) NOT NULL,
    emp_email     VARCHAR2(100) NOT NULL,
    job_ID        NUMBER,
    CONSTRAINT pk_employee PRIMARY KEY (emp_ID),
    CONSTRAINT fk_emp_job FOREIGN KEY (job_ID) REFERENCES Job_department(job_ID),
    CONSTRAINT chk_emp_gender CHECK (Gender IN ('M', 'F')),
    CONSTRAINT uq_emp_email UNIQUE (emp_email)

);
CREATE SEQUENCE seq_emp_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Employee_contact (
    contact_ID    NUMBER,
    emp_ID        NUMBER NOT NULL,
    CONSTRAINT pk_employee_contact PRIMARY KEY (contact_ID),
    CONSTRAINT fk_contact_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) ON DELETE CASCADE
);
CREATE SEQUENCE seq_contact_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Salary_Bonus (
    Salary_ID     NUMBER,
    amount        NUMBER(10, 2) NOT NULL,
    annual        NUMBER(10, 2),
    Bouns         NUMBER(10, 2) DEFAULT 0,
    emp_ID        NUMBER NOT NULL,
    job_ID        NUMBER NOT NULL,
    CONSTRAINT pk_salary_bonus PRIMARY KEY (Salary_ID),
    CONSTRAINT fk_salary_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES Job_department(job_ID),
    CONSTRAINT chk_salary_amount CHECK (amount > 0)
);
CREATE SEQUENCE seq_salary_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Qualification (
    qual_ID       NUMBER,
    Position      VARCHAR2(100) NOT NULL,
    date_in       DATE DEFAULT SYSDATE,
    emp_ID        NUMBER NOT NULL,
    CONSTRAINT pk_qualification PRIMARY KEY (qual_ID),
    CONSTRAINT fk_qual_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
);
CREATE SEQUENCE seq_qual_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Qualification_requirement (
    qual_ID       NUMBER,
    requirement   VARCHAR2(150),
    CONSTRAINT pk_qual_requirement PRIMARY KEY (qual_ID, requirement),
    CONSTRAINT fk_req_qual FOREIGN KEY (qual_ID) REFERENCES Qualification(qual_ID) ON DELETE CASCADE
);

CREATE TABLE Pay_roll (
    Payroll_ID    NUMBER,
    "DATE"        DATE DEFAULT SYSDATE NOT NULL,
    report        VARCHAR2(250),
    total_amount  NUMBER(10, 2) NOT NULL,
    job_ID        NUMBER,
    Salary_ID     NUMBER,
    emp_ID        NUMBER,
    CONSTRAINT pk_payroll PRIMARY KEY (Payroll_ID),
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES Job_department(job_ID),
    CONSTRAINT fk_payroll_salary FOREIGN KEY (Salary_ID) REFERENCES Salary_Bonus(Salary_ID),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
);
CREATE SEQUENCE seq_payroll_id START WITH 1 INCREMENT BY 1;

CREATE TABLE Leave (
    leave_ID      NUMBER,
    "DATE"        DATE DEFAULT SYSDATE NOT NULL,
    reason        VARCHAR2(200),
    Payroll_ID    NUMBER,
    emp_ID        NUMBER NOT NULL,
    CONSTRAINT pk_leave PRIMARY KEY (leave_ID),
    CONSTRAINT fk_leave_payroll FOREIGN KEY (Payroll_ID) REFERENCES Pay_roll(Payroll_ID),
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
);
CREATE SEQUENCE seq_leave_id START WITH 1 INCREMENT BY 1;


--*********************SQL DML — INSERT / UPDATE / DELETE / SELECT*****************

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Human Resources', 'HR Manager', 'Managing employee relations', '1200 - 1800');

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Information Technology', 'Senior Java Developer', 'Developing APIs', '1500 - 2200');

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Finance', 'Financial Analyst', 'Budgeting, payroll overview', '1000 - 1400');

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Information Technology', 'Database Administrator', 'Managing Oracle databases', '1400 - 2000');

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Marketing', 'Marketing Specialist', 'Managing marketing', '800 - 1200');

INSERT INTO Job_department (job_ID, job_dept, name, description, salary_range)
VALUES (seq_job_id.NEXTVAL, 'Cyber Security', 'Cybersecurity Analyst', 'Analyst Security', '950 - 1200');

select * from Job_department;

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Ahmed', 'Al-Balushi', 34, 'M', 'p@ss1234', 'ahmed.b@company.com', 1);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Khadija', 'Al-Zadjali', 26, 'F', 'javaSecure77', 'khadija.z@company.com', 2);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Salim', 'Al-Harthi', 41, 'M', 'dbPass990', 'salim.h@company.com', 4);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Fatma', 'Al-Riyami', 29, 'F', 'finPass!@', 'fatma.r@company.com', 3);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Mohammed', 'Al-Abri', 25, 'M', 'mktg2026', 'mohammed.a@company.com', 5);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Said', 'Al-Siaidi', 30, 'M', 'said9090', 'said.s@company.com', 2);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Muna', 'Al-Ghafri', 32, 'F', 'munaPass#1', 'muna.g@company.com', 1);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Ali', 'Al-Ajmi', 28, 'M', 'aliDev44', 'ali.a@company.com', 2);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Aisha', 'Al-Hikmani', 35, 'F', 'aishaDBA8', 'aisha.h@company.com', 4);

INSERT INTO Employee (emp_ID, Fname, Lname, age, Gender, emp_pass, emp_email, job_ID)
VALUES (seq_emp_id.NEXTVAL, 'Hamed', 'Al-Rawahi', 27, 'M', 'hamedFin0', 'hamed.r@company.com', 3);

UPDATE Employee
SET job_ID = 6
WHERE emp_ID = 7;

SELECT * FROM Employee;

INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 1);
INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 2);
INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 3);
INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 4);
INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 5);
INSERT INTO Employee_contact (contact_ID, emp_ID) VALUES (seq_contact_id.NEXTVAL, 6);

SELECT * FROM Employee_contact;

INSERT INTO Salary_Bonus (Salary_ID, amount, annual, Bouns, emp_ID, job_ID)
VALUES (seq_salary_id.NEXTVAL, 1600.00, 19200.00, 200.00, 1, 1); 

INSERT INTO Salary_Bonus (Salary_ID, amount, annual, Bouns, emp_ID, job_ID)
VALUES (seq_salary_id.NEXTVAL, 2100.00, 25200.00, 350.00, 2, 2); 

INSERT INTO Salary_Bonus (Salary_ID, amount, annual, Bouns, emp_ID, job_ID)
VALUES (seq_salary_id.NEXTVAL, 1850.00, 22200.00, 150.00, 3, 4); 

INSERT INTO Salary_Bonus (Salary_ID, amount, annual, Bouns, emp_ID, job_ID)
VALUES (seq_salary_id.NEXTVAL, 1250.00, 15000.00, 100.00, 4, 3); 

INSERT INTO Salary_Bonus (Salary_ID, amount, annual, Bouns, emp_ID, job_ID)
VALUES (seq_salary_id.NEXTVAL, 950.00, 11400.00, 50.00, 5, 5);

SELECT * FROM Salary_Bonus;

INSERT INTO Qualification (qual_ID, Position, date_in, emp_ID)
VALUES (seq_qual_id.NEXTVAL, 'HR Director', TO_DATE('2020-05-12', 'YYYY-MM-DD'), 1);

INSERT INTO Qualification (qual_ID, Position, date_in, emp_ID)
VALUES (seq_qual_id.NEXTVAL, 'Oracle Certified Professional Java SE 17', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 2);

INSERT INTO Qualification (qual_ID, Position, date_in, emp_ID)
VALUES (seq_qual_id.NEXTVAL, 'Lead Infrastructure Management', TO_DATE('2018-02-15', 'YYYY-MM-DD'), 3);

INSERT INTO Qualification (qual_ID, Position, date_in, emp_ID)
VALUES (seq_qual_id.NEXTVAL, 'CMA', TO_DATE('2022-08-20', 'YYYY-MM-DD'), 4);

INSERT INTO Qualification (qual_ID, Position, date_in, emp_ID)
VALUES (seq_qual_id.NEXTVAL, 'Professional Digital Marketer', TO_DATE('2025-01-10', 'YYYY-MM-DD'), 5);

SELECT * FROM Qualification;

INSERT INTO Qualification_requirement (qual_ID, requirement) VALUES (1, 'Master');
INSERT INTO Qualification_requirement (qual_ID, requirement) VALUES (2, 'BSc in Computer Science');
INSERT INTO Qualification_requirement (qual_ID, requirement) VALUES (3, '10+ Years Database Administration Experience');
INSERT INTO Qualification_requirement (qual_ID, requirement) VALUES (4, 'BSc in Accounting or Finance');
INSERT INTO Qualification_requirement (qual_ID, requirement) VALUES (3, 'Expertise in Meta Ads Frameworks');

SELECT * FROM Pay_roll;

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 1800.00, 1, 1, 1);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 2450.00, 2, 2, 2);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 2000.00, 4, 3, 3);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 1350.00, 3, 4, 4);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-05-25', 'YYYY-MM-DD'), 'May Payroll - Regular', 1000.00, 5, 5, 5);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-06-25', 'YYYY-MM-DD'), 'June Payroll - Pending Approval', 1600.00, 1, 1, 1);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-06-25', 'YYYY-MM-DD'), 'June Payroll - Pending Approval', 2100.00, 2, 2, 2);

INSERT INTO Pay_roll (Payroll_ID, "DATE", report, total_amount, job_ID, Salary_ID, emp_ID)
VALUES (seq_payroll_id.NEXTVAL, TO_DATE('2026-06-25', 'YYYY-MM-DD'), 'June Payroll - Pending Approval', 1850.00, 4, 3, 3);


INSERT INTO Leave (leave_ID, "DATE", reason, Payroll_ID, emp_ID)
VALUES (seq_leave_id.NEXTVAL, TO_DATE('2026-05-10', 'YYYY-MM-DD'), 'Annual Leave - Approved', 1, 1);

INSERT INTO Leave (leave_ID, "DATE", reason, Payroll_ID, emp_ID)
VALUES (seq_leave_id.NEXTVAL, TO_DATE('2026-05-14', 'YYYY-MM-DD'), 'Sick Leave - Medical Report Attached', 2, 2);

INSERT INTO Leave (leave_ID, "DATE", reason, Payroll_ID, emp_ID)
VALUES (seq_leave_id.NEXTVAL, TO_DATE('2026-05-18', 'YYYY-MM-DD'), 'Emergency Leave - Personal Reasons', 3, 3);

INSERT INTO Leave (leave_ID, "DATE", reason, Payroll_ID, emp_ID)
VALUES (seq_leave_id.NEXTVAL, TO_DATE('2026-05-20', 'YYYY-MM-DD'), 'Casual Leave - Approved', 4, 4);

INSERT INTO Leave (leave_ID, "DATE", reason, Payroll_ID, emp_ID)
VALUES (seq_leave_id.NEXTVAL, TO_DATE('2026-06-02', 'YYYY-MM-DD'), 'Maternity Leave - Documented', 6, 7);

SELECT * FROM Leave;