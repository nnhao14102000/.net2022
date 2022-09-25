USE AdventureWorks2014;

--Listing 1.1
SELECT d.Name
FROM HumanResources.Department AS d
WHERE d.DepartmentID = 42;



--Listing 1.2
GRANT SHOWPLAN TO username;

--Listing 1.3
CREATE TABLE TempTable (  Id INT IDENTITY(1, 1),
                          Dsc NVARCHAR(50)
                       );

INSERT INTO TempTable (Dsc)
SELECT Name
FROM Sales.Store;

SELECT *
FROM TempTable;

DROP TABLE TempTable;

--Listing 1.4
USE AdventureWorks2014;
GO


SELECT p.LastName + ', ' + p.FirstName,
       p.Title,
       pp.PhoneNumber
FROM Person.Person AS p
JOIN Person.PersonPhone AS pp
   ON pp.BusinessEntityID = p.BusinessEntityID
JOIN Person.PhoneNumberType AS pnt
   ON pnt.PhoneNumberTypeID = pp.PhoneNumberTypeID
WHERE pnt.Name = 'Cell'
      AND p.LastName = 'Dempsey';
GO


--Listing 2.1
SELECT TOP (5)
   BusinessEntityID,
   PersonType,
   NameStyle,
   Title,
   FirstName,
   LastName,
   ModifiedDate
FROM Person.Person
WHERE ModifiedDate >= '20130601'
      AND ModifiedDate <= CURRENT_TIMESTAMP;


SELECT TOP (5)
   BusinessEntityID,
   PersonType,
   NameStyle,
   Title,
   FirstName,
   LastName,
   ModifiedDate
FROM Person.Person
WHERE ModifiedDate >= '20130601'
      AND ModifiedDate <= CURRENT_TIMESTAMP
	  order by ModifiedDate;


--listing 2.2
SELECT d.DepartmentID,
       d.Name,
       d.GroupName
FROM HumanResources.Department AS d
WHERE d.GroupName = 'Manufacturing';

--Listing 2.3
SELECT d.DepartmentID,
       d.Name,
       d.GroupName,
       edh.StartDate
FROM HumanResources.Department AS d
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
   ON edh.DepartmentID = d.DepartmentID
WHERE d.GroupName = 'Manufacturing';

--Listing 2.4
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
  SELECT d.DepartmentID,
      d.Name,
      d.GroupName
  FROM HumanResources.Department AS d
  WHERE d.GroupName = 'Manufacturing';
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

--Listing 2.5
--output listing from previous query

--Listing 3.1
SELECT  e.LoginID,
        e.JobTitle,
        e.BirthDate
FROM    HumanResources.Employee AS e
WHERE   e.BirthDate < DATEADD(YEAR, -50, GETUTCDATE());

--Listing 3.2
SELECT  e.LoginID,
        e.BusinessEntityID
FROM    HumanResources.Employee AS e;

--Listing 3.3
SELECT  e.BusinessEntityID,
        e.NationalIDNumber,
        e.LoginID,
        e.VacationHours,
        e.SickLeaveHours
FROM    HumanResources.Employee AS e
WHERE e.BusinessEntityID = 226;

--Listing 3.4
SELECT  p.BusinessEntityID,
        p.LastName,
        p.FirstName
FROM    Person.Person AS p
WHERE   p.LastName LIKE 'Jaf%';

--Listing 3.5
SELECT  p.BusinessEntityID,
        p.LastName,
        p.FirstName,
        p.NameStyle
FROM    Person.Person AS p
WHERE   p.LastName LIKE 'Jaf%';

--Listing 3.6
SELECT  dl.DatabaseUser,
        dl.PostTime,
        dl.Event,
        dl.DatabaseLogID
FROM    dbo.DatabaseLog AS dl;

--Listing 3.7
SELECT  dl.DatabaseUser,
        dl.PostTime,
        dl.Event,
        dl.DatabaseLogID
FROM    dbo.DatabaseLog AS dl
WHERE   dl.DatabaseLogID = 1;

--Listing 4.1
SELECT e.JobTitle,
       a.City,
       p.LastName + ', ' + p.FirstName AS EmployeeName
FROM HumanResources.Employee AS e
INNER JOIN Person.BusinessEntityAddress AS bea
   ON e.BusinessEntityID = bea.BusinessEntityID
INNER JOIN Person.Address AS a
   ON bea.AddressID = a.AddressID
INNER JOIN Person.Person AS p
   ON e.BusinessEntityID = p.BusinessEntityID;
--option(querytraceon 3604, querytraceon 8607, querytraceon 7352);
--OPTION(querytraceon 9415)

--listing 4.2
SELECT c.CustomerID
FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Sales.Customer AS c
        ON soh.CustomerID = c.CustomerID;



--Listing 4.3
SET STATISTICS IO ON;
SELECT      sod.ProductID,
            sod.SalesOrderID,
            pv.BusinessEntityID,
            pv.StandardPrice
FROM        Sales.SalesOrderDetail   AS sod
INNER JOIN  Purchasing.ProductVendor AS pv
      ON    pv.ProductID = sod.ProductID; 
SET STATISTICS IO OFF;



GO
DROP INDEX production.TransactionHistory.ix_cstest
GO

--Listing 4.4
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_CSTest
ON Production.TransactionHistory
(
    TransactionID,
    ProductID,
    ActualCost
); 


--listing 4.5
SELECT p.Name AS ProductName,
       th.ActualCost
FROM Production.TransactionHistory AS th
    JOIN Production.Product AS p
        ON p.ProductID = th.ProductID
WHERE th.ActualCost > 0
      AND th.ActualCost < 2;



/*--Listing 4.5
UPDATE Production.TransactionHistory
SET ActualCost = .20
WHERE TransactionID = 177901;

SELECT p.Name AS ProductName,
       th.ActualCost
FROM Production.TransactionHistory AS th
    JOIN Production.Product AS p
        ON p.ProductID = th.ProductID
WHERE th.ActualCost > 0
      AND th.ActualCost < .21;

UPDATE Production.TransactionHistory
SET ActualCost = .21
WHERE TransactionID = 177901;*/

--Listing 4.6
SELECT bom.ProductAssemblyID,
       bom.PerAssemblyQty
FROM Production.BillOfMaterials AS bom
WHERE EXISTS (   SELECT *
                 FROM Production.BillOfMaterials AS bom2
                 WHERE bom.BillOfMaterialsID = bom2.ComponentID
                       AND bom2.EndDate IS NOT NULL);


--Listing 4.7
SELECT p.LastName,
       p.BusinessEntityID
FROM Person.Person AS p
UNION ALL
SELECT p.Name,
       p.ProductID
FROM Production.Product AS p;


SELECT * FROM Production.Product AS p


/*
GO
--old
--Listing 4.5
CREATE OR ALTER FUNCTION dbo.ProductListPrice (@ProductID INT)
RETURNS @ListPrice TABLE (  StartDate DATETIME NOT NULL,
                            ListPrice MONEY NOT NULL
                         )
AS
BEGIN
   INSERT INTO @ListPrice
   SELECT TOP 1 plph.StartDate,
          plph.ListPrice
   FROM Production.ProductListPriceHistory AS plph
   WHERE plph.ProductID = @ProductID
   AND plph.EndDate IS NOT NULL
   ORDER BY plph.StartDate DESC;

   RETURN;
END
GO


--Listing 4.6
SELECT p.Name,
       plp.ListPrice
FROM Production.Product AS p
CROSS APPLY dbo.ProductListPrice(p.ProductID) AS plp;



--Listing 4.5
SELECT p.Name,
       plp.ListPrice
FROM Production.Product AS p
OUTER APPLY dbo.ProductListPrice(p.ProductID) AS plp;


--Listing 4.6
SELECT bom.ProductAssemblyID,
       bom.PerAssemblyQty
FROM Production.BillOfMaterials AS bom
WHERE EXISTS (  SELECT *
                FROM Production.BillOfMaterials AS bom2
                WHERE bom.BillOfMaterialsID = bom2.ComponentID
                      AND bom2.EndDate IS NOT NULL
             );
*/



--Listing 5.1
SELECT  pi.Shelf
FROM    Production.ProductInventory AS pi
ORDER BY pi.Shelf;


SELECT  pi.Shelf
FROM    Production.ProductInventory AS pi
ORDER BY pi.ProductID;



--Listing 5.2
SELECT TOP (50)
    p.LastName,
    p.FirstName
FROM Person.Person AS p
ORDER BY p.FirstName DESC;


--Listing 5.3
SELECT DISTINCT
   p.LastName,
   p.FirstName,
   p.MiddleName,
   p.Suffix
FROM Person.Person AS p;

--Listing 5.4
SELECT sod.CarrierTrackingNumber,
       sod.LineTotal
FROM Sales.SalesOrderDetail AS sod
WHERE sod.UnitPrice = sod.LineTotal
ORDER BY sod.ModifiedDate DESC;

--Listing 5.5
SELECT c.TerritoryID,
       COUNT(*)
FROM Sales.Customer AS c
GROUP BY c.TerritoryID;

--Listing 5.6
SELECT sod.UnitPrice,
       AVG(sod.UnitPriceDiscount)
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.UnitPrice;

--Listing 5.7
SELECT sod.UnitPrice,
       AVG(sod.UnitPriceDiscount)
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.UnitPrice
HAVING AVG(sod.UnitPriceDiscount) > .2;



SELECT sod.UnitPrice,
       AVG(sod.UnitPriceDiscount)
FROM Sales.SalesOrderDetail AS sod
GROUP BY sod.UnitPrice
HAVING sod.UnitPrice > 800;


--Listing 5.8
SELECT sp.BusinessEntityID,
       sp.TerritoryID,
       (   SELECT SUM(TaxAmt)
           FROM Sales.SalesOrderHeader AS soh
           WHERE soh.TerritoryID = sp.TerritoryID)
FROM Sales.SalesPerson AS sp
WHERE sp.TerritoryID IS NOT NULL
ORDER BY sp.TerritoryID;

--Listing 5.9
CREATE INDEX IX_SalesOrderHeader_TerritoryID
ON Sales.SalesOrderHeader
(
    TerritoryID
)
INCLUDE
(
    TaxAmt
);

--Listing 5.10
DROP INDEX IX_SalesOrderHeader_TerritoryID ON Sales.SalesOrderHeader;



--Listing 5.11
SELECT soh.CustomerID,
       soh.SubTotal,
       ROW_NUMBER() OVER (PARTITION BY soh.CustomerID 
							ORDER BY soh.OrderDate ASC) AS RowNum,
       soh.OrderDate
FROM Sales.SalesOrderHeader AS soh
WHERE soh.OrderDate BETWEEN '1/1/2013'
                    AND     '7/1/2013'
ORDER BY RowNum DESC,
         soh.OrderDate;


--Listing 5.12
SELECT soh.CustomerID,
       soh.SubTotal,
       AVG(soh.SubTotal) OVER (PARTITION BY soh.CustomerID) AS AverageSubTotal,
	   ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate ASC) AS RowNum
FROM Sales.SalesOrderHeader AS soh
WHERE soh.OrderDate
BETWEEN '1/1/2013' AND '7/1/2013';

--Listing 5.13
SELECT sod.SalesOrderDetailID,
       sod.ProductID,
	   sod.ModifiedDate
FROM Sales.SalesOrderDetail AS sod
WHERE LineTotal < (SELECT AVG(dos.LineTotal)
                   FROM Sales.SalesOrderDetail AS dos
                   WHERE dos.ModifiedDate < sod.ModifiedDate)
	  AND sod.ProductID = 758;





--Listing 6.1
BEGIN TRAN;
INSERT INTO Person.Address (  AddressLine1,
                              AddressLine2,
                              City,
                              StateProvinceID,
                              PostalCode,
                              rowguid,
                              ModifiedDate
                           )
VALUES (  N'1313 Mockingbird Lane',-- AddressLine1 - nvarchar(60)
          N'Basement', -- AddressLine2 - nvarchar(60)
          N'Springfield', -- City - nvarchar(30)
          79, -- StateProvinceID - int
          N'02134', -- PostalCode - nvarchar(15)
          NEWID(), -- rowguid - uniqueidentifier
          GETDATE() -- ModifiedDate - datetime
       );
ROLLBACK TRAN;

--Listing 6.2
--in book, from properties in plan from Listing 6.1




--Listing 6.3
BEGIN TRAN;
UPDATE Person.Address
SET City = 'Munro',
    ModifiedDate = GETDATE()
WHERE City = 'Monroe';
ROLLBACK TRAN;



DROP TABLE dbo.mytable;


--Listing 6.4
CREATE TABLE dbo.Mytable (id INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
                          val VARCHAR(50));

INSERT dbo.Mytable (val)
VALUES ('whoop' -- val
    );

UPDATE dbo.Mytable
SET val = 'WHOOP'
WHERE id = 1;


--Listing 6.5
BEGIN TRAN;
DELETE FROM Person.EmailAddress
WHERE BusinessEntityID = 42;
ROLLBACK TRAN;

GO
--Listing 6.6
CREATE OR ALTER VIEW dbo.TransactionHistoryView
WITH SCHEMABINDING
AS
SELECT COUNT_BIG(*) AS ProductCount,
       th.ProductID
FROM Production.TransactionHistory AS th
GROUP BY th.ProductID
GO
CREATE UNIQUE CLUSTERED INDEX TransactionHistoryCount
ON dbo.TransactionHistoryView
(
    ProductID
)
GO


BEGIN TRAN;
DELETE FROM Production.TransactionHistory
WHERE ProductID = 711;
ROLLBACK TRAN;


--Listing 6.7
DROP INDEX TransactionHistoryCount ON dbo.TransactionHistoryView;
GO
DROP VIEW dbo.TransactionHistoryView;
GO





--Listing 6.8
DECLARE @BusinessEntityId INT = 42,
        @AccountNumber NVARCHAR(15) = N'SSHI',
        @Name NVARCHAR(50) = N'Shotz Beer',
        @CreditRating TINYINT = 2,
        @PreferredVendorStatus BIT = 0,
        @ActiveFlag BIT = 1,
        @PurchasingWebServiceURL NVARCHAR(1024) = N'http://shotzbeer.com',
        @ModifiedDate DATETIME = GETDATE();

BEGIN TRANSACTION;
MERGE Purchasing.Vendor AS v
USING
(   SELECT @BusinessEntityId,
           @AccountNumber,
           @Name,
           @CreditRating,
           @PreferredVendorStatus,
           @ActiveFlag,
           @PurchasingWebServiceURL,
           @ModifiedDate) AS vn (BusinessEntityId, AccountNumber, NAME, CreditRating, PreferredVendorStatus, ActiveFlag, PurchasingWebServiceURL, ModifiedDate)
ON (v.AccountNumber = vn.AccountNumber)
WHEN MATCHED THEN
    UPDATE SET v.Name = vn.NAME,
               v.CreditRating = vn.CreditRating,
               v.PreferredVendorStatus = vn.PreferredVendorStatus,
               v.ActiveFlag = vn.ActiveFlag,
               v.PurchasingWebServiceURL = vn.PurchasingWebServiceURL,
               v.ModifiedDate = vn.ModifiedDate
WHEN NOT MATCHED THEN
    INSERT (BusinessEntityID,
            AccountNumber,
            Name,
            CreditRating,
            PreferredVendorStatus,
            ActiveFlag,
            PurchasingWebServiceURL,
            ModifiedDate)
    VALUES (vn.BusinessEntityId, vn.AccountNumber, vn.NAME, vn.CreditRating, vn.PreferredVendorStatus, vn.ActiveFlag,
            vn.PurchasingWebServiceURL, vn.ModifiedDate);
ROLLBACK TRANSACTION;

--listing 6.8
--output from properties

--listing 6.9
--output in book, compute scalar properties

