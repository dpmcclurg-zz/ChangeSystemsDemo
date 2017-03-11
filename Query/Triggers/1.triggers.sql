ALTER TABLE dbo.Product SET (SYSTEM_VERSIONING = OFF);    
ALTER TABLE dbo.Product   
	DROP PERIOD FOR SYSTEM_TIME; 
go

CREATE TABLE dbo.ProductHistory (
	ID bigint not null identity(1,1),
	ProductID int not null,
	ProductName varchar(30) not null,
	Price decimal(6,2) not null,
	DMLAction char(1) not null,
	CreateDate datetime2(3) not null,
	constraint pk_producthistory primary key clustered (ID, ProductID)
);
GO

create nonclustered index ProductHistory on dbo.ProductHistory (CreateDate);
go

create trigger dbo.[tr : Product : Insert]
on dbo.product
after insert
as

insert into dbo.ProductHistory
(
	[ProductID]
    ,[ProductName]
    ,[Price]
	,[DMLAction]
	,[CreateDate]
)
select
	[ProductID]
    ,[ProductName]
    ,[Price]
	,'I'
	,sysdatetime()
from inserted

go

create trigger dbo.[tr : Product : Update]
on dbo.product
after update
as

insert into dbo.ProductHistory
(
	[ProductID]
    ,[ProductName]
    ,[Price]
	,[DMLAction]
	,[CreateDate]
)
select
	[ProductID]
    ,[ProductName]
    ,[Price]
	,'U'
	,sysdatetime()
from inserted

go


create trigger dbo.[tr : Product : Delete]
on dbo.product
after delete
as

insert into dbo.ProductHistory
(
	[ProductID]
    ,[ProductName]
    ,[Price]
	,[DMLAction]
	,[CreateDate]
)
select
	[ProductID]
    ,[ProductName]
    ,[Price]
	,'D'
	,sysdatetime()
from deleted

go


create function dbo.ProductChanges
(
	@LastChangeDate datetime2(7)
)
returns table
as
return
select  
	p1.ProductID, 
	p1.Price,
	p1.ProductName
from dbo.ProductHistory p1
left join dbo.ProductHistory p2
	on p2.ProductID = p1.ProductID
	and p2.[CreateDate] > p1.[CreateDate]
where p1.[CreateDate] >= @LastChangeDate
	and p2.ProductID is null
go


declare @CurrentDate datetime2(7) = sysdatetime();

exec dbo._SetLastChangeDate @tablename = 'dbo.Product', @CurrentDate = @CurrentDate;
go
