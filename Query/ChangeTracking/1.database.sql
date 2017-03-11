use demo
go

CREATE TABLE dbo.Customer (
	CustomerID int not null identity(1,1),
	CustomerName varchar(250) null,
	City varchar(250),
	StateProvince varchar(250),
	PostalCode varchar(10),
	constraint pk_customer primary key clustered (CustomerID)
)
GO

CREATE TABLE dbo.Product (
	ProductID int not null identity(1,1),
	ProductName varchar(30) not null,
	Price decimal(6,2) not null,
	constraint pk_product primary key clustered (ProductID)
)
GO

CREATE TABLE dbo.Sale (
	SaleID int not null identity(1,1),
	CustomerID int null,
	ProductID int not null,
	SaleDate datetime2(0) not null,
	TransactionType tinyint not null,
	Quantity int not null,
	Price int not null,
	Subtotal decimal(17, 2) not null,
	constraint pk_saledetail primary key clustered (SaleID)
)
GO

alter table dbo.sale add constraint fk_sale_product foreign key (productid) references dbo.product (productid) on delete cascade
go

alter table dbo.sale add constraint fk_sale_customer foreign key (customerid) references dbo.customer (customerid) on delete cascade
go

alter table dbo.sale add constraint df_sale_transactiontype default ((1)) for TransactionType
GO

create proc dbo.NewSale
@makeCustomer bit
as

DECLARE @maxcustid int, @maxproductid int, @rndcustomerid int, @rndproductid int, @rndquant tinyint, @price decimal(6,2);
set @maxcustid = (select max(customerid) from dbo.Customer);
set @maxproductid = (select max(productid) from dbo.Product);
set @rndproductid = ABS(Checksum(NewID()) % @maxproductid) + 1;
set @rndquant = ABS(Checksum(NewID()) % 3) + 1;
set @price = (select price from dbo.Product where productid = @rndproductid);

if (@makeCustomer=1)
begin

INSERT INTO [dbo].[Sale]
([CustomerID]
,[ProductID]
,[SaleDate]
,[TransactionType]
,[Quantity]
,[Price]
,[Subtotal])
VALUES
(@maxcustid
,@rndproductid
,SYSDATETIME()
,1
,@rndquant
,@price
,@rndquant * @price
)

end
else
begin

set @rndcustomerid = ABS(Checksum(NewID()) % @maxcustid) + 1;

INSERT INTO [dbo].[Sale]
([CustomerID]
,[ProductID]
,[SaleDate]
,[TransactionType]
,[Quantity]
,[Price]
,[Subtotal])
VALUES
(@rndcustomerid
,@rndproductid
,SYSDATETIME()
,1
,@rndquant
,@price
,@rndquant * @price
)

end
go


create proc dbo.UpdateCustomer
@CustomerName varchar(250)
,@City varchar(250)
,@StateProvince varchar(250)
,@PostalCode varchar(10)
as

declare @maxcustomerid int, @rndcustomerid int, @maxproductid int, @rndproductid int, @rndquant tinyint, @price decimal(6,2);
set @maxcustomerid = (select max(customerid) from dbo.Customer);
set @rndcustomerid = ABS(Checksum(NewID()) % @maxcustomerid) + 1;
set @maxproductid = (select max(productid) from dbo.Product);
set @rndproductid = ABS(Checksum(NewID()) % @maxproductid) + 1;
set @rndquant = ABS(Checksum(NewID()) % 3) + 1;
set @price = (select price from dbo.Product where productid = @rndproductid);


UPDATE [dbo].[Customer] 
SET 
	[CustomerName] = @CustomerName,
	[City] = @City,
	[StateProvince] = @StateProvince,
	[PostalCode] = @PostalCode 
WHERE CustomerID = @rndcustomerid;

INSERT INTO [dbo].[Sale]
([CustomerID]
,[ProductID]
,[SaleDate]
,[TransactionType]
,[Quantity]
,[Price]
,[Subtotal])
VALUES
(@rndcustomerid
,@rndproductid
,SYSDATETIME()
,1
,@rndquant
,@price
,@rndquant * @price
)

GO


CREATE TABLE dbo._ChangeHistory (
	ID int not null identity(1,1),
	TableName sysname not null,
	PreviousVersion bigint null,
	ModifyDate datetime2(0) not null
);
go

CREATE UNIQUE CLUSTERED INDEX [ix : ChangeHistory : TableName] ON [dbo].[_ChangeHistory]
(
	[TableName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE proc [dbo].[_GetChangeTrackingVersion]
@tablename sysname,
@previousversion bigint output
as

	select @previousversion = PreviousVersion
	from dbo._ChangeHistory
	where TableName = @tablename

RETURN

go

create proc dbo._SetChangeTrackingVersion
@tablename sysname,
@currentversion bigint
as

merge dbo._ChangeHistory t
using (
	select 
		@tablename TableName,
		@currentversion CurrentVersion
) s
on s.TableName = t.TableName
when matched then update set
	PreviousVersion = CurrentVersion,
	ModifyDate = sysdatetime()
when not matched then insert
(
	TableName
	,PreviousVersion
	,ModifyDate
) values (
	s.TableName
	,s.CurrentVersion
	,sysdatetime()
);

go

create schema EDW
go

CREATE TABLE EDW.stgCustomer (
	CustomerID int not null,
	CustomerName varchar(250) null,
	City varchar(250),
	StateProvince varchar(250),
	PostalCode varchar(10),
	DMLAction varchar(6),
	constraint pk_downstreamcustomer primary key clustered (CustomerID)
)
GO

CREATE TABLE EDW.stgProduct (
	ProductID int not null,
	ProductName varchar(30) null,
	Price decimal(6,2) null,
	DMLAction varchar(6),
	constraint pk_downstreamproduct primary key clustered (ProductID)
)
GO

CREATE TABLE EDW.stgSale (
	SaleID int not null,
	CustomerID int null,
	ProductID int null,
	SaleDate datetime2(0) null,
	TransactionType tinyint null,
	Quantity int null,
	Price int null,
	Subtotal decimal(17, 2) null,
	DMLAction varchar(6),
	constraint pk_downstreamsaledetail primary key clustered (SaleID)
)
GO

ALTER DATABASE demo  
    SET ALLOW_SNAPSHOT_ISOLATION ON;  
GO