--listing 6.10
--output in book

--listing 6.11
/*--…
@AccountNumber NVARCHAR(15) = 'SPEEDCO0001',
--…
*/


GO
--Chapter 7
--Listing 7.1
CREATE OR ALTER PROCEDURE Sales.TaxRateByState @CountryRegionCode NVARCHAR(3)
AS
SET NOCOUNT ON;

CREATE TABLE #TaxRateByState (SalesTaxRateID INT NOT NULL,
                              TaxRateName NVARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
                              TaxRate SMALLMONEY NOT NULL,
                              TaxType TINYINT NOT NULL,
                              StateName NVARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL);


INSERT INTO #TaxRateByState (SalesTaxRateID,
                             TaxRateName,
                             TaxRate,
                             TaxType,
                             StateName)
SELECT st.SalesTaxRateID,
       st.Name,
       st.TaxRate,
       st.TaxType,
       sp.Name AS StateName
FROM Sales.SalesTaxRate AS st
    JOIN Person.StateProvince AS sp
        ON st.StateProvinceID = sp.StateProvinceID
WHERE sp.CountryRegionCode = @CountryRegionCode;

DELETE #TaxRateByState
WHERE TaxRate < 7.5;

SELECT soh.SubTotal,
       soh.TaxAmt,
       trbs.TaxRate,
       trbs.TaxRateName
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesTerritory AS st
        ON st.TerritoryID = soh.TerritoryID
    JOIN Person.StateProvince AS sp
        ON sp.TerritoryID = st.TerritoryID
    JOIN #TaxRateByState AS trbs
        ON trbs.StateName = sp.Name;
GO


--Listing 7.2
EXEC Sales.TaxRateByState @CountryRegionCode = 'US';

--Listing 7.3
SELECT p.Name,
       p.ProductNumber,
       ph.ListPrice
FROM Production.Product AS p
    INNER JOIN Production.ProductListPriceHistory AS ph
        ON p.ProductID = ph.ProductID
           AND ph.StartDate = (   SELECT TOP (1)
                                         ph2.StartDate
                                  FROM Production.ProductListPriceHistory AS ph2
                                  WHERE ph2.ProductID = p.ProductID
                                  ORDER BY ph2.StartDate DESC);

--Listing 7.4
SELECT p.Name,
       p.ProductNumber,
       ph.ListPrice
FROM Production.Product AS p
    CROSS APPLY
(   SELECT TOP (1)
           ph2.ProductID,
           ph2.ListPrice
    FROM Production.ProductListPriceHistory AS ph2
    WHERE ph2.ProductID = p.ProductID
    ORDER BY ph2.StartDate DESC) AS ph;

--Listing 7.5
SELECT p.Name,
       p.ProductNumber,
       ph.ListPrice
FROM Production.Product AS p
    INNER JOIN Production.ProductListPriceHistory AS ph
        ON p.ProductID = ph.ProductID
           AND ph.StartDate = (   SELECT TOP (1)
                                         ph2.StartDate
                                  FROM Production.ProductListPriceHistory AS ph2
                                  WHERE ph2.ProductID = p.ProductID
                                  ORDER BY ph2.StartDate DESC)
WHERE p.ProductID = 839;

SELECT p.Name,
       p.ProductNumber,
       ph.ListPrice
FROM Production.Product AS p
    CROSS APPLY
(   SELECT TOP (1)
           ph2.ProductID,
           ph2.ListPrice
    FROM Production.ProductListPriceHistory AS ph2
    WHERE ph2.ProductID = p.ProductID
    ORDER BY ph2.StartDate DESC) AS ph
WHERE p.ProductID = 839;

go
--Listing 7.6
ALTER PROCEDURE dbo.uspGetManagerEmployees
    @BusinessEntityID int
AS
BEGIN
    SET NOCOUNT ON;
    WITH    EMP_cte(BusinessEntityID, OrganizationNode, FirstName, LastName, 
                RecursionLevel)
              -- CTE name and columns
              AS (SELECT    e.BusinessEntityID,
                            e.OrganizationNode,
                            p.FirstName,
                            p.LastName,
                            0 -- Get the initial list of Employees
                              -- for Manager n
                  FROM      HumanResources.Employee e
                  INNER JOIN Person.Person p
                            ON p.BusinessEntityID = e.BusinessEntityID
                  WHERE     e.BusinessEntityID = @BusinessEntityID
                  UNION ALL
                  SELECT    e.BusinessEntityID,
                            e.OrganizationNode,
                            p.FirstName,
                            p.LastName,
                            EMP_cte.RecursionLevel + 1 -- Join recursive
                                                 -- member to anchor
                  FROM      HumanResources.Employee e
                  INNER JOIN EMP_cte
                            ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode
                  INNER JOIN Person.Person p
                            ON p.BusinessEntityID = e.BusinessEntityID
                 )
        SELECT  EMP_cte.RecursionLevel,
                EMP_cte.OrganizationNode.ToString() AS OrganizationNode,
                p.FirstName AS 'ManagerFirstName',
                p.LastName AS 'ManagerLastName',
                EMP_cte.BusinessEntityID,
                EMP_cte.FirstName,
                EMP_cte.LastName -- Outer select from the CTE
        FROM    EMP_cte
        INNER JOIN HumanResources.Employee e
                ON EMP_cte.OrganizationNode.GetAncestor(1) = e.OrganizationNode
        INNER JOIN Person.Person p
                ON p.BusinessEntityID = e.BusinessEntityID
        ORDER BY EMP_cte.RecursionLevel,
                EMP_cte.OrganizationNode.ToString()
    OPTION  (MAXRECURSION 25); 
END;

--Listing 7.7
EXEC dbo.uspGetEmployeeManagers
    @BusinessEntityID = 9;

--Listing 7.8
SELECT  * 
FROM    Sales.vIndividualCustomer
WHERE   BusinessEntityId = 8743;

--Listing 7.9
SELECT ic.BusinessEntityID,
       ic.Title,
       ic.LastName,
       ic.FirstName
FROM Sales.vIndividualCustomer AS ic
WHERE BusinessEntityID = 8743;


go
--listing 7.10
DROP VIEW Person.vStateProvinceCountryRegion
GO

CREATE OR ALTER VIEW Person.vStateProvinceCountryRegion
WITH SCHEMABINDING
AS
SELECT sp.StateProvinceID,
       sp.StateProvinceCode,
       sp.IsOnlyStateProvinceFlag,
       sp.Name AS StateProvinceName,
       sp.TerritoryID,
       cr.CountryRegionCode,
       cr.Name AS CountryRegionName
FROM Person.StateProvince sp
    INNER JOIN Person.CountryRegion cr
        ON sp.CountryRegionCode = cr.CountryRegionCode;
GO

CREATE UNIQUE CLUSTERED INDEX IX_vStateProvinceCountryRegion
ON Person.vStateProvinceCountryRegion
(
    StateProvinceID ASC,
    CountryRegionCode ASC
)
GO


--Listing 7.11
SELECT vspcr.StateProvinceCode,
       vspcr.IsOnlyStateProvinceFlag,
       vspcr.CountryRegionName
FROM Person.vStateProvinceCountryRegion AS vspcr;

--Listing 7.12
SELECT  sp.Name AS StateProvinceName,
        cr.Name AS CountryRegionName
FROM    Person.StateProvince sp
INNER JOIN Person.CountryRegion cr
        ON sp.CountryRegionCode = cr.CountryRegionCode;

--Listing 7.13
SELECT a.City,
       v.StateProvinceName,
       v.CountryRegionName
FROM Person.Address a
    JOIN Person.vStateProvinceCountryRegion v
        ON a.StateProvinceID = v.StateProvinceID
WHERE a.AddressID = 22701;

GO

--Listing 7.14
/*CREATE FUNCTION [dbo].[ufnGetStock](@ProductID [int])
RETURNS [int] 
AS 
-- Returns the stock level for the product. This function is used internally only
BEGIN
    DECLARE @ret int;
    
    SELECT @ret = SUM(p.[Quantity]) 
    FROM [Production].[ProductInventory] p 
    WHERE p.[ProductID] = @ProductID 
        AND p.[LocationID] = '6'; -- Only look at inventory in the misc storage
    
    IF (@ret IS NULL) 
        SET @ret = 0
    
    RETURN @ret
END;
GO*/


--Listing 7.15
SELECT p.Name,
       dbo.ufnGetStock(p.ProductID)
FROM Production.Product AS p
WHERE p.Color = 'Black';

--Listing 7.16
/*CREATE FUNCTION dbo.GetStock (@ProductID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(pi.Quantity) AS QuantitySum
    FROM Production.ProductInventory AS pi
    WHERE pi.ProductID = @ProductID
          AND pi.LocationID = '6'
);


--Listing 7.17
SELECT p.Name,
       gs.QuantitySum
FROM Production.Product AS p
CROSS APPLY dbo.GetStock(p.ProductID) AS gs
WHERE p.Color = 'Black';

--Listing 7.18
CREATE FUNCTION dbo.GetStock2 (@ProductID INT)
RETURNS @GetStock TABLE (QuantitySum int NULL)
AS
BEGIN
    INSERT @GetStock
    (
        QuantitySum
    )
    SELECT SUM(pi.Quantity) AS QuantitySum
    FROM Production.ProductInventory AS pi
    WHERE pi.ProductID = @ProductID
          AND pi.LocationID = '6';

    RETURN;
END
 
--Listing 7.18a
SELECT p.Name,
       gs.QuantitySum
FROM Production.Product AS p
CROSS APPLY dbo.GetStock2(p.ProductID) AS gs
WHERE p.Color = 'Black';*/

GO

--Chapter 8, indexes
--Listing 8.1
DROP TABLE IF EXISTS NewOrders;
GO
SELECT SalesOrderID,
       SalesOrderDetailID,
       CarrierTrackingNumber,
       OrderQty,
       ProductID,
       SpecialOfferID,
       UnitPrice,
       UnitPriceDiscount,
       LineTotal,
       rowguid,
       ModifiedDate
INTO dbo.NewOrders
FROM Sales.SalesOrderDetail;
GO
ALTER TABLE dbo.NewOrders
ADD CONSTRAINT PK_NewOrders_SalesOrderID_SalesOrderDetailID
    PRIMARY KEY CLUSTERED
    (
        SalesOrderID,
        SalesOrderDetailID
    );

CREATE NONCLUSTERED INDEX IX_NewOrders_ProductID
ON dbo.NewOrders
(
    ProductID
);
GO
CREATE NONCLUSTERED INDEX IX_NewOrders_OrderQty
ON dbo.NewOrders
(
    OrderQty
);
GO


--Listing 8.2
/*SET STATISTICS XML ON;
GO
--init
SELECT  OrderQty,
        CarrierTrackingNumber
FROM    dbo.NewOrders
WHERE   ProductID = 897;
GO
SET STATISTICS XML OFF;
GO

--disable automatic statistics
ALTER DATABASE AdventureWorks2014
SET AUTO_UPDATE_STATISTICS OFF;
GO

--modify the data
BEGIN TRAN;
UPDATE  dbo.NewOrders
SET     ProductID = 897
WHERE   ProductID BETWEEN 800 AND 900;
GO

-- Capture the plan again
SET STATISTICS XML ON;
GO
SELECT  OrderQty,
        CarrierTrackingNumber
FROM    dbo.NewOrders
WHERE   ProductID = 897;

SET STATISTICS XML OFF;
GO

--Manually update statistics
UPDATE STATISTICS dbo.NewOrders
GO

--Capture a third execution plan
SET STATISTICS XML ON;
GO
SELECT  OrderQty,
        CarrierTrackingNumber
FROM    dbo.NewOrders
WHERE   ProductID = 897;

SET STATISTICS XML OFF;
GO


ROLLBACK TRAN;
GO

ALTER DATABASE AdventureWorks2014
SET AUTO_UPDATE_STATISTICS ON;
GO*/

--listing 8.2
SELECT OrderQty,
       SalesOrderID,
       SalesOrderDetailID,
       LineTotal
FROM dbo.NewOrders
WHERE OrderQty = 20;


--Listing 8.3
DBCC SHOW_STATISTICS('dbo.NewOrders',
                     'IX_NewOrders_OrderQty');

--Listing 8.4
DECLARE @OrderQuantity SMALLINT
SET @OrderQuantity = 20
SELECT OrderQty,
       SalesOrderID,
       SalesOrderDetailID,
       LineTotal
FROM dbo.NewOrders
WHERE OrderQty = @OrderQuantity;


--Listing 8.4
SELECT sod.OrderQty,
       sod.SalesOrderID,
       sod.SalesOrderDetailID,
       sod.LineTotal
FROM Sales.SalesOrderDetail AS sod
WHERE sod.OrderQty = 10;

--Listing 8.5
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_OrderQty
ON Sales.SalesOrderDetail
(
    OrderQty ASC
) ON [PRIMARY];

--Listing 8.6
DROP INDEX Sales.SalesOrderDetail.IX_SalesOrderDetail_OrderQty;

DBCC SHOW_STATISTICS('Sales.SalesOrderDetail',
                     'IX_SalesOrderDetail_OrderQty');



--Listing 8.7
SELECT sod.ProductID,
       sod.OrderQty,
       sod.UnitPrice
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 897;
GO

--Listing 8.8
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON Sales.SalesOrderDetail
(
    ProductID ASC
)
INCLUDE
(
    OrderQty,
    UnitPrice
)
WITH (DROP_EXISTING = ON);
GO

SET STATISTICS XML ON;
GO

SELECT sod.ProductID,
       sod.OrderQty,
       sod.UnitPrice
FROM Sales.SalesOrderDetail AS sod
WHERE sod.ProductID = 897;
GO
SET STATISTICS XML OFF;
GO

--Recreate original index 
CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID
ON Sales.SalesOrderDetail
(
    ProductID ASC
)
WITH (DROP_EXISTING = ON);
GO


--Listing 8.9
SELECT p.Name,
       COUNT(th.ProductID) AS CountProductID,
       SUM(th.Quantity) AS SumQuantity,
       AVG(th.ActualCost) AS AvgActualCost
FROM Production.TransactionHistory AS th
    JOIN Production.Product AS p
        ON p.ProductID = th.ProductID
WHERE th.ReferenceOrderID = 53458
GROUP BY th.ProductID,
         p.Name;




--Listing 8.10
CREATE NONCLUSTERED COLUMNSTORE INDEX ix_csTest
ON Production.TransactionHistory
(
    ProductID,
    Quantity,
    ActualCost,
    ReferenceOrderID,
    ReferenceOrderLineID,
    ModifiedDate
);



DROP TABLE dbo.TransactionHistory

DROP INDEX IX_CSTest ON Production.TransactionHistory


GO
--Listing 8.11
SELECT *
INTO dbo.TransactionHistory
FROM Production.TransactionHistory AS th;

CREATE CLUSTERED COLUMNSTORE INDEX ClusteredColumnStoreTest
ON dbo.TransactionHistory;

--Listing 8.12
SELECT p.Name,
       COUNT(th.ProductID) AS CountProductID,
       SUM(th.Quantity) AS SumQuantity,
       AVG(th.ActualCost) AS AvgActualCost
FROM dbo.TransactionHistory AS th
    JOIN Production.Product AS p
        ON p.ProductID = th.ProductID
GROUP BY th.ProductID,
         p.Name;

--Listing 8.13
--Create a Database for Memory Optimized Tables
CREATE DATABASE InMemoryTest
ON PRIMARY (NAME = InMemTestData,
            FILENAME = 'C:\Data\InMemTest.mdf',
            SIZE = 10GB,
            FILEGROWTH = 10GB),
   FILEGROUP InMem CONTAINS MEMORY_OPTIMIZED_DATA (NAME = InMem,
                                                   FILENAME = 'c:\data\inmem.ndf')
