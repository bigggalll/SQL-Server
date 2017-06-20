BEGIN TRAN;
UPDATE ##Suppliers
  SET
      Fax = N'555-1212'
WHERE supplierid = 1;

-- goto session 2

UPDATE ##Employees
  SET
      phone = N'555-9999'
WHERE empid = 1;

Rollback;
