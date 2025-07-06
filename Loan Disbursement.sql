Create database Loan_Disbursement ;

Use Loan_Disbursement ;

CREATE TABLE loan_applications (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    amount INT,
    status VARCHAR(50),
    assigned_to VARCHAR(50),
    approval_sla_hours INT,
    disbursed BOOLEAN,
    verification_mode VARCHAR(50),
    submitted_date DATE
);

INSERT INTO loan_applications VALUES
('L001', 'Rohan Gupta', 500000, 'In Verification', 'Anjali', 24, FALSE, 'Manual', '2025-07-01'),
('L002', 'Priya Sharma', 300000, 'Approved', 'Ramesh', 12, FALSE, 'Auto-OCR', '2025-07-02'),
('L003', 'Amit Verma', 200000, 'Rejected', 'Sunita', 36, FALSE, 'Manual', '2025-07-02'),
('L004', 'Meena Patel', 800000, 'Disbursed', NULL, 24, TRUE, 'Auto-OCR', '2025-07-03'),
('L005', 'Karan Mehta', 400000, 'Pending Credit', 'Rahul', 18, FALSE, 'Manual', '2025-07-04');

CREATE TABLE uat_test_cases (
    test_case_id VARCHAR(10) PRIMARY KEY,
    scenario VARCHAR(255),
    expected_result TEXT,
    actual_result TEXT,
    status VARCHAR(10),
    tester VARCHAR(100),
    test_date DATE,
    remarks TEXT
);

INSERT INTO uat_test_cases VALUES
('TC001', 'Auto OCR Verification', 'Documents auto-verified and flagged if blurry', 'Match', 'Pass', 'Harsh Yadav', '2025-07-06', '-'),
('TC002', 'Credit Officer Auto-Routing', 'Each routed based on officer’s current SLA load', 'Match', 'Pass', 'Ria Mehta', '2025-07-06', 'Validate load balancing'),
('TC003', 'Risk Officer Approval Parallel Execution', 'Both approvals should log within same SLA window', 'Match', 'Pass', 'Amit Roy', '2025-07-06', 'Check timestamp logging'),
('TC004', 'Auto Email Confirmation', 'Customer receives email with PDF confirmation', 'Match', 'Pass', 'Harsh Yadav', '2025-07-06', 'Confirm PDF attachment'),
('TC005', 'SLA Breach Alert', 'Alert triggers to supervisor after SLA breach', 'Match', 'Pass', 'Anjali Verma', '2025-07-06', 'SLA working as expected'),
('TC006', 'Audit Trail Generation', 'Each step logged with timestamp and actor ID', 'Match', 'Pass', 'Harsh Yadav', '2025-07-06', 'Log format to validate'),
('TC007', 'Negative Test – Missing Document', 'System blocks and highlights missing field', 'Match', 'Pass', 'Ria Mehta', '2025-07-06', 'Proper error shown');

CREATE TABLE change_log (
    change_id INT PRIMARY KEY,
    feature VARCHAR(100),
    description TEXT,
    requested_date DATE,
    completion_date DATE,
    status VARCHAR(20),
    owner VARCHAR(100),
    remarks TEXT
);

INSERT INTO change_log VALUES
(1, 'OCR Verification Module', 'Enhance accuracy and flag unreadable documents', '2025-07-03', '2025-07-05', 'Completed', 'R&D Team', 'Deployed after UAT Pass'),
(2, 'Auto-Routing Logic', 'Route based on Credit Officer SLA load', '2025-07-03', '2025-07-06', 'In Progress', 'DevOps Team', 'Pending UAT Case TC002'),
(3, 'Email Confirmation Workflow', 'Trigger confirmation email post disbursement', '2025-07-04', '2025-07-06', 'Completed', 'BA Team', 'Verified in TC004'),
(4, 'SLA Breach Alerts', 'Implement alert for Credit Team SLA breach', '2025-07-05', '2025-07-06', 'Completed', 'Compliance', 'Passed test case TC005'),
(5, 'Audit Trail Engine', 'Log timestamp & user actions for each process step', '2025-07-03', '2025-07-06', 'Completed', 'Audit & IT', 'Tested under TC006'),
(6, 'Document Validation Rules', 'Block submission if ID proof missing', '2025-07-04', '2025-07-06', 'Completed', 'QA Team', 'Covered in Negative Test TC007');

-- # Get All Loans Verified by OCR --

SELECT *
FROM loan_applications
WHERE verification_mode = 'Auto-OCR';

-- # 2. Count of OCR vs Manual Verifications --

SELECT 
    verification_mode,
    COUNT(*) AS total_cases
FROM loan_applications
GROUP BY verification_mode;

-- # 3. OCR-Verified Loans with SLA Breaches --

SELECT loan_id, customer_name, approval_sla_hours, submitted_date, assigned_to
FROM loan_applications
WHERE verification_mode = 'Auto-OCR'
  AND approval_sla_hours > 24;
  
-- # 4. Daily OCR Volume Trend --

SELECT 
    submitted_date,
    COUNT(*) AS ocr_cases
FROM loan_applications
WHERE verification_mode = 'Auto-OCR'
GROUP BY submitted_date
ORDER BY submitted_date;

-- #  5. OCR Cases Still Not Disbursed --

SELECT loan_id, customer_name, status
FROM loan_applications
WHERE verification_mode = 'Auto-OCR'
  AND disbursed = 0;
  
-- #  6. Auto-OCR Loans Ready for Disbursement (Approved) --

SELECT loan_id, customer_name, amount
FROM loan_applications
WHERE verification_mode = 'Auto-OCR'
  AND status = 'Approved'
  AND disbursed = 0;

-- # 7. Update a Loan to Set OCR Flag (Simulation) --

UPDATE loan_applications
SET verification_mode = 'Auto-OCR'
WHERE loan_id = 'L005';

-- #  OCR Accuracy Rate (Pass vs Total Processed) --

SELECT 
    (SELECT COUNT(*) FROM uat_test_cases 
     WHERE scenario LIKE '%OCR%' AND status = 'Pass') * 100.0 /
    (SELECT COUNT(*) FROM uat_test_cases 
     WHERE scenario LIKE '%OCR%') AS ocr_accuracy_percent;
     
-- # Average SLA (in hours) for Auto-OCR Loans --

SELECT 
    AVG(approval_sla_hours) AS avg_sla_ocr
FROM loan_applications
WHERE verification_mode = 'Auto-OCR';

-- # OCR Penetration Rate (OCR vs Total Submissions) -- 

SELECT 
    ROUND(
        (SELECT COUNT(*) FROM loan_applications WHERE verification_mode = 'Auto-OCR') * 100.0 /
        (SELECT COUNT(*) FROM loan_applications), 2
    ) AS ocr_penetration_percent;

-- KPI Dashboard View (All in One)  -- 

SELECT
    COUNT(*) AS total_loans,
    SUM(CASE WHEN verification_mode = 'Auto-OCR' THEN 1 ELSE 0 END) AS total_ocr,
    ROUND(SUM(CASE WHEN verification_mode = 'Auto-OCR' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS ocr_percent,
    ROUND(AVG(CASE WHEN verification_mode = 'Auto-OCR' THEN approval_sla_hours ELSE NULL END), 2) AS avg_ocr_sla,
    SUM(CASE WHEN disbursed = 1 THEN amount ELSE 0 END) AS total_disbursed,
    SUM(CASE WHEN disbursed = 1 AND verification_mode = 'Auto-OCR' THEN amount ELSE 0 END) AS ocr_disbursed
FROM loan_applications;