LOG ON (NAME = InMemTestLog,
        FILENAME = 'C:\Data\InMemTestLog.ldf',
        SIZE = 5GB,
        FILEGROWTH = 1GB);
GO

--Move to the new database
USE InMemoryTest;
GO

--Create some tables
CREATE TABLE dbo.Address (AddressID INTEGER NOT NULL IDENTITY PRIMARY KEY NONCLUSTERED HASH
                                                              WITH (BUCKET_COUNT = 128),
                          AddressLine1 VARCHAR(60) NOT NULL,
                          City VARCHAR(30) NOT NULL,
                          StateProvinceID INT NOT NULL)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE dbo.StateProvince (StateProvinceID INTEGER NOT NULL PRIMARY KEY NONCLUSTERED,
                                StateProvinceName VARCHAR(50) NOT NULL,
                                CountryRegionCode NVARCHAR(3) NOT NULL)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);

CREATE TABLE dbo.CountryRegion (CountryRegionCode NVARCHAR(3) NOT NULL PRIMARY KEY NONCLUSTERED,
                                CountryRegionName NVARCHAR(50) NOT NULL)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);


--Add Data to the tables
--Cross database queries can't be used with In-Memory Tables
SELECT a.AddressLine1,
       a.City,
       a.StateProvinceID
INTO dbo.AddressStage
FROM AdventureWorks2014.Person.Address AS a;

INSERT INTO dbo.Address (AddressLine1,
                         City,
                         StateProvinceID)
SELECT a.AddressLine1,
       a.City,
       a.StateProvinceID
FROM dbo.AddressStage AS a;

DROP TABLE dbo.AddressStage;

SELECT sp.StateProvinceID,
       sp.Name,
       sp.CountryRegionCode
INTO dbo.ProvinceStage
FROM AdventureWorks2014.Person.StateProvince AS sp;

INSERT INTO dbo.StateProvince (StateProvinceID,
                               StateProvinceName,
                               CountryRegionCode)
SELECT ps.StateProvinceID,
       ps.Name,
       ps.CountryRegionCode
FROM dbo.ProvinceStage AS ps;

DROP TABLE dbo.ProvinceStage;

SELECT cr.CountryRegionCode,
       cr.Name
INTO dbo.CountryStage
FROM AdventureWorks2014.Person.CountryRegion AS cr;

INSERT INTO dbo.CountryRegion (CountryRegionCode,
                               CountryRegionName)
SELECT cs.CountryRegionCode,
       cs.Name
FROM dbo.CountryStage AS cs

DROP TABLE dbo.CountryStage;
GO



--Listing 8.14
USE AdventureWorks2014;
GO
SELECT a.AddressLine1,
       a.City,
       sp.Name,
       cr.Name
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 42;


--Listing 8.15
USE InMemoryTest
GO
SELECT a.AddressLine1,
       a.City,
       sp.StateProvinceName,
       cr.CountryRegionName
FROM dbo.Address AS a
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN dbo.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID = 42;

--Listing 8.16
SELECT a.AddressLine1,
       a.City,
       sp.StateProvinceName,
       cr.CountryRegionName
FROM dbo.Address AS a
    JOIN dbo.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN dbo.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID BETWEEN 42
                  AND     52;

GO
--Listing 8.17
CREATE PROC dbo.AddressDetails @City VARCHAR(30)
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'us_english')
    SELECT a.AddressLine1,
           a.City,
           sp.StateProvinceName,
           cr.CountryRegionName
    FROM dbo.Address AS a
        JOIN dbo.StateProvince AS sp
            ON sp.StateProvinceID = a.StateProvinceID
        JOIN dbo.CountryRegion
        AS
        cr
            ON cr.CountryRegionCode = sp.CountryRegionCode
    WHERE a.City = @City;
END
GO

EXEC dbo.AddressDetails @City = N'London' -- nvarchar(30)





GO


USE AdventureWorks2014

SELECT a.AddressLine1,
       a.City,
       sp.Name,
       cr.Name
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON sp.StateProvinceID = a.StateProvinceID
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE a.AddressID BETWEEN 42
                  AND     52;



GO
DROP DATABASE InMemoryTest;
GO



--Listing 8.1
SET SHOWPLAN_XML ON;
--…
SET SHOWPLAN_XML OFF;

--Listing 8.2
SET STATISTICS XML ON;
--…
SET STATISTICS XML OFF;


--Listing 8.3
SET   SHOWPLAN_XML ON;
GO
SELECT  c.CustomerID,
        a.City,
        s.Name,
        st.Name
FROM    Sales.Customer AS c
JOIN    Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON c.TerritoryID = st.TerritoryID
JOIN    Person.BusinessEntityAddress AS bea
        ON c.CustomerID = bea.BusinessEntityID
JOIN    Person.Address AS a
        ON bea.AddressID = a.AddressID
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';

GO
SET SHOWPLAN_XML OFF;
GO  

--Listing 8.4
--XML output from query above

--Listing 8.5
--XML output from query above

--Listing 8.6
--XML output

--Listing 8.7
--XML output

--Listing 8.8
--XML output

--Listing 8.9
SET STATISTICS XML ON;
GO
SELECT  c.CustomerID,
        a.City,
        s.Name,
        st.Name
FROM    Sales.Customer AS c
JOIN    Sales.Store AS s
        ON c.StoreID = s.BusinessEntityID
JOIN    Sales.SalesTerritory AS st
        ON c.TerritoryID = st.TerritoryID
JOIN    Person.BusinessEntityAddress AS bea
        ON c.CustomerID = bea.BusinessEntityID
JOIN    Person.Address AS a
        ON bea.AddressID = a.AddressID
JOIN    Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE   st.Name = 'Northeast'
        AND sp.Name = 'New York';
GO 
SET STATISTICS XML OFF;
GO 

--Listing 8.10
--XML output

--Listing 8.11
--xml output

--Listing 8.12
SET STATISTICS XML ON;
GO
SELECT  poh.PurchaseOrderID,
        poh.ShipDate,
        poh.ShipMethodID
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.ShipDate BETWEEN '3/1/2014'  AND '3/3/2014';
GO
SET STATISTICS XML OFF;
GO  

--Listing 8.13
--XML output

--Listing 8.14
WITH Top1Query
AS (SELECT TOP 1
        dest.text,
        deqp.query_plan
    FROM sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    ORDER BY deqs.execution_count DESC
   )
SELECT TOP 3
    tq.text,
    op.value('@PhysicalOp',
                      'varchar(50)'
                  ) AS PhysicalOp,
    RelOp.op.value('@EstimateCPU',
                      'float'
                  )
    + RelOp.op.value('@EstimateIO',
                        'float'
                    ) AS EstimatedCost
FROM Top1Query AS tq
    CROSS APPLY tq.query_plan.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
    //RelOp') RelOp(op)
ORDER BY EstimatedCost DESC;

--Listing 8.15
WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT deqp.query_plan.value(
                             N'(//MissingIndex/@Database)[1]',
                             'NVARCHAR(256)'
                         ) AS DatabaseName,
       dest.text AS QueryText,
       deqs.total_elapsed_time,
       deqs.last_execution_time,
       deqs.execution_count,
       deqs.total_logical_writes,
       deqs.total_logical_reads,
       deqs.min_elapsed_time,
       deqs.max_elapsed_time,
       deqp.query_plan,
       deqp.query_plan.value(
                             N'(//MissingIndex/@Table)[1]',
                             'NVARCHAR(256)'
                         ) AS TableName,
       deqp.query_plan.value(
                             N'(//MissingIndex/@Schema)[1]',
                             'NVARCHAR(256)'
                         ) AS SchemaName,
       deqp.query_plan.value(
                             N'(//MissingIndexGroup/@Impact)[1]',
                             'DECIMAL(6,4)'
                         ) AS ProjectedImpact,
       ColumnGroup.value('./@Usage', 'NVARCHAR(256)') AS ColumnGroupUsage,
       ColumnGroupColumn.value('./@Name', 'NVARCHAR(256)') AS ColumnName
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
CROSS APPLY deqp.query_plan.nodes('//MissingIndexes/MissingIndexGroup/MissingIndex/ColumnGroup') AS t1(ColumnGroup)
CROSS APPLY t1.ColumnGroup.nodes('./Column') AS t2(ColumnGroupColumn);





--Chapter 9
--Listing 9.1
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO

SELECT ISNULL(p.Title,
              '') + ' ' + p.FirstName + ' ' + p.LastName AS PersonName
FROM Person.Person AS p
WHERE p.BusinessEntityID = 5;

SELECT ISNULL(p.Title,
              '') + ' ' + p.FirstName + ' ' + p.LastName AS PersonName
FROM Person.Person AS p
WHERE p.BusinessEntityID = 6;

SELECT ISNULL(p.Title,
              '') + ' ' + p.FirstName + ' ' + p.LastName AS PersonName
FROM Person.Person AS p
WHERE p.BusinessEntityID = 6;
GO



--Listing 9.2
SELECT cp.usecounts,
       cp.objtype,
       cp.plan_handle,
       DB_NAME(st.dbid) AS DatabaseName,
       OBJECT_NAME(st.objectid, st.dbid) AS ObjectName,
       st.text,
       qp.query_plan
FROM sys.dm_exec_cached_plans AS cp
    CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
    CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
WHERE st.text LIKE '%Person%'
      AND st.dbid = DB_ID('AdventureWorks2014');


--Listing 9.3
SELECT SUBSTRING(dest.text,
                 (deqs.statement_start_offset / 2) + 1,
                 (CASE deqs.statement_end_offset
                      WHEN -1 THEN
                          DATALENGTH(dest.text)
                      ELSE
                          deqs.statement_end_offset - deqs.statement_start_offset
                  END) / 2 + 1) AS QueryStatement,
       deqs.creation_time,
       deqs.execution_count,
       deqp.query_plan
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS dest
WHERE dest.text LIKE '%Person%'
      AND deqp.dbid = DB_ID('AdventureWorks2014')
ORDER BY deqs.execution_count DESC,
         deqs.creation_time;


--Listing 9.4
DECLARE @ii INT;
DECLARE @IterationsToDo INT = 500;
DECLARE @id VARCHAR(8);

SELECT @ii = 1;

WHILE @ii <= @IterationsToDo
BEGIN
    SELECT @ii = @ii + 1,
           @id = CONVERT(VARCHAR(5), @ii);

    EXECUTE ('SELECT ISNULL(Title, '''') + '' '' + FirstName + '' '' + LastName FROM Person.Person WHERE BusinessEntityID =' + @id);
END;
GO

DECLARE @ii INT;
DECLARE @IterationsToDo INT = 500;
DECLARE @id VARCHAR(8);

SELECT @ii = 1;

WHILE @ii <= @IterationsToDo
BEGIN
    SELECT @ii = @ii + 1,
           @id = CONVERT(VARCHAR(5), @ii);

    EXEC sys.sp_executesql N'
  SELECT ISNULL(Title, '''') + '' '' + FirstName + '' '' + LastName FROM Person.Person WHERE BusinessEntityID = @id',
N'@id int',
@id = @ii;
END;
GO

--Listing 9.5
SELECT decp.objtype,
       CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5, 2)) AS plans_In_Cache
FROM sys.dm_exec_cached_plans AS decp
GROUP BY decp.objtype
ORDER BY plans_In_Cache;


--Listing 9.6
SELECT a.AddressID,
       a.AddressLine1,
       a.City
FROM Person.Address AS a
WHERE a.AddressID = 42;

SELECT a.AddressID,
       a.AddressLine1,
       a.City
FROM Person.Address AS a
WHERE a.AddressID = 100;

--Listing 9.7
SELECT qsqt.query_sql_text,
       qsq.query_parameterization_type_desc,
       qsq.count_compiles,
       qsp.is_trivial_plan,
       qsrs.count_executions
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
    JOIN sys.query_store_runtime_stats AS qsrs
        ON qsrs.plan_id = qsp.plan_id
WHERE qsqt.query_sql_text LIKE '%@1%';


--Listing 9.8
SELECT a.AddressID,
       a.AddressLine1,
       a.City,
       bea.BusinessEntityID
FROM Person.Address AS a
    JOIN Person.BusinessEntityAddress AS bea
        ON bea.AddressID = a.AddressID
WHERE a.AddressID = 42;

--Listing 9.9
SELECT Person.FirstName + ' ' + Person.LastName,
       Person.Title
FROM Person.Person
WHERE Person.LastName = 'Diaz';

--Listing 9.10
DECLARE @sql NVARCHAR(400);
DECLARE @param NVARCHAR(400);

SELECT @sql =
  N'SELECT  p.Name,
            p.ProductNumber,
            th.ReferenceOrderID
    FROM    Production.Product AS p
    JOIN    Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE   th.ReferenceOrderID = @ReferenceOrderID;';

SELECT @param = N'@ReferenceOrderID int';

EXEC sys.sp_executesql @sql, @param, 53465;


ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
ALTER DATABASE AdventureWorks2014 SET QUERY_STORE CLEAR

SELECT CAST(qsp.query_plan AS XML)
FROM sys.query_store_query_text AS qsqt
    JOIN sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsqt.query_sql_text LIKE '%p.ProductNumber%'




--Listing 9.11
--C# code
/*using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace ExecuteSQL
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Data Source=MySQLInstance;Database=AdventureWorks2014;Integrated Security=true";

            try
            {
                using (SqlConnection myConnection = new SqlConnection(connectionString))
                {
                 myConnection.Open();
                 SqlCommand prepStatement = myConnection.CreateCommand();
                 prepStatement.CommandText = @"SELECT p.Name, p.ProductNumber,
                                 th.ReferenceOrderID
                                 FROM Production.Product AS p
                                 JOIN Production.TransactionHistory AS th
                                 ON th.ProductID = p.ProductID
                                 WHERE th.ReferenceOrderID = @ReferenceOrderID";
                prepStatement.Parameters.Add("@ReferenceOrderID", SqlDbType.Int);
                prepStatement.Prepare();
                prepStatement.Parameters["@ReferenceOrderID"].Value = 53465;
                prepStatement.ExecuteReader ();
                }
            }
            catch (SqlException e)
            {
                Console.WriteLine(e.Message);
                Console.Read();
            }
        }
    }
}
*/


--Listing 9.12
DECLARE @sql NVARCHAR(400);
DECLARE @param NVARCHAR(400);
DECLARE @PreparedStatement INT;
DECLARE @MyID INT;

SELECT @sql =
  N'SELECT  p.Name,
            p.ProductNumber,
            th.ReferenceOrderID
    FROM    Production.Product AS p
    JOIN    Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE   th.ReferenceOrderID = @ReferenceOrderID;';

SELECT @param = N'@ReferenceOrderID int';
SELECT @MyID = 53465;
EXEC sp_prepare @PreparedStatement OUTPUT, @param, @sql;
EXEC sp_execute @PreparedStatement, @MyID;
EXEC sp_unprepare @PreparedStatement;

