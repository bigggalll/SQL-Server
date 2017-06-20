BEGIN TRAN;
UPDATE ##Employees
  SET
      EmpName = 'Mary'
WHERE empid = 1;

----> GoTo session2.sql

UPDATE ##Suppliers
  SET
      Fax = N'555-1212'
WHERE supplierid = 1;

ROLLBACK;