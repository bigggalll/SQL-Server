SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AWBuildVersion](
	[SystemInformationID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Database Version] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[VersionDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AWBuildVersion_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DatabaseLog](
	[DatabaseLogID] [int] IDENTITY(1,1) NOT NULL,
	[PostTime] [datetime] NOT NULL,
	[DatabaseUser] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Event] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Schema] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Object] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TSQL] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[XmlEvent] [xml] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ErrorLog](
	[ErrorLogID] [int] IDENTITY(1,1) NOT NULL,
	[ErrorTime] [datetime] NOT NULL,
	[UserName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorNumber] [int] NOT NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorProcedure] [nvarchar](126) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[Department](
	[DepartmentID] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[GroupName] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Department_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[Employee](
	[BusinessEntityID] [int] NOT NULL,
	[NationalIDNumber] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoginID] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel]  AS ([OrganizationNode].[GetLevel]()),
	[JobTitle] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Gender] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Employee_SalariedFlag]  DEFAULT ((1)),
	[VacationHours] [smallint] NOT NULL CONSTRAINT [DF_Employee_VacationHours]  DEFAULT ((0)),
	[SickLeaveHours] [smallint] NOT NULL CONSTRAINT [DF_Employee_SickLeaveHours]  DEFAULT ((0)),
	[CurrentFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Employee_CurrentFlag]  DEFAULT ((1)),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Employee_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Employee_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[EmployeeDepartmentHistory](
	[BusinessEntityID] [int] NOT NULL,
	[DepartmentID] [smallint] NOT NULL,
	[ShiftID] [tinyint] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmployeeDepartmentHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[EmployeePayHistory](
	[BusinessEntityID] [int] NOT NULL,
	[RateChangeDate] [datetime] NOT NULL,
	[Rate] [money] NOT NULL,
	[PayFrequency] [tinyint] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmployeePayHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[JobCandidate](
	[JobCandidateID] [int] IDENTITY(1,1) NOT NULL,
	[BusinessEntityID] [int] NULL,
	[Resume] [xml](CONTENT [HumanResources].[HRResumeSchemaCollection]) NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_JobCandidate_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [HumanResources].[Shift](
	[ShiftID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Shift_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[Address](
	[AddressID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[AddressLine1] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AddressLine2] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[City] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[PostalCode] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SpatialLocation] [geography] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Address_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Address_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[AddressType](
	[AddressTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_AddressType_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_AddressType_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[BusinessEntity](
	[BusinessEntityID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_BusinessEntity_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntity_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[BusinessEntityAddress](
	[BusinessEntityID] [int] NOT NULL,
	[AddressID] [int] NOT NULL,
	[AddressTypeID] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_BusinessEntityAddress_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntityAddress_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[BusinessEntityContact](
	[BusinessEntityID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
	[ContactTypeID] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_BusinessEntityContact_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BusinessEntityContact_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[ContactType](
	[ContactTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ContactType_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[CountryRegion](
	[CountryRegionCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CountryRegion_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[EmailAddress](
	[BusinessEntityID] [int] NOT NULL,
	[EmailAddressID] [int] IDENTITY(1,1) NOT NULL,
	[EmailAddress] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_EmailAddress_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_EmailAddress_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[Password](
	[BusinessEntityID] [int] NOT NULL,
	[PasswordHash] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PasswordSalt] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Password_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Password_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[Person](
	[BusinessEntityID] [int] NOT NULL,
	[PersonType] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NameStyle] [dbo].[NameStyle] NOT NULL CONSTRAINT [DF_Person_NameStyle]  DEFAULT ((0)),
	[Title] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[Suffix] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EmailPromotion] [int] NOT NULL CONSTRAINT [DF_Person_EmailPromotion]  DEFAULT ((0)),
	[AdditionalContactInfo] [xml](CONTENT [Person].[AdditionalContactInfoSchemaCollection]) NULL,
	[Demographics] [xml](CONTENT [Person].[IndividualSurveySchemaCollection]) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Person_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Person_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[PersonPhone](
	[BusinessEntityID] [int] NOT NULL,
	[PhoneNumber] [dbo].[Phone] NOT NULL,
	[PhoneNumberTypeID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PersonPhone_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[PhoneNumberType](
	[PhoneNumberTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PhoneNumberType_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Person].[StateProvince](
	[StateProvinceID] [int] IDENTITY(1,1) NOT NULL,
	[StateProvinceCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CountryRegionCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsOnlyStateProvinceFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_StateProvince_IsOnlyStateProvinceFlag]  DEFAULT ((1)),
	[Name] [dbo].[Name] NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_StateProvince_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_StateProvince_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[BillOfMaterials](
	[BillOfMaterialsID] [int] IDENTITY(1,1) NOT NULL,
	[ProductAssemblyID] [int] NULL,
	[ComponentID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterials_StartDate]  DEFAULT (getdate()),
	[EndDate] [datetime] NULL,
	[UnitMeasureCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BOMLevel] [smallint] NOT NULL,
	[PerAssemblyQty] [decimal](8, 2) NOT NULL CONSTRAINT [DF_BillOfMaterials_PerAssemblyQty]  DEFAULT ((1.00)),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_BillOfMaterials_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Culture](
	[CultureID] [nchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Culture_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Document](
	[DocumentNode] [hierarchyid] NOT NULL,
	[DocumentLevel]  AS ([DocumentNode].[GetLevel]()),
	[Title] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Owner] [int] NOT NULL,
	[FolderFlag] [bit] NOT NULL CONSTRAINT [DF_Document_FolderFlag]  DEFAULT ((0)),
	[FileName] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileExtension] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Revision] [nchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ChangeNumber] [int] NOT NULL CONSTRAINT [DF_Document_ChangeNumber]  DEFAULT ((0)),
	[Status] [tinyint] NOT NULL,
	[DocumentSummary] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Document] [varbinary](max) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Document_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Document_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Illustration](
	[IllustrationID] [int] IDENTITY(1,1) NOT NULL,
	[Diagram] [xml] NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Illustration_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Location](
	[LocationID] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CostRate] [smallmoney] NOT NULL CONSTRAINT [DF_Location_CostRate]  DEFAULT ((0.00)),
	[Availability] [decimal](8, 2) NOT NULL CONSTRAINT [DF_Location_Availability]  DEFAULT ((0.00)),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Location_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[Product](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ProductNumber] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MakeFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Product_MakeFlag]  DEFAULT ((1)),
	[FinishedGoodsFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Product_FinishedGoodsFlag]  DEFAULT ((1)),
	[Color] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[ListPrice] [money] NOT NULL,
	[Size] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SizeUnitMeasureCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WeightUnitMeasureCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Weight] [decimal](8, 2) NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ProductLine] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Class] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Style] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ProductSubcategoryID] [int] NULL,
	[ProductModelID] [int] NULL,
	[SellStartDate] [datetime] NOT NULL,
	[SellEndDate] [datetime] NULL,
	[DiscontinuedDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Product_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Product_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductCategory](
	[ProductCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ProductCategory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCategory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductCostHistory](
	[ProductID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[StandardCost] [money] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductCostHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductDescription](
	[ProductDescriptionID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ProductDescription_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductDescription_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductDocument](
	[ProductID] [int] NOT NULL,
	[DocumentNode] [hierarchyid] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductDocument_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductInventory](
	[ProductID] [int] NOT NULL,
	[LocationID] [smallint] NOT NULL,
	[Shelf] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Bin] [tinyint] NOT NULL,
	[Quantity] [smallint] NOT NULL CONSTRAINT [DF_ProductInventory_Quantity]  DEFAULT ((0)),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ProductInventory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductInventory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductListPriceHistory](
	[ProductID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[ListPrice] [money] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductListPriceHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductModel](
	[ProductModelID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CatalogDescription] [xml](CONTENT [Production].[ProductDescriptionSchemaCollection]) NULL,
	[Instructions] [xml](CONTENT [Production].[ManuInstructionsSchemaCollection]) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ProductModel_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModel_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductModelIllustration](
	[ProductModelID] [int] NOT NULL,
	[IllustrationID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModelIllustration_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductModelProductDescriptionCulture](
	[ProductModelID] [int] NOT NULL,
	[ProductDescriptionID] [int] NOT NULL,
	[CultureID] [nchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductModelProductDescriptionCulture_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductPhoto](
	[ProductPhotoID] [int] IDENTITY(1,1) NOT NULL,
	[ThumbNailPhoto] [varbinary](max) NULL,
	[ThumbnailPhotoFileName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LargePhoto] [varbinary](max) NULL,
	[LargePhotoFileName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductPhoto_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductProductPhoto](
	[ProductID] [int] NOT NULL,
	[ProductPhotoID] [int] NOT NULL,
	[Primary] [dbo].[Flag] NOT NULL CONSTRAINT [DF_ProductProductPhoto_Primary]  DEFAULT ((0)),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductProductPhoto_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductReview](
	[ProductReviewID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ReviewerName] [dbo].[Name] NOT NULL,
	[ReviewDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ReviewDate]  DEFAULT (getdate()),
	[EmailAddress] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Rating] [int] NOT NULL,
	[Comments] [nvarchar](3850) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductReview_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductSubcategory](
	[ProductSubcategoryID] [int] IDENTITY(1,1) NOT NULL,
	[ProductCategoryID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ProductSubcategory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductSubcategory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ScrapReason](
	[ScrapReasonID] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ScrapReason_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[TransactionHistory](
	[TransactionID] [int] IDENTITY(100000,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[ReferenceOrderID] [int] NOT NULL,
	[ReferenceOrderLineID] [int] NOT NULL CONSTRAINT [DF_TransactionHistory_ReferenceOrderLineID]  DEFAULT ((0)),
	[TransactionDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistory_TransactionDate]  DEFAULT (getdate()),
	[TransactionType] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [int] NOT NULL,
	[ActualCost] [money] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[TransactionHistoryArchive](
	[TransactionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ReferenceOrderID] [int] NOT NULL,
	[ReferenceOrderLineID] [int] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_ReferenceOrderLineID]  DEFAULT ((0)),
	[TransactionDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_TransactionDate]  DEFAULT (getdate()),
	[TransactionType] [nchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [int] NOT NULL,
	[ActualCost] [money] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionHistoryArchive_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[UnitMeasure](
	[UnitMeasureCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_UnitMeasure_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[WorkOrder](
	[WorkOrderID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[OrderQty] [int] NOT NULL,
	[StockedQty]  AS (isnull([OrderQty]-[ScrappedQty],(0))),
	[ScrappedQty] [smallint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[DueDate] [datetime] NOT NULL,
	[ScrapReasonID] [smallint] NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrder_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[WorkOrderRouting](
	[WorkOrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[OperationSequence] [smallint] NOT NULL,
	[LocationID] [smallint] NOT NULL,
	[ScheduledStartDate] [datetime] NOT NULL,
	[ScheduledEndDate] [datetime] NOT NULL,
	[ActualStartDate] [datetime] NULL,
	[ActualEndDate] [datetime] NULL,
	[ActualResourceHrs] [decimal](9, 4) NULL,
	[PlannedCost] [money] NOT NULL,
	[ActualCost] [money] NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_WorkOrderRouting_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[ProductVendor](
	[ProductID] [int] NOT NULL,
	[BusinessEntityID] [int] NOT NULL,
	[AverageLeadTime] [int] NOT NULL,
	[StandardPrice] [money] NOT NULL,
	[LastReceiptCost] [money] NULL,
	[LastReceiptDate] [datetime] NULL,
	[MinOrderQty] [int] NOT NULL,
	[MaxOrderQty] [int] NOT NULL,
	[OnOrderQty] [int] NULL,
	[UnitMeasureCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductVendor_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[PurchaseOrderDetail](
	[PurchaseOrderID] [int] NOT NULL,
	[PurchaseOrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[LineTotal]  AS (isnull([OrderQty]*[UnitPrice],(0.00))),
	[ReceivedQty] [decimal](8, 2) NOT NULL,
	[RejectedQty] [decimal](8, 2) NOT NULL,
	[StockedQty]  AS (isnull([ReceivedQty]-[RejectedQty],(0.00))),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderDetail_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[PurchaseOrderHeader](
	[PurchaseOrderID] [int] IDENTITY(1,1) NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_RevisionNumber]  DEFAULT ((0)),
	[Status] [tinyint] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Status]  DEFAULT ((1)),
	[EmployeeID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_OrderDate]  DEFAULT (getdate()),
	[ShipDate] [datetime] NULL,
	[SubTotal] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_SubTotal]  DEFAULT ((0.00)),
	[TaxAmt] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_TaxAmt]  DEFAULT ((0.00)),
	[Freight] [money] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_Freight]  DEFAULT ((0.00)),
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))) PERSISTED NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PurchaseOrderHeader_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[ShipMethod](
	[ShipMethodID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ShipBase] [money] NOT NULL CONSTRAINT [DF_ShipMethod_ShipBase]  DEFAULT ((0.00)),
	[ShipRate] [money] NOT NULL CONSTRAINT [DF_ShipMethod_ShipRate]  DEFAULT ((0.00)),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_ShipMethod_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ShipMethod_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[Vendor](
	[BusinessEntityID] [int] NOT NULL,
	[AccountNumber] [dbo].[AccountNumber] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CreditRating] [tinyint] NOT NULL,
	[PreferredVendorStatus] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Vendor_PreferredVendorStatus]  DEFAULT ((1)),
	[ActiveFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_Vendor_ActiveFlag]  DEFAULT ((1)),
	[PurchasingWebServiceURL] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Vendor_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[CountryRegionCurrency](
	[CountryRegionCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CurrencyCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CountryRegionCurrency_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[CreditCard](
	[CreditCardID] [int] IDENTITY(1,1) NOT NULL,
	[CardType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardNumber] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpMonth] [tinyint] NOT NULL,
	[ExpYear] [smallint] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CreditCard_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[Currency](
	[CurrencyCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Currency_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[CurrencyRate](
	[CurrencyRateID] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyRateDate] [datetime] NOT NULL,
	[FromCurrencyCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ToCurrencyCode] [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AverageRate] [money] NOT NULL,
	[EndOfDayRate] [money] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_CurrencyRate_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[Customer](
	[CustomerID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[PersonID] [int] NULL,
	[StoreID] [int] NULL,
	[TerritoryID] [int] NULL,
	[AccountNumber]  AS (isnull('AW'+[dbo].[ufnLeadingZeros]([CustomerID]),'')),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Customer_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Customer_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[PersonCreditCard](
	[BusinessEntityID] [int] NOT NULL,
	[CreditCardID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_PersonCreditCard_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesOrderDetail](
	[SalesOrderID] [int] NOT NULL,
	[SalesOrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[CarrierTrackingNumber] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OrderQty] [smallint] NOT NULL,
	[ProductID] [int] NOT NULL,
	[SpecialOfferID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL CONSTRAINT [DF_SalesOrderDetail_UnitPriceDiscount]  DEFAULT ((0.0)),
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesOrderDetail_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderDetail_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesOrderHeader](
	[SalesOrderID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RevisionNumber] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_RevisionNumber]  DEFAULT ((0)),
	[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OrderDate]  DEFAULT (getdate()),
	[DueDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL,
	[Status] [tinyint] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Status]  DEFAULT ((1)),
	[OnlineOrderFlag] [dbo].[Flag] NOT NULL CONSTRAINT [DF_SalesOrderHeader_OnlineOrderFlag]  DEFAULT ((1)),
	[SalesOrderNumber]  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID]),N'*** ERROR ***')),
	[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
	[CustomerID] [int] NOT NULL,
	[SalesPersonID] [int] NULL,
	[TerritoryID] [int] NULL,
	[BillToAddressID] [int] NOT NULL,
	[ShipToAddressID] [int] NOT NULL,
	[ShipMethodID] [int] NOT NULL,
	[CreditCardID] [int] NULL,
	[CreditCardApprovalCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CurrencyRateID] [int] NULL,
	[SubTotal] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_SubTotal]  DEFAULT ((0.00)),
	[TaxAmt] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_TaxAmt]  DEFAULT ((0.00)),
	[Freight] [money] NOT NULL CONSTRAINT [DF_SalesOrderHeader_Freight]  DEFAULT ((0.00)),
	[TotalDue]  AS (isnull(([SubTotal]+[TaxAmt])+[Freight],(0))),
	[Comment] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesOrderHeader_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeader_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesOrderHeaderSalesReason](
	[SalesOrderID] [int] NOT NULL,
	[SalesReasonID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesOrderHeaderSalesReason_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesPerson](
	[BusinessEntityID] [int] NOT NULL,
	[TerritoryID] [int] NULL,
	[SalesQuota] [money] NULL,
	[Bonus] [money] NOT NULL CONSTRAINT [DF_SalesPerson_Bonus]  DEFAULT ((0.00)),
	[CommissionPct] [smallmoney] NOT NULL CONSTRAINT [DF_SalesPerson_CommissionPct]  DEFAULT ((0.00)),
	[SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesPerson_SalesYTD]  DEFAULT ((0.00)),
	[SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesPerson_SalesLastYear]  DEFAULT ((0.00)),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesPerson_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesPerson_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesPersonQuotaHistory](
	[BusinessEntityID] [int] NOT NULL,
	[QuotaDate] [datetime] NOT NULL,
	[SalesQuota] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesPersonQuotaHistory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesPersonQuotaHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesReason](
	[SalesReasonID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ReasonType] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesReason_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesTaxRate](
	[SalesTaxRateID] [int] IDENTITY(1,1) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[TaxType] [tinyint] NOT NULL,
	[TaxRate] [smallmoney] NOT NULL CONSTRAINT [DF_SalesTaxRate_TaxRate]  DEFAULT ((0.00)),
	[Name] [dbo].[Name] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesTaxRate_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTaxRate_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesTerritory](
	[TerritoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CountryRegionCode] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Group] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SalesYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesYTD]  DEFAULT ((0.00)),
	[SalesLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_SalesLastYear]  DEFAULT ((0.00)),
	[CostYTD] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostYTD]  DEFAULT ((0.00)),
	[CostLastYear] [money] NOT NULL CONSTRAINT [DF_SalesTerritory_CostLastYear]  DEFAULT ((0.00)),
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesTerritory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTerritory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SalesTerritoryHistory](
	[BusinessEntityID] [int] NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SalesTerritoryHistory_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SalesTerritoryHistory_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[ShoppingCartItem](
	[ShoppingCartItemID] [int] IDENTITY(1,1) NOT NULL,
	[ShoppingCartID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Quantity] [int] NOT NULL CONSTRAINT [DF_ShoppingCartItem_Quantity]  DEFAULT ((1)),
	[ProductID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL CONSTRAINT [DF_ShoppingCartItem_DateCreated]  DEFAULT (getdate()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ShoppingCartItem_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SpecialOffer](
	[SpecialOfferID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPct] [smallmoney] NOT NULL CONSTRAINT [DF_SpecialOffer_DiscountPct]  DEFAULT ((0.00)),
	[Type] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Category] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[MinQty] [int] NOT NULL CONSTRAINT [DF_SpecialOffer_MinQty]  DEFAULT ((0)),
	[MaxQty] [int] NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SpecialOffer_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SpecialOffer_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[SpecialOfferProduct](
	[SpecialOfferID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_SpecialOfferProduct_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_SpecialOfferProduct_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Sales].[Store](
	[BusinessEntityID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[SalesPersonID] [int] NULL,
	[Demographics] [xml](CONTENT [Sales].[StoreSurveySchemaCollection]) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_Store_rowguid]  DEFAULT (newid()),
	[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_Store_ModifiedDate]  DEFAULT (getdate())
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