GO
--Listing 9.13
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference (@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END
GO


--Listing 9.14
EXEC dbo.ProductTransactionHistoryByReference @ReferenceOrderID = 41798;


--Listing 9.15
SELECT DB_NAME(deps.database_id) AS DatabaseName,
       deps.cached_time,
       deps.min_elapsed_time,
       deps.max_elapsed_time,
       deps.last_elapsed_time,
       deps.total_elapsed_time,
       deqp.query_plan
FROM sys.dm_exec_procedure_stats AS deps
    CROSS APPLY sys.dm_exec_query_plan(deps.plan_handle) AS deqp
WHERE deps.object_id = OBJECT_ID('AdventureWorks2014.dbo.ProductTransactionHistoryByReference');

--Listing 9.16
SELECT dest.text,
       deqp.query_plan,
       deqs.execution_count,
       deqs.max_worker_time,
       deqs.max_logical_reads,
       deqs.max_logical_writes
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.ProductTransactionHistoryByReference%';

EXECUTE sp_configure 'show advanced options', '1';
RECONFIGURE;
GO
EXECUTE sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
DBCC FREEPROCCACHE;
GO


--Listing 9.17
EXECUTE sp_configure 'show advanced options', '1';
RECONFIGURE;
GO
EXECUTE sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
DBCC FREEPROCCACHE;
GO

--Listing 9.18
ALTER DATABASE SCOPED CONFIGURATION SET OPTIMIZE_FOR_AD_HOC_WORKLOADS = ON;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

--Listing 9.19
SELECT 42 AS TheAnswer,
       em.EmailAddress,
       a.City
FROM Person.BusinessEntityAddress AS bea
    JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
    JOIN Person.EmailAddress AS em
        ON bea.BusinessEntityID = em.BusinessEntityID
WHERE em.EmailAddress LIKE 'david%'
      AND sp.StateProvinceCode = 'WA';

	
--LIsting 9.20
EXECUTE sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXECUTE sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO
EXECUTE sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

--Listing 9.21
SELECT ISNULL(Person.Title,
              '') + ' ' + Person.FirstName + ' ' + Person.LastName
FROM Person.Person
WHERE Person.BusinessEntityID = 278;


--Listing 9.22
ALTER DATABASE AdventureWorks2014 SET PARAMETERIZATION FORCED;
GO

--Listing 9.23
ALTER DATABASE AdventureWorks2014 SET PARAMETERIZATION SIMPLE;
GO

--Listing 9.24
DECLARE @templateout NVARCHAR(MAX),
        @paramsout NVARCHAR(MAX);

EXEC sys.sp_get_query_template @querytext = N'SELECT  42 AS TheAnswer
       ,em.EmailAddress
       ,e.BirthDate
       ,a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e
            ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea
            ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a
            ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em
        ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE ''david%''
        AND sp.StateProvinceCode = ''WA'';',
                               @templatetext = @templateout OUTPUT,
                               @parameters = @paramsout OUTPUT;

EXEC sys.sp_create_plan_guide
    @name = N'MyTemplatePlanGuide',
    @stmt = @templateout,
    @type = N'TEMPLATE',
    @module_or_batch = NULL,
    @params = @paramsout,
    @hints = N'OPTION(PARAMETERIZATION FORCED)';


--Listing 9.25
EXEC sys.sp_create_plan_guide
  @name = N'MySQLPlanGuide',
  @stmt = N'SELECT  p.Name,
            p.ProductNumber,
            th.ReferenceOrderID
    FROM    Production.Product AS p
    JOIN    Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE   th.ReferenceOrderID = @ReferenceOrderID;',
  @type = N'SQL',
  @module_or_batch = NULL,
  @params = N'@ReferenceOrderID int',
  @hints = N'OPTION (OPTIMIZE FOR UNKNOWN)';

--Listing 9.26
EXEC sys.sp_create_plan_guide 
    @name = N'MyObjectPlanGuide',
    @stmt = N'WITH [EMP_cte]([BusinessEntityID], [OrganizationNode],
                              [FirstName], [LastName], [RecursionLevel])
                              -- CTE name and columns
AS (
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], 0 -- Get initial list of Employees for Manager n
FROM [HumanResources].[Employee] e 
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
WHERE e.[BusinessEntityID] = @BusinessEntityID
UNION ALL
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], [RecursionLevel] + 1
-- Join recursive member to anchor
FROM [HumanResources].[Employee] e 
     INNER JOIN [EMP_cte]
            ON e.[OrganizationNode].GetAncestor(1) =
                  [EMP_cte].[OrganizationNode]
    INNER JOIN [Person].[Person] p 
           ON p.[BusinessEntityID] = e.[BusinessEntityID]
)
SELECT [EMP_cte].[RecursionLevel],
       [EMP_cte].[OrganizationNode].ToString() as [OrganizationNode],
       p.[FirstName] AS ''ManagerFirstName'',
       p.[LastName] AS ''ManagerLastName'',
       [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName],
       [EMP_cte].[LastName] -- Outer select from the CTE
FROM [EMP_cte] 
     INNER JOIN [HumanResources].[Employee] e 
             ON [EMP_cte].[OrganizationNode].GetAncestor(1) = 
                  e.[OrganizationNode]
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
OPTION (MAXRECURSION 25) ',
    @type = N'OBJECT',
    @module_or_batch = N'dbo.uspGetManagerEmployees',
    @params = NULL,
    @hints = N'OPTION(RECOMPILE,MAXRECURSION 25)';

--Listing 9.26
SELECT  *
FROM    sys.plan_guides;


--Listing 9.27
SELECT pg.plan_guide_id,
       pg.name,
       fvpg.message,
       fvpg.severity,
       fvpg.state
FROM sys.plan_guides AS pg
    OUTER APPLY sys.fn_validate_plan_guide(pg.plan_guide_id) AS fvpg;


	--Listing 9.28
EXEC sys.sp_control_plan_guide @operation = N'DROP ALL', @name = N'*';

GO

--Listing 9.29
CREATE PROCEDURE Sales.CreditInfoBySalesPerson (@SalesPersonID INT)
AS
SELECT soh.AccountNumber,
       soh.CreditCardApprovalCode,
       soh.CreditCardID,
       soh.OnlineOrderFlag
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @SalesPersonID;

--Listing 9.30
SET STATISTICS XML ON
GO
SELECT  soh.AccountNumber ,
        soh.CreditCardApprovalCode ,
        soh.CreditCardID ,
        soh.OnlineOrderFlag
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesPersonID = 285;
GO
SET STATISTICS XML OFF
GO

--Listing 9.31
EXEC sys.sp_create_plan_guide
    @name = N'UsePlanPlanGuide',
    @stmt = N'SELECT soh.AccountNumber,
       soh.CreditCardApprovalCode,
       soh.CreditCardID,
       soh.OnlineOrderFlag
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @SalesPersonID;',
    @type = N'OBJECT',
    @module_or_batch = N'Sales.CreditInfoBySalesPerson',
    @params = NULL,
    @hints = N'<ShowPlanXML xmlns="http://sche...'


--Listing 9.32
EXEC Sales.CreditInfoBySalesPerson @SalesPersonID = 277;

--Listing 9.33
SELECT Object_Name(qsq.object_id) AS ObjectName,
  Cast(qsp.query_plan AS XML) AS xmlplan, qsq.query_id, qsp.plan_id
  FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
      ON qsp.query_id = qsq.query_id
  WHERE qsq.object_id = Object_Id('Sales.CreditInfoBySalesPerson');

--Listing 9.34
EXEC sys.sp_query_store_force_plan @query_id = 5004, @pland_id = 5111;

--Listing 9.35
EXEC sp_query_store_unforce_plan @query_id = 5004, @pland_id = 5111; 


/*
--old chapter 9 listings retained... just in case
--Listing 9.1
SELECT SUBSTRING(dest.text,
                 (der.statement_start_offset / 2) + 1,
                 (CASE der.statement_end_offset
                      WHEN-1 THEN
                          DATALENGTH(dest.text)
                      ELSE
                          der.statement_end_offset - der.statement_start_offset
                  END) / 2 + 1) AS QueryStatement,
       deqp.query_plan,
       der.start_time,
       der.status,
       DB_NAME(der.database_id) AS DatabaseName,
       USER_NAME(der.user_id) AS UserName,
       der.wait_type,
       der.wait_time
FROM sys.dm_exec_requests AS der
    CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest;
	GO--Listing 9.2
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference (@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END
GO

--Listing 9.3
EXEC dbo.ProductTransactionHistoryByReference @ReferenceOrderID = 41798;

--Listing 9.4
SELECT DB_NAME(deps.database_id) AS DatabaseName,
       deps.cached_time,
       deps.min_elapsed_time,
       deps.max_elapsed_time,
       deps.last_elapsed_time,
       deps.total_elapsed_time,
       deqp.query_plan
FROM sys.dm_exec_procedure_stats AS deps
    CROSS APPLY sys.dm_exec_query_plan(deps.plan_handle) AS deqp
WHERE deps.object_id = OBJECT_ID('AdventureWorks2014.dbo.ProductTransactionHistoryByReference');

--Listing 9.5
SELECT dest.text,
       deqp.query_plan,
       deqs.execution_count,
       deqs.max_worker_time,
       deqs.max_logical_reads,
       deqs.max_logical_writes
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'CREATE PROC dbo.ProductTransactionHistoryByReference%';

GO
--Listing 9.6
/*
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference (
     @ReferenceOrderID int
    )
AS...
*/

--Listing 9.7
EXEC sys.sp_executesql
    N'SELECT  p.Name,
            p.ProductNumber,
            th.ReferenceOrderID
    FROM    Production.Product AS p
    JOIN    Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE   th.ReferenceOrderID = @ReferenceOrderID;',
    N'@ReferenceOrderID int',
    @ReferenceOrderID = 53465;


--Listing 9.8
/*SqlCommand prepStatement = dbConnection.CreateCommand();

prepStatement.CommandText = "SELECT p.Name,
       p.ProductNumber,
       th.ReferenceOrderID
FROM Production.Product AS p
    JOIN Production.TransactionHistory AS th
        ON th.ProductID = p.ProductID
WHERE th.ReferenceOrderID = @ReferenceOrderID;”

prepStatement.Parameters.Add("@ReferenceOrderID", SqlDbType.Int);

prepStatement.Prepare();
prepStatement.Parameters["@ReferenceOrderID"].Value = 53465;
prepStatement.ExecuteNonQuery();*/

--Listing 9.9
DECLARE @ReferenceOrderID INT;

--Listing 9.10
EXEC dbo.ProductTransactionHistoryByReference
    @ReferenceOrderID = 41798;

--Listing 9.11
DBCC SHOW_STATISTICS('Production.TransactionHistory', 'IX_TransactionHistory_ReferenceOrderID_ReferenceOrderLineID');

--Listing 9.12
DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO

--Listing 9.13
EXEC dbo.ProductTransactionHistoryByReference
    @referenceorderid = 53465;

GO
--Listing 9.14
ALTER PROC dbo.ProductTransactionHistoryByReference (@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID
    OPTION (OPTIMIZE FOR (@ReferenceOrderID UNKNOWN));
END
GO

--Listing 9.15
SELECT OBJECT_NAME(qsq.object_id),
       CAST(qsp.query_plan AS XML) AS xmlplan,
       qsq.query_id,
       qsp.plan_id
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

--Listing 9.16
EXEC sys.sp_query_store_force_plan @query_id = 97, @pland_id = 102;

--Listing 9.17
SELECT a.AddressID,
       a.AddressLine1,
       a.City
FROM Person.Address AS a
WHERE a.AddressID = 42;

--Listing 9.18
SELECT a.AddressID,
       a.AddressLine1,
       a.City,
       bea.BusinessEntityID
FROM Person.Address AS a
    JOIN Person.BusinessEntityAddress AS bea
        ON bea.AddressID = a.AddressID
WHERE a.AddressID = 42;

--Listing 9.19
SELECT 42 AS TheAnswer,
       em.EmailAddress,
       a.City
FROM Person.BusinessEntityAddress AS bea
    JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
    JOIN Person.EmailAddress AS em
        ON bea.BusinessEntityID = em.BusinessEntityID
WHERE em.EmailAddress LIKE 'david%'
      AND sp.StateProvinceCode = 'WA';

--Listing 9.20
ALTER DATABASE AdventureWorks2014 SET PARAMETERIZATION FORCED;
GO

--Listing 9.21
SELECT 42 AS TheAnswer,
       em.EmailAddress,
       a.City
FROM Person.BusinessEntityAddress AS bea
    JOIN Person.Address AS a
        ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
    JOIN Person.EmailAddress AS em
        ON bea.BusinessEntityID = em.BusinessEntityID
WHERE em.EmailAddress LIKE 'david%'
      AND sp.StateProvinceCode = @0

--Listing 9.22
ALTER DATABASE AdventureWorks2014 SET PARAMETERIZATION SIMPLE;
GO

--Listing 9.23
EXEC sp_configure 'show advanced option', 1;
RECONFIGURE;
GO
EXECUTE sys.sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE;
DBCC FREEPROCCACHE();
GO


--Listing 9.24
SELECT deqs.execution_count,
       deqp.query_plan
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE 'SELECT  42 AS TheAnswer%';


--Listing 9.25
EXECUTE sys.sp_configure 'optimize for ad hoc workloads', 0;
RECONFIGURE;
GO
EXEC sp_configure 'show advanced option', 0;
RECONFIGURE;
GO


--Listing 9.26
EXEC sys.sp_create_plan_guide @name = N'MyFirstPlanGuide',
    @stmt = N'WITH [EMP_cte]([BusinessEntityID], [OrganizationNode],
                              [FirstName], [LastName], [RecursionLevel])
                              -- CTE name and columns
AS (
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], 0 -- Get initial list of Employees for Manager n
FROM [HumanResources].[Employee] e 
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
WHERE e.[BusinessEntityID] = @BusinessEntityID
UNION ALL
SELECT e.[BusinessEntityID], e.[OrganizationNode], p.[FirstName],
       p.[LastName], [RecursionLevel] + 1
-- Join recursive member to anchor
FROM [HumanResources].[Employee] e 
     INNER JOIN [EMP_cte]
            ON e.[OrganizationNode].GetAncestor(1) =
                  [EMP_cte].[OrganizationNode]
    INNER JOIN [Person].[Person] p 
           ON p.[BusinessEntityID] = e.[BusinessEntityID]
)
SELECT [EMP_cte].[RecursionLevel],
       [EMP_cte].[OrganizationNode].ToString() as [OrganizationNode],
       p.[FirstName] AS ''ManagerFirstName'',
       p.[LastName] AS ''ManagerLastName'',
       [EMP_cte].[BusinessEntityID], [EMP_cte].[FirstName],
       [EMP_cte].[LastName] -- Outer select from the CTE
FROM [EMP_cte] 
     INNER JOIN [HumanResources].[Employee] e 
             ON [EMP_cte].[OrganizationNode].GetAncestor(1) = 
                  e.[OrganizationNode]
     INNER JOIN [Person].[Person] p 
            ON p.[BusinessEntityID] = e.[BusinessEntityID]
ORDER BY [RecursionLevel], [EMP_cte].[OrganizationNode].ToString()
OPTION (MAXRECURSION 25) ', @type = N'OBJECT',
    @module_or_batch = N'dbo.uspGetManagerEmployees', @params = NULL,
    @hints = N'OPTION(RECOMPILE,MAXRECURSION 25)';

--Listing 9.27
EXEC dbo.uspGetManagerEmployees 
@BusinessEntityID = 42;

--Listing 9.28
SELECT soh.SalesOrderNumber,
       sod.CarrierTrackingNumber
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesPersonID = 277;

DBCC FREEPROCCACHE
EXEC sys.sp_control_plan_guide @operation = N'drop', -- nvarchar(60)
                               @name = 'MySecondPlanGuide'      -- sysname


--Listing 9.29
EXEC sys.sp_create_plan_guide
    @name = N'MySecondPlanGuide',
    @stmt = 'SELECT soh.SalesOrderNumber,
       sod.CarrierTrackingNumber
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.SalesPersonID = 277;',
    @type = N'SQL',
    @module_or_batch = NULL,
    @params = NULL,
    @hints = N'OPTION (TABLE HINT(soh,INDEX = IX_SalesOrderHeader_SalesPersonID))';

--Listing 9.30
DECLARE @templateout NVARCHAR(MAX),
        @paramsout NVARCHAR(MAX)

