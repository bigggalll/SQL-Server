/*============================================================================
  File:     3b_tempdb_Configuration_Contention_setup.sql

  Summary:  This script creates a function and stored procedure
			that creates tempdb contention when executed
			repeatedly.

  Date:     October 2016

  SQL Server Version: 2005/2008/2008R2/2012/2014
------------------------------------------------------------------------------
  Written by Jonathan Kehayias, SQLskills.com

  For more scripts and other useful content, go to:
	http://www.SQLskills.com

  This script is intended only as a supplement to demos and lectures
  given by Jonathan Kehayias or Erin Stellato.  
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [AdventureWorks2016]
GO

IF OBJECT_ID(N'Person.USR_GetTopDuplicateCustomer') IS NOT NULL
BEGIN
	DROP FUNCTION [Person].[USR_GetTopDuplicateCustomer];
END
GO
CREATE FUNCTION [Person].[USR_GetTopDuplicateCustomer]  (@base  int)  
RETURNS @retval TABLE  
(   
      AddressLine1		NCHAR(600)		NOT NULL,   
      AddressLine2		NCHAR(600)		NULL,   
      City				NVARCHAR(30)	NOT NULL,   
      StateProvinceID	INT				NOT NULL,   
      CT				INT				NOT NULL,
	  PADDING			NCHAR(2800)		NOT NULL 
)  
AS  
BEGIN   
 
      INSERT INTO @retval   
      SELECT AddressLine1, AddressLine2, City, StateProvinceID, ct = COUNT(*), ''
      FROM [Person].[Address]   
      WHERE AddressID >= @base   
      GROUP BY AddressLine1, AddressLine2, StateProvinceID, City   
      HAVING COUNT(*) > 1   
 
      RETURN  
END
GO

IF OBJECT_ID(N'Person.USR_IsInTop100Customers') IS NOT NULL
BEGIN
	DROP FUNCTION [Person].[USR_IsInTop100Customers];
END
GO
CREATE FUNCTION  [Person].[USR_IsInTop100Customers](@base int)
RETURNS @retval TABLE
(
	AddressID INT
)
AS
BEGIN

	INSERT INTO @retval
	SELECT TOP 100 AddressID 
	FROM [Person].[Address] 
	WHERE AddressID >= @base
	ORDER BY AddressID;

	RETURN
END
GO

IF OBJECT_ID(N'Person.GetNextDuplicateCustomerSet') IS NOT NULL
BEGIN
    DROP PROCEDURE Person.GetNextDuplicateCustomerSet;
END
GO
CREATE PROCEDURE [Person].[GetNextDuplicateCustomerSet] (@base INT)
AS
BEGIN
    SELECT TOP 1 tdc.*
    FROM [Person].[Address] AS a 
    CROSS APPLY [Person].[USR_GetTopDuplicateCustomer](AddressID)  AS tdc
    WHERE AddressID IN 
           (SELECT TOP 100 AddressID 
             FROM [Person].[Address] 
             WHERE AddressID >= @base
             ORDER BY AddressID);
END
GO


/*  Run Tests from here  */