EXEC sys.sp_get_query_template @querytext = N'SELECT  42 AS TheAnswer
       ,em.EmailAddress
       ,e.BirthDate
       ,a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e
            ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea
            ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a
            ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em
        ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE ''david%''
        AND sp.StateProvinceCode = ''WA'';',
                               @templatetext = @templateout OUTPUT,
                               @parameters = @paramsout OUTPUT

EXEC sys.sp_create_plan_guide
    @name = N'MyThirdPlanGuide',
    @stmt = @templateout,
    @type = N'TEMPLATE',
    @module_or_batch = NULL,
    @params = @paramsout,
    @hints = N'OPTION(PARAMETERIZATION FORCED)';

SELECT  42 AS TheAnswer
       ,em.EmailAddress
       ,e.BirthDate
       ,a.City
FROM    Person.Person AS p
        JOIN HumanResources.Employee e
            ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Person.BusinessEntityAddress AS bea
            ON p.BusinessEntityID = bea.BusinessEntityID
        JOIN Person.Address a
            ON bea.AddressID = a.AddressID
        JOIN Person.StateProvince AS sp
            ON a.StateProvinceID = sp.StateProvinceID
        JOIN Person.EmailAddress AS em
        ON e.BusinessEntityID = em.BusinessEntityID
WHERE   em.EmailAddress LIKE 'david%'
        AND sp.StateProvinceCode = 'WA';


DBCC FREEPROCCACHE
EXEC sys.sp_control_plan_guide @operation = N'drop', -- nvarchar(60)
                               @name = 'MyThirdPlanGuide'      -- sysname






--listing 9.31
SELECT *
FROM sys.plan_guides AS pg;


--Listing 9.32
EXEC sys.sp_control_plan_guide @operation = N'DROP ALL', @name = N'*';


--Lisint 9.33
SELECT pg.plan_guide_id,
       pg.name,
       fvpg.message,
       fvpg.severity,
       fvpg.state
FROM sys.plan_guides AS pg
    OUTER APPLY sys.fn_validate_plan_guide(pg.plan_guide_id) AS fvpg;

GO
--Listing 9.34
CREATE PROCEDURE Sales.CreditInfoBySalesPerson (@SalesPersonID INT)
AS
SELECT soh.AccountNumber,
       soh.CreditCardApprovalCode,
       soh.CreditCardID,
       soh.OnlineOrderFlag
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @SalesPersonID;

EXEC sales.CreditInfoBySalesPerson @SalesPersonID = 277; -- int

DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deps.plan_handle
FROM    sys.dm_exec_procedure_stats AS deps
WHERE   deps.object_id = OBJECT_ID('Sales.CreditInfoBySalesPerson');

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END
GO

EXEC Sales.CreditInfoBySalesPerson @SalesPersonID = 285; -- int

--Listing 9.35
SET STATISTICS XML ON
GO
SELECT  soh.AccountNumber ,
        soh.CreditCardApprovalCode ,
        soh.CreditCardID ,
        soh.OnlineOrderFlag
FROM    Sales.SalesOrderHeader AS soh
WHERE   soh.SalesPersonID = 285;
GO
SET STATISTICS XML OFF
GO

--Listing 9.36
EXEC sys.sp_create_plan_guide
    @name = N'UsePlanPlanGuide',
    @stmt = N'SELECT soh.AccountNumber,
       soh.CreditCardApprovalCode,
       soh.CreditCardID,
       soh.OnlineOrderFlag
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @SalesPersonID;',
    @type = N'OBJECT',
    @module_or_batch = N'Sales.CreditInfoBySalesPerson',
    @params = NULL,
	@hints = N'<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.6" Build="14.0.3008.27"><BatchSequence><Batch><Statements><StmtSimple StatementText="SELECT [soh].[AccountNumber],[soh].[CreditCardApprovalCode],[soh].[CreditCardID],[soh].[OnlineOrderFlag] FROM [Sales].[SalesOrderHeader] [soh] WHERE [soh].[SalesPersonID]=@1" StatementId="1" StatementCompId="1" StatementType="SELECT" StatementSqlHandle="0x090021CAC6983D30666CE72E6CBDFF65D7F70000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="1" ParentObjectId="0" StatementParameterizationType="0" RetrievedFromCache="false" StatementSubTreeCost="0.0522951" StatementEstRows="16" SecurityPolicyApplied="false" StatementOptmLevel="FULL" QueryHash="0x271CB2B3F6031B63" QueryPlanHash="0x690551DB59CE0365" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="140"><StatementSetOptions QUOTED_IDENTIFIER="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" NUMERIC_ROUNDABORT="false"></StatementSetOptions><QueryPlan DegreeOfParallelism="1" CachedPlanSize="32" CompileTime="2" CompileCPU="2" CompileMemory="296"><MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0"></MemoryGrantInfo><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="461979" EstimatedPagesCached="57747" EstimatedAvailableDegreeOfParallelism="2" MaxCompileMemory="4500640"></OptimizerHardwareDependentProperties><OptimizerStatsUsage><StatisticsInfo LastUpdate="2014-07-17T16:11:32.44" ModificationCount="0" SamplingPercent="100" Statistics="[IX_SalesOrderHeader_SalesPersonID]" Table="[SalesOrderHeader]" Schema="[Sales]" Database="[AdventureWorks2014]"></StatisticsInfo></OptimizerStatsUsage><QueryTimeStats ElapsedTime="0" CpuTime="0"></QueryTimeStats><RelOp NodeId="0" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="16" EstimateIO="0" EstimateCPU="6.688e-005" AvgRowSize="40" EstimatedTotalSubtreeCost="0.0522951" StatsCollectionId="4" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualEndOfScans="1" ActualExecutions="1"></RunTimeCountersPerThread></RunTimeInformation><NestedLoops Optimized="0"><OuterReferences><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></OuterReferences><RelOp NodeId="1" PhysicalOp="Index Seek" LogicalOp="Index Seek" EstimateRows="16" EstimatedRowsRead="16" EstimateIO="0.003125" EstimateCPU="0.0001746" AvgRowSize="11" EstimatedTotalSubtreeCost="0.0032996" TableCardinality="31465" StatsCollectionId="4" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="2" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="16" ActualEndOfScans="1" ActualExecutions="1"></RunTimeCountersPerThread></RunTimeInformation><IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></DefinedValue></DefinedValues><Object Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[IX_SalesOrderHeader_SalesPersonID]" Alias="[soh]" IndexKind="NonClustered" Storage="RowStore"></Object><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesPersonID"></ColumnReference></RangeColumns><RangeExpressions><ScalarOperator ScalarString="(285)"><Const ConstValue="(285)"></Const></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp><RelOp NodeId="3" PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek" EstimateRows="1" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="40" EstimatedTotalSubtreeCost="0.0489286" TableCardinality="31465" StatsCollectionId="6" Parallel="0" EstimateRebinds="15" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="48" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="16" ActualEndOfScans="0" ActualExecutions="16"></RunTimeCountersPerThread></RunTimeInformation><IndexScan Lookup="1" Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></DefinedValue></DefinedValues><Object Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[PK_SalesOrderHeader_SalesOrderID]" Alias="[soh]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore"></Object><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[AdventureWorks2014].[Sales].[SalesOrderHeader].[SalesOrderID] as [soh].[SalesOrderID]"><Identifier><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></Identifier></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp></NestedLoops></RelOp><ParameterList><ColumnReference Column="@1" ParameterDataType="smallint" ParameterCompiledValue="(285)" ParameterRuntimeValue="(285)"></ColumnReference></ParameterList></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>'
--    @hints = N'OPTION(USE PLAN N''<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.6" Build="14.0.3008.27"><BatchSequence><Batch><Statements><StmtSimple StatementText="SELECT [soh].[AccountNumber],[soh].[CreditCardApprovalCode],[soh].[CreditCardID],[soh].[OnlineOrderFlag] FROM [Sales].[SalesOrderHeader] [soh] WHERE [soh].[SalesPersonID]=@1" StatementId="1" StatementCompId="1" StatementType="SELECT" StatementSqlHandle="0x090021CAC6983D30666CE72E6CBDFF65D7F70000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="1" ParentObjectId="0" StatementParameterizationType="0" RetrievedFromCache="false" StatementSubTreeCost="0.0522951" StatementEstRows="16" SecurityPolicyApplied="false" StatementOptmLevel="FULL" QueryHash="0x271CB2B3F6031B63" QueryPlanHash="0x690551DB59CE0365" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="140"><StatementSetOptions QUOTED_IDENTIFIER="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" NUMERIC_ROUNDABORT="false"></StatementSetOptions><QueryPlan DegreeOfParallelism="1" CachedPlanSize="32" CompileTime="2" CompileCPU="2" CompileMemory="296"><MemoryGrantInfo SerialRequiredMemory="0" SerialDesiredMemory="0"></MemoryGrantInfo><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="461979" EstimatedPagesCached="57747" EstimatedAvailableDegreeOfParallelism="2" MaxCompileMemory="4500640"></OptimizerHardwareDependentProperties><OptimizerStatsUsage><StatisticsInfo LastUpdate="2014-07-17T16:11:32.44" ModificationCount="0" SamplingPercent="100" Statistics="[IX_SalesOrderHeader_SalesPersonID]" Table="[SalesOrderHeader]" Schema="[Sales]" Database="[AdventureWorks2014]"></StatisticsInfo></OptimizerStatsUsage><QueryTimeStats ElapsedTime="0" CpuTime="0"></QueryTimeStats><RelOp NodeId="0" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="16" EstimateIO="0" EstimateCPU="6.688e-005" AvgRowSize="40" EstimatedTotalSubtreeCost="0.0522951" StatsCollectionId="4" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualEndOfScans="1" ActualExecutions="1"></RunTimeCountersPerThread></RunTimeInformation><NestedLoops Optimized="0"><OuterReferences><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></OuterReferences><RelOp NodeId="1" PhysicalOp="Index Seek" LogicalOp="Index Seek" EstimateRows="16" EstimatedRowsRead="16" EstimateIO="0.003125" EstimateCPU="0.0001746" AvgRowSize="11" EstimatedTotalSubtreeCost="0.0032996" TableCardinality="31465" StatsCollectionId="4" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="2" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="16" ActualEndOfScans="1" ActualExecutions="1"></RunTimeCountersPerThread></RunTimeInformation><IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></DefinedValue></DefinedValues><Object Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[IX_SalesOrderHeader_SalesPersonID]" Alias="[soh]" IndexKind="NonClustered" Storage="RowStore"></Object><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesPersonID"></ColumnReference></RangeColumns><RangeExpressions><ScalarOperator ScalarString="(285)"><Const ConstValue="(285)"></Const></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp><RelOp NodeId="3" PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek" EstimateRows="1" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="40" EstimatedTotalSubtreeCost="0.0489286" TableCardinality="31465" StatsCollectionId="6" Parallel="0" EstimateRebinds="15" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></OutputList><RunTimeInformation><RunTimeCountersPerThread Thread="0" ActualRows="16" Batches="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="48" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualRowsRead="16" ActualEndOfScans="0" ActualExecutions="16"></RunTimeCountersPerThread></RunTimeInformation><IndexScan Lookup="1" Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="OnlineOrderFlag"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="AccountNumber"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardID"></ColumnReference></DefinedValue><DefinedValue><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="CreditCardApprovalCode"></ColumnReference></DefinedValue></DefinedValues><Object Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Index="[PK_SalesOrderHeader_SalesOrderID]" Alias="[soh]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore"></Object><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[AdventureWorks2014].[Sales].[SalesOrderHeader].[SalesOrderID] as [soh].[SalesOrderID]"><Identifier><ColumnReference Database="[AdventureWorks2014]" Schema="[Sales]" Table="[SalesOrderHeader]" Alias="[soh]" Column="SalesOrderID"></ColumnReference></Identifier></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp></NestedLoops></RelOp><ParameterList><ColumnReference Column="@1" ParameterDataType="smallint" ParameterCompiledValue="(285)" ParameterRuntimeValue="(285)"></ColumnReference></ParameterList></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>'''

*/





--Chapter 10
--Listing 10.1
--psuedo code, in book only

--Listing 10.2
SELECT p.Suffix,
       COUNT(*) AS SuffixUsageCount
FROM Person.Person AS p
GROUP BY p.Suffix;

--Listing 10.3
SELECT p.Suffix,
       COUNT(p.Suffix) AS SuffixUsageCount
FROM Person.Person AS p
GROUP BY p.Suffix
OPTION (ORDER GROUP);

--Listing 10.4
SELECT pm1.Name,
       pm1.ModifiedDate
FROM Production.ProductModel AS pm1
UNION
SELECT p.Name,
       p.ModifiedDate
FROM Production.Product AS p;

--Listing 10.5
SELECT pm1.Name,
       pm1.ModifiedDate
FROM Production.ProductModel AS pm1
UNION
SELECT p.Name,
       p.ModifiedDate
FROM Production.Product AS p
OPTION (MERGE UNION);

--Listing 10.6
SELECT pm1.Name,
       pm1.ModifiedDate
FROM Production.ProductModel AS pm1
UNION
SELECT p.Name,
       p.ModifiedDate
FROM Production.Product AS p
OPTION (HASH UNION);

--Listing 10.7
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
    LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;
GO 50

--Listing 10.8
--Book only I/O output from above query

--Listing 10.9
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
    LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name
OPTION (LOOP JOIN);
GO 50

--Listing 10.10
--Book only I/O output of above query


--Listing 10.11
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
    LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name
OPTION (MERGE JOIN);


--Listing 10.12
--Book only I/O output fo above query



--Listing 10.13
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON p.ProductModelID = pmi.ProductModelID
    LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name
OPTION (HASH JOIN);

--Listing 10.14
--Book only, I/O output of above query

--Listing 10.15
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.DueDate,
       sod.CarrierTrackingNumber,
       sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
ORDER BY soh.DueDate DESC;

--Listing 10.16
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.DueDate,
       sod.CarrierTrackingNumber,
       sod.OrderQty
FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh
        ON sod.SalesOrderID = soh.SalesOrderID
ORDER BY soh.DueDate DESC
OPTION (FAST 10);


--Listing 10.17
SELECT pc.Name AS ProductCategoryName,
       ps.Name AS ProductSubCategoryName,
       p.Name AS ProductName,
       pdr.Description,
       pm.Name AS ProductModelName,
       c.Name AS CultureName,
       d.FileName,
       pri.Quantity,
       pr.Rating,
       pr.Comments
FROM Production.Product AS p
    LEFT JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
    LEFT JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductInventory AS pri
        ON p.ProductID = pri.ProductID
    LEFT JOIN Production.ProductReview AS pr
        ON p.ProductID = pr.ProductID
    LEFT JOIN Production.ProductDocument AS pd
        ON p.ProductID = pd.ProductID
    LEFT JOIN Production.Document AS d
        ON pd.DocumentNode = d.DocumentNode
    LEFT JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    LEFT JOIN Production.ProductModelProductDescriptionCulture AS pmpdc
        ON pm.ProductModelID = pmpdc.ProductModelID
    LEFT JOIN Production.ProductDescription AS pdr
        ON pmpdc.ProductDescriptionID = pdr.ProductDescriptionID
    LEFT JOIN Production.Culture AS c
        ON c.CultureID = pmpdc.CultureID;
GO 50

--Listing 10.18
SELECT pc.Name AS ProductCategoryName,
       ps.Name AS ProductSubCategoryName,
       p.Name AS ProductName,
       pdr.Description,
       pm.Name AS ProductModelName,
       c.Name AS CultureName,
       d.FileName,
       pri.Quantity,
       pr.Rating,
       pr.Comments
FROM Production.Product AS p
    LEFT JOIN Production.ProductModel AS pm
        ON p.ProductModelID = pm.ProductModelID
    LEFT JOIN Production.ProductSubcategory AS ps
        ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductInventory AS pri
        ON p.ProductID = pri.ProductID
    LEFT JOIN Production.ProductReview AS pr
        ON p.ProductID = pr.ProductID
    LEFT JOIN Production.ProductDocument AS pd
        ON p.ProductID = pd.ProductID
    LEFT JOIN Production.Document AS d
        ON pd.DocumentNode = d.DocumentNode
    LEFT JOIN Production.ProductCategory AS pc
        ON ps.ProductCategoryID = pc.ProductCategoryID
    LEFT JOIN Production.ProductModelProductDescriptionCulture AS pmpdc
        ON pm.ProductModelID = pmpdc.ProductModelID
    LEFT JOIN Production.ProductDescription AS pdr
        ON pmpdc.ProductDescriptionID = pdr.ProductDescriptionID
    LEFT JOIN Production.Culture AS c
        ON c.CultureID = pmpdc.CultureID
OPTION (FORCE ORDER);
GO 50





--Listing 10.19
--enable advanced options
EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
--change the cost threshold to 1
EXEC sp_configure 'cost threshold for parallelism', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
--Execute the query which will go parallel
SELECT wo.DueDate,
       MIN(wo.OrderQty) AS MinOrderQty,
       MIN(wo.StockedQty) AS MinStockedQty,
       MIN(wo.ScrappedQty) AS MinScrappedQty,
       MAX(wo.OrderQty) AS MaxOrderQty,
       MAX(wo.StockedQty) AS MaxStockedQty,
       MAX(wo.ScrappedQty) AS MaxScrappedQty
FROM Production.WorkOrder AS wo
GROUP BY wo.DueDate
ORDER BY wo.DueDate;
GO
--reset the cost threshold to the default value
--if your cost threshold is set to a different value, change the 5
EXEC sys.sp_configure 'cost threshold for parallelism', 5;
GO
RECONFIGURE WITH OVERRIDE;
GO
--disable advanced options
EXEC sys.sp_configure 'show advanced options', 0
GO
RECONFIGURE WITH OVERRIDE
GO



--Listing 10.20
SELECT wo.DueDate,
       MIN(wo.OrderQty) AS MinOrderQty,
       MIN(wo.StockedQty) AS MinStockedQty,
       MIN(wo.ScrappedQty) AS MinScrappedQty,
       MAX(wo.OrderQty) AS MaxOrderQty,
       MAX(wo.StockedQty) AS MaxStockedQty,
       MAX(wo.ScrappedQty) AS MaxScrappedQty
FROM Production.WorkOrder AS wo
GROUP BY wo.DueDate
ORDER BY wo.DueDate
OPTION (MAXDOP 1);




--Listing 10.21
SELECT  AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceID,
        PostalCode,
        SpatialLocation,
        rowguid,
        ModifiedDate
FROM    Person.Address
WHERE   City = 'Mentor';

SELECT  AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceID,
        PostalCode,
        SpatialLocation,
        rowguid,
        ModifiedDate
FROM    Person.Address
WHERE   City = 'London';


--Listing 10.22
DECLARE @City NVARCHAR(30) 

SET @City = N'Mentor'
SELECT  AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceID,
        PostalCode,
        SpatialLocation,
        rowguid,
        ModifiedDate
FROM    Person.Address
WHERE   City = @City;

SET @City = N'London'
SELECT  AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceID,
        PostalCode,
        SpatialLocation,
        rowguid,
        ModifiedDate
FROM    Person.Address
WHERE   City = @City;

GO
--Listin 10.23
CREATE OR ALTER PROCEDURE dbo.AddressByCity @City NVARCHAR(30)
AS
SELECT  AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvinceID,
        PostalCode,
        SpatialLocation,
        rowguid,
        ModifiedDate
FROM    Person.Address
WHERE   City = @City
OPTION (OPTIMIZE FOR UNKNOWN);
GO

EXEC dbo.AddressByCity @City = N'Mentor';


go
--Listing 10.24
CREATE OR ALTER PROCEDURE dbo.AddressDetails (
    @City NVARCHAR(30),
    @PostalCode NVARCHAR(15),
    @AddressLine2 NVARCHAR(60) NULL)
AS
SELECT a.AddressLine1,
       a.AddressLine2,
       a.SpatialLocation
FROM Person.Address AS a
WHERE a.City = @City
      AND a.PostalCode = @City
      AND (   a.AddressLine2 = @AddressLine2
              OR @AddressLine2 IS NULL)
OPTION (OPTIMIZE FOR (@City = 'London', @PostalCode = 'W1Y 3RA'));
GO


--Listing 10.25
DECLARE @PersonId INT = 277;
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @PersonId;

SET @PersonId = 288;
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @PersonId;



SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = 279;
GO
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = 280;
GO




DECLARE @IDValue INT;
DECLARE @MaxID INT = 280;
DECLARE @PreparedStatement INT;

SELECT @IDValue = 279;
EXEC sp_prepare @PreparedStatement OUTPUT,
                N'@SalesPersonID INT',
                N'SELECT  soh.SalesPersonID, soh.SalesOrderNumber,
        soh.OrderDate,
        soh.SubTotal,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID =  @SalesPersonID';

WHILE @IDValue <= @MaxID
BEGIN
    EXEC sp_execute @PreparedStatement, @IDValue;

    SELECT @IDValue = @IDValue + 1;
END;
EXEC sp_unprepare @PreparedStatement;

GO


DECLARE @IDValue INT;
DECLARE @MaxID INT = 280;
DECLARE @PreparedStatement INT;

SELECT @IDValue = 280;
EXEC sp_prepare @PreparedStatement OUTPUT,
                N'@SalesPersonID INT = 280',
                N'SELECT  soh.SalesPersonID, soh.SalesOrderNumber,
        soh.OrderDate,
        soh.SubTotal,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID =  @SalesPersonID';

WHILE @IDValue <= @MaxID
BEGIN
    EXEC sp_execute @PreparedStatement, @IDValue;

    SELECT @IDValue = @IDValue + 1;
END;
EXEC sp_unprepare @PreparedStatement;

GO






DECLARE @IDValue INT;
DECLARE @MaxID INT = 280;
DECLARE @PreparedStatement INT;

SELECT @IDValue = 279;
EXEC sp_prepare @PreparedStatement OUTPUT,
                N'@SalesPersonID INT',
                N'SELECT  soh.SalesPersonID, soh.SalesOrderNumber,
        soh.OrderDate,
        soh.SubTotal,
        soh.TotalDue
FROM    Sales.SalesOrderHeader soh
WHERE   soh.SalesPersonID =  @SalesPersonID
OPTION (RECOMPILE)';

WHILE @IDValue <= @MaxID
BEGIN
    EXEC sp_execute @PreparedStatement, @IDValue;

    SELECT @IDValue = @IDValue + 1;
END;
EXEC sp_unprepare @PreparedStatement;






--listing 10.26
DECLARE @PersonId INT = 277;
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @PersonId
OPTION (RECOMPILE);

SET @PersonId = 288;
SELECT soh.SalesOrderNumber,
       soh.OrderDate,
       soh.SubTotal,
       soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
WHERE soh.SalesPersonID = @PersonId
OPTION (RECOMPILE);



--Listing 10.27
SELECT vspcr.StateProvinceCode,
       vspcr.StateProvinceName,
       vspcr.CountryRegionName
FROM Person.vStateProvinceCountryRegion AS vspcr;
GO 50


SELECT vspcr.StateProvinceCode,
       vspcr.StateProvinceName,
       vspcr.CountryRegionName
FROM Person.vStateProvinceCountryRegion AS vspcr
OPTION (EXPAND VIEWS);
GO 50



--Listing 10.28
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON pm.ProductModelID = pmi.ProductModelID
    LEFT JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;
GO 50


--Listing 10.29
SELECT pm.Name,
       pm.CatalogDescription,
       p.Name AS ProductName,
       i.Diagram
FROM Production.ProductModel AS pm
    LEFT JOIN Production.Product AS p
        ON pm.ProductModelID = p.ProductModelID
    LEFT JOIN Production.ProductModelIllustration AS pmi
        ON pm.ProductModelID = pmi.ProductModelID
    LEFT HASH JOIN Production.Illustration AS i
        ON pmi.IllustrationID = i.IllustrationID
WHERE pm.Name LIKE '%Mountain%'
ORDER BY pm.Name;
GO 50



--Listing 10.30
--book only

--Listing 10.31
SELECT a.City,
       v.StateProvinceName,
       v.CountryRegionName
FROM Person.Address AS a
    JOIN Person.vStateProvinceCountryRegion AS v WITH (NOEXPAND)
        ON a.StateProvinceID = v.StateProvinceID
WHERE a.AddressID = 22701;
GO 500

SELECT a.City,
       v.StateProvinceName,
       v.CountryRegionName
FROM Person.Address AS a
    JOIN Person.vStateProvinceCountryRegion AS v 
        ON a.StateProvinceID = v.StateProvinceID
WHERE a.AddressID = 22701;
GO 500


--Listing 10.32-34
--Book only
DROP TABLE dbo.indexsample

--listing 10.35
CREATE TABLE dbo.IndexSample (ID INT NOT NULL IDENTITY(1, 1),
                              ColumnA INT,
                              ColumnB INT,
                              ColumnC INT,
                              CONSTRAINT IndexSamplePK
                                  PRIMARY KEY
                                  (
                                      ID
                                  ));

CREATE INDEX FirstIndex ON dbo.IndexSample (ColumnA);
CREATE INDEX SecondIndex ON dbo.IndexSample (ColumnB);
CREATE INDEX ThirdIndex ON dbo.IndexSample (ColumnC);

SELECT isa.ID,
       isa.ColumnA,
       isa.ColumnB,
       isa.ColumnC
FROM dbo.IndexSample AS isa WITH (INDEX(FirstIndex, SecondIndex, ThirdIndex));

DROP TABLE dbo.IndexSample;







--Listing 10.35
SELECT de.Name,
       e.JobTitle,
       p.LastName + ', ' + p.FirstName
FROM HumanResources.Department AS de
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
        ON de.DepartmentID = edh.DepartmentID
    JOIN HumanResources.Employee AS e
        ON edh.BusinessEntityID = e.BusinessEntityID
    JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
WHERE de.Name LIKE 'P%';
GO 500

--Lising 10.36
SELECT de.Name,
       e.JobTitle,
       p.LastName + ', ' + p.FirstName
FROM HumanResources.Department AS de WITH (INDEX(PK_Department_DepartmentID))
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
        ON de.DepartmentID = edh.DepartmentID
    JOIN HumanResources.Employee AS e
        ON edh.BusinessEntityID = e.BusinessEntityID
    JOIN Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
WHERE de.Name LIKE 'P%';
GO 500


--Listing 10.37
SELECT p.Name AS ComponentName,
       p2.Name AS AssemblyName,
       bom.StartDate,
       bom.EndDate
FROM Production.BillOfMaterials AS bom
    JOIN Production.Product AS p
        ON p.ProductID = bom.ComponentID
    JOIN Production.Product AS p2
        ON p2.ProductID = bom.ProductAssemblyID;
GO 500

--Listing 10.38
SELECT p.Name AS ComponentName,
       p2.Name AS AssemblyName,
       bom.StartDate,
       bom.EndDate
FROM Production.BillOfMaterials AS bom WITH (FORCESEEK)
    JOIN Production.Product AS p
        ON p.ProductID = bom.ComponentID
    JOIN Production.Product AS p2
        ON p2.ProductID = bom.ProductAssemblyID;
GO 500




--Chapter 11
--Listing 11.1
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
--show the current value
EXEC sys.sp_configure @configname = 'max degree of parallelism'

--change value
EXEC sys.sp_configure @configname = 'max degree of parallelism',
                      @configvalue = 4;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 0;
GO
RECONFIGURE WITH OVERRIDE;
GO


--Listing 11.2
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure @configname = 'cost threshold for parallelism',
                      @configvalue = 5;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 0;
GO
RECONFIGURE WITH OVERRIDE;
GO


--Listing 11.3
SELECT so.ProductID,
       COUNT(*) AS Order_Count
FROM Sales.SalesOrderDetail AS so
WHERE so.ModifiedDate >= 'March 3, 2014'
      AND so.ModifiedDate < DATEADD(mm,
                                    3,
                                    'March 1, 2014')
GROUP BY so.ProductID
ORDER BY so.ProductID;



--Listing 11.4
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure @configname = 'cost threshold for parallelism',
                      @configvalue = 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
SET STATISTICS XML ON;
SELECT so.ProductID,
       COUNT(*) AS Order_Count
FROM Sales.SalesOrderDetail AS so
WHERE so.ModifiedDate >= 'March 3, 2014'
      AND so.ModifiedDate < DATEADD(mm,
                                    3,
                                    'March 1, 2014')
GROUP BY so.ProductID
ORDER BY so.ProductID;
SET STATISTICS XML OFF;
GO
EXEC sys.sp_configure @configname = 'cost threshold for parallelism',
                      @configvalue = 50; --your value goes here
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sys.sp_configure @configname = 'show advanced options',
                      @configvalue = 0;
GO
RECONFIGURE WITH OVERRIDE;
GO
















GO
--Batch mode chapter
DROP TABLE dbo.ccTransactionHistory;
DROP INDEX TransactionHistoryCS ON dbo.bigTransactionHistory

GO

--listing 12.1
CREATE NONCLUSTERED COLUMNSTORE INDEX TransactionHistoryCS
ON dbo.bigTransactionHistory
(
    ProductID,
    TransactionDate,
    Quantity,
    ActualCost,
	TransactionID
);

--Listing 12.2
SELECT th.ProductID,
       AVG(th.ActualCost),
       MAX(th.ActualCost),
       MIN(th.ActualCost)
FROM dbo.bigTransactionHistory AS th
GROUP BY th.ProductID;


--Listing 12.3
ALTER DATABASE AdventureWorks2014 SET COMPATIBILITY_LEVEL = 120;



--Listing 12.4
SELECT th.ProductID,
       AVG(th.ActualCost),
       MAX(th.ActualCost),
       MIN(th.ActualCost)
FROM dbo.bigTransactionHistory AS th
GROUP BY th.ProductID
OPTION(QUERYTRACEON 8649);


--Listing 12.5
ALTER DATABASE AdventureWorks2014 SET COMPATIBILITY_LEVEL = 140;

--Listing 12.6
SELECT bp.Name,
       AVG(th.ActualCost),
       MAX(th.ActualCost),
       MIN(th.ActualCost)
FROM dbo.bigTransactionHistory AS th
    JOIN dbo.bigProduct AS bp
        ON bp.ProductID = th.ProductID
GROUP BY bp.Name;




GO
--Listing 12.9
CREATE OR ALTER PROCEDURE dbo.CostCheck (@Cost MONEY)
AS
SELECT p.Name,
       AVG(th.Quantity)
FROM dbo.bigTransactionHistory AS th
    JOIN dbo.bigProduct AS p
        ON p.ProductID = th.ProductID
WHERE th.ActualCost = @Cost
GROUP BY p.Name;

--Listing 12.10
EXEC dbo.CostCheck @Cost = 0;
GO
EXEC dbo.CostCheck @Cost = 462.7985;
GO

--Listing 12.11
EXEC dbo.CostCheck @Cost = 15.035;


--XML
--Chapter 13
--Listing 13.1
SELECT c.CustomerID, a.City, s.Name, st.Name
  FROM Sales.Customer AS c
    JOIN Sales.Store AS s
      ON c.StoreID = s.BusinessEntityID
    JOIN Sales.SalesTerritory AS st
      ON c.TerritoryID = st.TerritoryID
    JOIN Person.BusinessEntityAddress AS bea
      ON c.CustomerID = bea.BusinessEntityID
    JOIN Person.Address AS a
      ON bea.AddressID = a.AddressID
    JOIN Person.StateProvince AS sp
      ON a.StateProvinceID = sp.StateProvinceID
  WHERE st.Name = 'Northeast' AND sp.Name = 'New York';
GO

--Listing 13.2
SET STATISTICS XML ON;
SELECT  poh.PurchaseOrderID,
        poh.ShipDate,
        poh.ShipMethodID
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.ShipDate BETWEEN '3/1/2014' AND '3/3/2014';
GO
SET STATISTICS XML OFF;


--Listing 13.3
SELECT  poh.PurchaseOrderID,
        poh.ShipDate,
        poh.ShipMethodID
FROM    Purchasing.PurchaseOrderHeader AS poh
WHERE   poh.ShipDate BETWEEN '3/1/2014' AND '3/3/2014';
GO

--Listing 13.4
WITH Top1Query
AS (SELECT TOP 1
           dest.text,
           deqp.query_plan
    FROM sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
        CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    ORDER BY deqs.execution_count DESC)
SELECT TOP 3
       tq.text,
       op.value('@PhysicalOp', 'varchar(50)') AS PhysicalOp,
       RelOp.op.value('@EstimateCPU', 'float') + RelOp.op.value('@EstimateIO', 'float') AS EstimatedCost
FROM Top1Query AS tq
    CROSS APPLY tq.query_plan.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
    //RelOp') RelOp(op)
ORDER BY EstimatedCost DESC;


--Listing 13.5
WITH XMLNAMESPACES
(
    DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT deqp.query_plan.value(N'(//MissingIndex/@Database)[1]', 'NVARCHAR(256)')
           AS DatabaseName,
       dest.text AS QueryText,
       deqs.total_elapsed_time,
       deqs.last_execution_time,
       deqs.execution_count,
       deqs.total_logical_writes,
       deqs.total_logical_reads,
       deqs.min_elapsed_time,
       deqs.max_elapsed_time,
       deqp.query_plan,
       deqp.query_plan.value(N'(//MissingIndex/@Table)[1]', 'NVARCHAR(256)')
           AS TableName,
       deqp.query_plan.value(N'(//MissingIndex/@Schema)[1]', 'NVARCHAR(256)')
           AS SchemaName,
       deqp.query_plan.value(N'(//MissingIndexGroup/@Impact)[1]', 'DECIMAL(6,4)')
           AS ProjectedImpact,
       ColumnGroup.value('./@Usage', 'NVARCHAR(256)') AS ColumnGroupUsage,
       ColumnGroupColumn.value('./@Name', 'NVARCHAR(256)') AS ColumnName
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
    CROSS APPLY deqp.query_plan.nodes('//MissingIndexes/MissingIndexGroup/MissingIndex/ColumnGroup') AS t1(ColumnGroup)
    CROSS APPLY t1.ColumnGroup.nodes('./Column') AS t2(ColumnGroupColumn);


--Listing 13.6





--special data types and cursors
--Chapter 14
--Listing 14.1
SELECT s.Name AS StoreName,
       bec.PersonID,
       bec.ContactTypeID
FROM Sales.Store AS s
    JOIN Person.BusinessEntityContact AS bec
        ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY s.Name;


--Listing 14.2
SELECT s.Name AS StoreName,
       bec.PersonID,
       bec.ContactTypeID
FROM Sales.Store AS s
    INNER JOIN Person.BusinessEntityContact AS bec
        ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY s.Name
FOR XML AUTO;


--Listing 14.3
SELECT s.Name AS StoreName,
       (   SELECT bec.BusinessEntityID,
                  bec.ContactTypeID
           FROM Person.BusinessEntityContact AS bec
           WHERE bec.BusinessEntityID = s.BusinessEntityID
           FOR XML AUTO, TYPE, ELEMENTS)
FROM Sales.Store AS s
ORDER BY s.Name
FOR XML AUTO;

GO

--Listing 14.4
SELECT 1 AS Tag,
       NULL AS Parent,
       s.Name AS [Store!1!StoreName],
       NULL AS [BECContact!2!PersonID],
       NULL AS [BECContact!2!ContactTypeID]
FROM Sales.Store AS s
    JOIN Person.BusinessEntityContact AS bec
        ON s.BusinessEntityID = bec.BusinessEntityID
UNION ALL
SELECT 2 AS Tag,
       1 AS Parent,
       s.Name AS StoreName,
       bec.PersonID,
       bec.ContactTypeID
FROM Sales.Store AS s
    JOIN Person.BusinessEntityContact AS bec
        ON s.BusinessEntityID = bec.BusinessEntityID
ORDER BY [Store!1!StoreName],
         [BECContact!2!PersonID]
FOR XML EXPLICIT;

go
--Listing 14.5
/*<ROOT>
  <Currency CurrencyCode="UTE" 
CurrencyName="Universal Transactional Exchange">
    <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
                   CurrencyRateDate="2007/1/1" AverageRate=".553"
                   EndOfDateRate= ".558" />
    <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
                   CurrencyRateDate="2007/6/1" AverageRate=".928"
                   EndOfDateRate= "1.057" />
  </Currency>
</ROOT>
*/

--Listing 14.6
BEGIN TRAN;
DECLARE @iDoc AS INTEGER;
DECLARE @Xml AS NVARCHAR(MAX);

SET @Xml = '<ROOT>
<Currency CurrencyCode="UTE" CurrencyName="Universal
  Transactional Exchange">
   <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
     CurrencyRateDate="2007/1/1" AverageRate=".553"
     EndOfDayRate= ".558" />
   <CurrencyRate FromCurrencyCode="USD" ToCurrencyCode="UTE"
     CurrencyRateDate="2007/6/1" AverageRate=".928"
     EndOfDayRate= "1.057" />
</Currency>
</ROOT>';

EXEC sys.sp_xml_preparedocument
    @iDoc OUTPUT,
    @Xml;

INSERT  INTO Sales.Currency
        (CurrencyCode,
         Name,
         ModifiedDate
        )
SELECT  CurrencyCode,
        CurrencyName,
        GETDATE()
FROM    OPENXML (@iDoc, 'ROOT/Currency',1)
           WITH (CurrencyCode NCHAR(3), CurrencyName NVARCHAR(50));

INSERT  INTO Sales.CurrencyRate
        (CurrencyRateDate,
         FromCurrencyCode,
         ToCurrencyCode,
         AverageRate,
         EndOfDayRate,
         ModifiedDate
        )
SELECT  CurrencyRateDate,
        FromCurrencyCode,
        ToCurrencyCode,
        AverageRate,
        EndOfDayRate,
        GETDATE()
FROM    OPENXML(@iDoc , 'ROOT/Currency/CurrencyRate',2)
          WITH (CurrencyRateDate DATETIME '@CurrencyRateDate',
                 FromCurrencyCode NCHAR(3) '@FromCurrencyCode',
                 ToCurrencyCode NCHAR(3) '@ToCurrencyCode', 
                 AverageRate MONEY '@AverageRate', 
                 EndOfDayRate MONEY '@EndOfDayRate');

EXEC sys.sp_xml_removedocument
    @iDoc;
ROLLBACK TRAN;


--Listing 14.7
SELECT p.LastName,
       p.FirstName,
       e.HireDate,
       e.JobTitle
FROM Person.Person AS p
    INNER JOIN HumanResources.Employee AS e
        ON p.BusinessEntityID = e.BusinessEntityID
    INNER JOIN HumanResources.JobCandidate AS jc
        ON e.BusinessEntityID = jc.BusinessEntityID
           AND jc.Resume.exist(
                   ' declare namespace
        res="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";
        /res:Resume/res:Employment/res:Emp.JobTitle[contains
             (.,"Sales Manager")]') = 1;


--Listing 14.8
SELECT s.Name,
       s.Demographics.query(
           '
   declare namespace ss="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";
   for $s in /ss:StoreSurvey
   where ss:StoreSurvey/ss:SquareFeet > 20000
   return $s
')     AS Demographics
FROM Sales.Store AS s
WHERE s.SalesPersonID = 279;


--Listing 14.9
DROP TABLE IF EXISTS dbo.PersonJson;

SELECT p.BusinessEntityID,
       p.Title,
       p.FirstName,
       p.LastName,
       (   SELECT p2.FirstName AS "person.name",
                  p2.LastName AS "person.surname",
                  p2.Title,
                  p2.BusinessEntityID
           FROM Person.Person AS p2
           WHERE p.BusinessEntityID = p2.BusinessEntityID
           FOR JSON PATH) AS JsonData
INTO dbo.PersonJson
FROM Person.Person AS p;


--Listing 14.10
SELECT oj.FirstName,
       oj.LastName,
       oj.Title
FROM dbo.PersonJson AS pj
    CROSS APPLY
    OPENJSON(pj.JsonData,
             N'$')
    WITH (FirstName VARCHAR(50) N'$.person.name',
          LastName VARCHAR(50) N'$.person.surname',
          Title VARCHAR(8) N'$.Title',
          BusinessEntityID INT N'$.BusinessEntityID') AS oj
WHERE oj.BusinessEntityID = 42;


--Listing 14.11
DECLARE @ManagerID HIERARCHYID

SELECT @ManagerID = e.OrganizationNode
FROM HumanResources.Employee AS e
WHERE e.JobTitle = 'Vice President of Engineering'

SELECT  e.BusinessEntityID,
        p.LastName
FROM    HumanResources.Employee AS e
JOIN    Person.Person AS p
        ON e.BusinessEntityID = p.BusinessEntityID
WHERE   e.OrganizationNode.IsDescendantOf(@ManagerID) = 1;

--Listing 14.12
DECLARE @MyLocation GEOGRAPHY = geography::STPointFromText('POINT(-122.33383 47.610870)',
                                                           4326);

SELECT a.AddressLine1,
       a.City,
       a.PostalCode,
       a.SpatialLocation
FROM Person.Address AS a
WHERE @MyLocation.STDistance(a.SpatialLocation) < 1000;

--Listing 14.13
CREATE SPATIAL INDEX TestSpatial
ON Person.Address (SpatialLocation)
USING GEOGRAPHY_GRID
WITH (GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM),
      CELLS_PER_OBJECT = 16,
      PAD_INDEX = OFF,
      SORT_IN_TEMPDB = OFF,
      DROP_EXISTING = OFF,
      ALLOW_ROW_LOCKS = ON,
      ALLOW_PAGE_LOCKS = ON)
ON [PRIMARY];

--Listing 14.14
DROP INDEX TestSpatial ON Person.Address;


--Listing 14.15
DECLARE CurrencyList CURSOR STATIC 
FOR
SELECT c.CurrencyCode,
       cr.Name
FROM Sales.Currency AS c
    JOIN Sales.CountryRegionCurrency AS crc
        ON crc.CurrencyCode = c.CurrencyCode
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = crc.CountryRegionCode
WHERE c.Name LIKE '%Dollar%';

OPEN CurrencyList;

FETCH NEXT FROM CurrencyList;

WHILE @@FETCH_STATUS = 0
    BEGIN

 -- Normally there would be operations here using data from cursor

        FETCH NEXT FROM CurrencyList;
    END 

CLOSE CurrencyList;
DEALLOCATE CurrencyList;
GO


--Listing 14.16
DECLARE CurrencyList CURSOR KEYSET 
FOR
SELECT c.CurrencyCode,
       cr.Name
FROM Sales.Currency AS c
    JOIN Sales.CountryRegionCurrency AS crc
        ON crc.CurrencyCode = c.CurrencyCode
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = crc.CountryRegionCode
WHERE c.Name LIKE '%Dollar%';

OPEN CurrencyList;

FETCH NEXT FROM CurrencyList;

WHILE @@FETCH_STATUS = 0
    BEGIN

 -- Normally there would be operations here using data from cursor

        FETCH NEXT FROM CurrencyList;
    END 

CLOSE CurrencyList;
DEALLOCATE CurrencyList;
GO

--Listing 14.17
DECLARE CurrencyList CURSOR DYNAMIC 
FOR
SELECT c.CurrencyCode,
       cr.Name
FROM Sales.Currency AS c
    JOIN Sales.CountryRegionCurrency AS crc
        ON crc.CurrencyCode = c.CurrencyCode
    JOIN Person.CountryRegion AS cr
        ON cr.CountryRegionCode = crc.CountryRegionCode
WHERE c.Name LIKE '%Dollar%';

OPEN CurrencyList;

FETCH NEXT FROM CurrencyList;

WHILE @@FETCH_STATUS = 0
    BEGIN

 -- Normally there would be operations here using data from cursor

        FETCH NEXT FROM CurrencyList;
    END 

CLOSE CurrencyList;
DEALLOCATE CurrencyList;
GO


--Automating plan capture
--Chapter 15
--Listing 15.1
CREATE EVENT SESSION ExecutionPlansOnAdventureWorks2014
ON SERVER
    ADD EVENT sqlserver.query_post_compilation_showplan
    (WHERE (   sqlserver.database_name = N'AdventureWorks2014'
               AND sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%Person.Person%'))),
    ADD EVENT sqlserver.query_post_execution_showplan
    (WHERE (   sqlserver.database_name = N'AdventureWorks2014'
               AND sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%Person.Person%'))),
    ADD EVENT sqlserver.query_pre_execution_showplan
    (WHERE (   sqlserver.database_name = N'AdventureWorks2014'
               AND sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%Person.Person%'))),
    ADD EVENT sqlserver.sql_batch_completed
    (WHERE (   sqlserver.database_name = N'AdventureWorks2014'
               AND sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%Person.Person%')))
    ADD TARGET package0.event_file
    (SET filename = N'C:\PerfData\ExecutionPlansOnAdventureWorks2014.xel')
WITH (MAX_MEMORY = 4096KB,
      EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
      MAX_DISPATCH_LATENCY = 30 SECONDS,
      MAX_EVENT_SIZE = 0KB,
      MEMORY_PARTITION_MODE = NONE,
      TRACK_CAUSALITY = ON,
      STARTUP_STATE = OFF)
GO


--Listing 15.2
USE AdventureWorks2014;
GO
DECLARE @PlanHandle VARBINARY(64);

SELECT  @PlanHandle = deqs.plan_handle
FROM    sys.dm_exec_query_stats AS deqs
        CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE   dest.text LIKE '%Person.Person%';

IF @PlanHandle IS NOT NULL
    BEGIN
        DBCC FREEPROCCACHE(@PlanHandle);
    END;
GO

SELECT  p.LastName + ', ' + p.FirstName ,
        p.Title ,
        pp.PhoneNumber
FROM    Person.Person AS p
        JOIN Person.PersonPhone AS pp
        ON pp.BusinessEntityID = p.BusinessEntityID
        JOIN Person.PhoneNumberType AS pnt
        ON pnt.PhoneNumberTypeID = pp.PhoneNumberTypeID
WHERE   pnt.Name = 'Cell'
        AND p.LastName = 'Dempsey';
GO



--Listing 15.3
CREATE EVENT SESSION ExecPlansAndWaits
ON SERVER
    ADD EVENT sqlos.wait_completed
    (WHERE (   (sqlserver.database_name = N'AdventureWorks2014')
               AND (sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%ProductTransferByReference%')))),
    ADD EVENT sqlserver.query_post_execution_showplan
    (WHERE (   (sqlserver.database_name = N'AdventureWorks2014')
               AND (sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%ProductTransferByReference%')))),
    ADD EVENT sqlserver.rpc_completed
    (WHERE (   (sqlserver.database_name = N'AdventureWorks2014')
               AND (sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%ProductTransferByReference%')))),
    ADD EVENT sqlserver.rpc_starting
    (WHERE (   (sqlserver.database_name = N'AdventureWorks2014')
               AND (sqlserver.like_i_sql_unicode_string(sqlserver.sql_text, N'%ProductTransferByReference%'))))
    ADD TARGET package0.event_file
    (SET filename = N'C:\PerfData\ExecPlansAndWaits.xel')
WITH (TRACK_CAUSALITY = ON)
GO


--Listing 15.4
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

EXEC @rc = sp_trace_create @TraceID OUTPUT,
                           0,
                           N'InsertFileNameHere',
                           @maxfilesize,
                           NULL;
IF (@rc != 0)
    GOTO error;

-- Client side File and Table cannot be scripted

-- Set the events
DECLARE @on BIT;
SET @on = 1;
EXEC sp_trace_setevent @TraceID, 122, 1, @on;
EXEC sp_trace_setevent @TraceID, 122, 9, @on;
EXEC sp_trace_setevent @TraceID, 122, 2, @on;
EXEC sp_trace_setevent @TraceID, 122, 66, @on;
EXEC sp_trace_setevent @TraceID, 122, 10, @on;
EXEC sp_trace_setevent @TraceID, 122, 3, @on;
EXEC sp_trace_setevent @TraceID, 122, 4, @on;
EXEC sp_trace_setevent @TraceID, 122, 5, @on;
EXEC sp_trace_setevent @TraceID, 122, 7, @on;
EXEC sp_trace_setevent @TraceID, 122, 8, @on;
EXEC sp_trace_setevent @TraceID, 122, 11, @on;
EXEC sp_trace_setevent @TraceID, 122, 12, @on;
EXEC sp_trace_setevent @TraceID, 122, 14, @on;
EXEC sp_trace_setevent @TraceID, 122, 22, @on;
EXEC sp_trace_setevent @TraceID, 122, 25, @on;
EXEC sp_trace_setevent @TraceID, 122, 26, @on;
EXEC sp_trace_setevent @TraceID, 122, 28, @on;
EXEC sp_trace_setevent @TraceID, 122, 29, @on;
EXEC sp_trace_setevent @TraceID, 122, 34, @on;
EXEC sp_trace_setevent @TraceID, 122, 35, @on;
EXEC sp_trace_setevent @TraceID, 122, 41, @on;
EXEC sp_trace_setevent @TraceID, 122, 49, @on;
EXEC sp_trace_setevent @TraceID, 122, 50, @on;
EXEC sp_trace_setevent @TraceID, 122, 51, @on;
EXEC sp_trace_setevent @TraceID, 122, 60, @on;
EXEC sp_trace_setevent @TraceID, 122, 64, @on;
EXEC sp_trace_setevent @TraceID, 10, 1, @on;
EXEC sp_trace_setevent @TraceID, 10, 9, @on;
EXEC sp_trace_setevent @TraceID, 10, 2, @on;
EXEC sp_trace_setevent @TraceID, 10, 66, @on;
EXEC sp_trace_setevent @TraceID, 10, 10, @on;
EXEC sp_trace_setevent @TraceID, 10, 3, @on;
EXEC sp_trace_setevent @TraceID, 10, 4, @on;
EXEC sp_trace_setevent @TraceID, 10, 6, @on;
EXEC sp_trace_setevent @TraceID, 10, 7, @on;
EXEC sp_trace_setevent @TraceID, 10, 8, @on;
EXEC sp_trace_setevent @TraceID, 10, 11, @on;
EXEC sp_trace_setevent @TraceID, 10, 12, @on;
EXEC sp_trace_setevent @TraceID, 10, 13, @on;
EXEC sp_trace_setevent @TraceID, 10, 14, @on;
EXEC sp_trace_setevent @TraceID, 10, 15, @on;
EXEC sp_trace_setevent @TraceID, 10, 16, @on;
EXEC sp_trace_setevent @TraceID, 10, 17, @on;
EXEC sp_trace_setevent @TraceID, 10, 18, @on;
EXEC sp_trace_setevent @TraceID, 10, 25, @on;
EXEC sp_trace_setevent @TraceID, 10, 26, @on;
EXEC sp_trace_setevent @TraceID, 10, 31, @on;
EXEC sp_trace_setevent @TraceID, 10, 34, @on;
EXEC sp_trace_setevent @TraceID, 10, 35, @on;
EXEC sp_trace_setevent @TraceID, 10, 41, @on;
EXEC sp_trace_setevent @TraceID, 10, 48, @on;
EXEC sp_trace_setevent @TraceID, 10, 49, @on;
EXEC sp_trace_setevent @TraceID, 10, 50, @on;
EXEC sp_trace_setevent @TraceID, 10, 51, @on;
EXEC sp_trace_setevent @TraceID, 10, 60, @on;
EXEC sp_trace_setevent @TraceID, 10, 64, @on;
EXEC sp_trace_setevent @TraceID, 12, 1, @on;
EXEC sp_trace_setevent @TraceID, 12, 9, @on;
EXEC sp_trace_setevent @TraceID, 12, 3, @on;
EXEC sp_trace_setevent @TraceID, 12, 11, @on;
EXEC sp_trace_setevent @TraceID, 12, 4, @on;
EXEC sp_trace_setevent @TraceID, 12, 6, @on;
EXEC sp_trace_setevent @TraceID, 12, 7, @on;
EXEC sp_trace_setevent @TraceID, 12, 8, @on;
EXEC sp_trace_setevent @TraceID, 12, 10, @on;
EXEC sp_trace_setevent @TraceID, 12, 12, @on;
EXEC sp_trace_setevent @TraceID, 12, 13, @on;
EXEC sp_trace_setevent @TraceID, 12, 14, @on;
EXEC sp_trace_setevent @TraceID, 12, 15, @on;
EXEC sp_trace_setevent @TraceID, 12, 16, @on;
EXEC sp_trace_setevent @TraceID, 12, 17, @on;
EXEC sp_trace_setevent @TraceID, 12, 18, @on;
EXEC sp_trace_setevent @TraceID, 12, 26, @on;
EXEC sp_trace_setevent @TraceID, 12, 31, @on;
EXEC sp_trace_setevent @TraceID, 12, 35, @on;
EXEC sp_trace_setevent @TraceID, 12, 41, @on;
EXEC sp_trace_setevent @TraceID, 12, 48, @on;
EXEC sp_trace_setevent @TraceID, 12, 49, @on;
EXEC sp_trace_setevent @TraceID, 12, 50, @on;
EXEC sp_trace_setevent @TraceID, 12, 51, @on;
EXEC sp_trace_setevent @TraceID, 12, 60, @on;
EXEC sp_trace_setevent @TraceID, 12, 64, @on;
EXEC sp_trace_setevent @TraceID, 12, 66, @on;


-- Set the Filters
DECLARE @intfilter INT;
DECLARE @bigintfilter BIGINT;

-- Set the trace status to start
EXEC sp_trace_setstatus @TraceID, 1;

-- display trace id for future references
SELECT @TraceID AS TraceID;
GOTO finish;

error:
SELECT @rc AS ErrorCode;

finish:
GO




--Query Store chapter. Insert into approprate spot
--Listing 16.1
ALTER DATABASE AdventureWorks2014 SET QUERY_STORE (MAX_PLANS_PER_QUERY = 20);

--Listing 16.2
ALTER DATABASE AdventureWorks2014 SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL);

--Listing 16.3
SELECT qsq.query_id,
       qsqt.query_sql_text,
       CAST(qsp.query_plan AS XML),
	   qcs.set_options
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
	JOIN sys.query_context_settings AS qcs
		ON qcs.context_settings_id = qsq.context_settings_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');

--Listing 16.4
--in the book, text from the preceding query
GO
--Listing 16.5
CREATE OR ALTER PROC dbo.AddressByCity @City NVARCHAR(30)
AS
SELECT a.AddressID,
       a.AddressLine1,
       a.AddressLine2,
       a.City,
       sp.Name AS StateProvinceName,
       a.PostalCode
FROM Person.Address AS a
    JOIN Person.StateProvince AS sp
        ON a.StateProvinceID = sp.StateProvinceID
WHERE a.City = @City;
GO



--Listing 16.6
SELECT bom.BillOfMaterialsID,
       bom.StartDate,
       bom.EndDate
FROM Production.BillOfMaterials AS bom
WHERE bom.BillOfMaterialsID = 2363;

--Listing 16.7
SELECT qsqt.query_text_id
FROM sys.query_store_query_text AS qsqt
WHERE qsqt.query_sql_text = 'SELECT bom.BillOfMaterialsID,
       bom.StartDate,
       bom.EndDate
FROM Production.BillOfMaterials AS bom
WHERE bom.BillOfMaterialsID = 2363;';

--Listing 16.8
SELECT qsqt.query_text_id
FROM sys.query_store_query_text AS qsqt
    JOIN sys.query_store_query AS qsq
        ON qsq.query_text_id = qsqt.query_text_id
    CROSS APPLY sys.fn_stmt_sql_handle_from_sql_stmt(
                    'SELECT bom.BillOfMaterialsID,
       bom.StartDate,
       bom.EndDate
FROM Production.BillOfMaterials AS bom
WHERE bom.BillOfMaterialsID = 2363;',
                    qsq.query_parameterization_type) AS fsshfss
WHERE fsshfss.statement_sql_handle = qsqt.statement_sql_handle;


--Listing 16.9
EXEC dbo.AddressByCity @City = N'London';



--Listing 16.10
DECLARE @PlanHandle VARBINARY(64);

SELECT @PlanHandle = deqs.plan_handle
FROM sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.objectid = OBJECT_ID('dbo.AddressByCity');

IF @PlanHandle IS NOT NULL
BEGIN;
    DBCC FREEPROCCACHE(@PlanHandle);
END;
GO

--Listing 16.11
EXEC dbo.AddressByCity @City = N'Mentor';

--Listing 16.12
SELECT qsq.query_id,
       qsp.plan_id,
       CAST(qsp.query_plan AS XML)
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsq.object_id = OBJECT_ID('dbo.AddressByCity');

--Listing 16.13
EXEC sys.sp_query_store_force_plan 214, 248;

--Listing 16.14
SELECT qsq.query_id,
       qsp.plan_id,
       CAST(qsp.query_plan AS XML)
FROM sys.query_store_query AS qsq
    JOIN sys.query_store_plan AS qsp
        ON qsp.query_id = qsq.query_id
WHERE qsp.is_forced_plan = 1;

--Listing 16.15
EXEC sys.sp_query_store_unforce_plan 214, 248;

GO
--Listing 16.16
--ALTER DATABASE CURRENT SET AUTOMATIC_TUNING(FORCE_LAST_GOOD_PLAN = ON);




--Listing 16.17
SELECT ddtr.reason,
       ddtr.score,
       pfd.query_id,
       JSON_VALUE(ddtr.state,
                  '$.currentValue') AS CurrentState
FROM sys.dm_db_tuning_recommendations AS ddtr
    CROSS APPLY
    OPENJSON(ddtr.details,
             '$.planForceDetails')
    WITH (query_id INT '$.queryId') AS pfd;


--Listing 16.18
WITH DbTuneRec
AS (SELECT ddtr.reason,
           ddtr.score,
           pfd.query_id,
           pfd.regressedPlanId,
           pfd.recommendedPlanId,
           JSON_VALUE(ddtr.state,
                      '$.currentValue') AS CurrentState,
           JSON_VALUE(ddtr.state,
                      '$.reason') AS CurrentStateReason,
           JSON_VALUE(ddtr.details,
                      '$.implementationDetails.script') AS ImplementationScript
    FROM sys.dm_db_tuning_recommendations AS ddtr
        CROSS APPLY
        OPENJSON(ddtr.details,
                 '$.planForceDetails')
        WITH (query_id INT '$.queryId',
              regressedPlanId INT '$.regressedPlanId',
              recommendedPlanId INT '$.recommendedPlanId') AS pfd)
SELECT qsq.query_id,
       dtr.reason,
       dtr.score,
       dtr.CurrentState,
       dtr.CurrentStateReason,
       qsqt.query_sql_text,
       CAST(rp.query_plan AS XML) AS RegressedPlan,
       CAST(sp.query_plan AS XML) AS SuggestedPlan
FROM DbTuneRec AS dtr
    JOIN sys.query_store_plan AS rp
        ON rp.query_id = dtr.query_id
           AND rp.plan_id = dtr.regressedPlanId
    JOIN sys.query_store_plan AS sp
        ON sp.query_id = dtr.query_id
           AND sp.plan_id = dtr.recommendedPlanId
    JOIN sys.query_store_query AS qsq
        ON qsq.query_id = rp.query_id
    JOIN sys.query_store_query_text AS qsqt
        ON qsqt.query_text_id = qsq.query_text_id;

GO
--Listing 16.19
CREATE OR ALTER PROC dbo.ProductTransactionHistoryByReference (@ReferenceOrderID INT)
AS
BEGIN
    SELECT p.Name,
           p.ProductNumber,
           th.ReferenceOrderID
    FROM Production.Product AS p
        JOIN Production.TransactionHistory AS th
            ON th.ProductID = p.ProductID
    WHERE th.ReferenceOrderID = @ReferenceOrderID;
END;




--Listing 16.20
SELECT ddtr.reason,
       ddtr.valid_since,
       ddtr.last_refresh,
       ddtr.execute_action_initiated_by
FROM sys.dm_db_tuning_recommendations AS ddtr;





EXEC dbo.AddressByCity @City = N'London' -- nvarchar(30)


ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE



-- Chapter 17
--Listing 17.1
SELECT soh.OrderDate,
       soh.Status,
       sod.CarrierTrackingNumber,
       sod.OrderQty,
       p.Name
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE sod.OrderQty * 2 > 60
      AND sod.ProductID = 867;

--Listing 17.2
SELECT soh.OrderDate,
       soh.Status,
       sod.CarrierTrackingNumber,
       sod.OrderQty,
       p.Name
FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN Production.Product AS p
        ON p.ProductID = sod.ProductID
WHERE sod.ProductID = 897;

--listing 17.3

SELECT *
FROM sys.objects AS o,
     sys.columns AS c;


--listing 17.4
DBCC TRACEON (7412, -1);

DBCC TRACEOFF(7412,-1);


--Listing 17.5
SELECT deqp.session_id,
       deqp.node_id,
       deqp.physical_operator_name,
       deqp.estimate_row_count,
       deqp.row_count
FROM sys.dm_exec_query_profiles AS deqp
WHERE deqp.session_id <> @@SPID
ORDER BY deqp.node_id ASC;



--Addendum
--Checking for optimizer behavior
DBCC FREEPROCCACHE();
GO

SELECT *
INTO OpInfoAfter
FROM sys.dm_exec_query_optimizer_info AS deqoi;
GO

DROP TABLE OpInfoAfter;
GO

--gather the existing optimizer information
SELECT *
INTO OpInfoBefore
FROM sys.dm_exec_query_optimizer_info AS deqoi;
GO

--run a query
ALTER TABLE Sales.Customer  WITH CHECK ADD  CONSTRAINT SomeTest FOREIGN KEY(CustomerID)
REFERENCES [dbo].[Agent] ([AgentId])
GO

/*CREATE TABLE dbo.MyNewTable (  MyNewTableID INT PRIMARY KEY IDENTITY(1, 1),
                               MyNewValue NVARCHAR(50)
                            );
GO*/

SELECT *
INTO OpInfoAfter
FROM sys.dm_exec_query_optimizer_info AS deqoi;
GO

--display the data that has changed
SELECT oia.counter,
       (oia.occurrence - oib.occurrence) AS ActualOccurence,
       (oia.occurrence * oia.value - oib.occurrence * oib.value) AS ActualValue
FROM OpInfoBefore AS oib
JOIN OpInfoAfter AS oia
   ON oib.counter = oia.counter
WHERE oia.occurrence <> oib.occurrence;
GO

DROP TABLE OpInfoBefore;
DROP TABLE OpInfoAfter;
GO

DROP TABLE dbo.MyNewTable
ALTER TABLE sales.Customer DROP CONSTRAINT SomeTest

TRUNCATE TABLE dbo.MyNewTable
