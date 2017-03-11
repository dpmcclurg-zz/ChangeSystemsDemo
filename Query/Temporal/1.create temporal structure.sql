use demo
go

drop table [dbo].[_ChangeHistory];
drop proc [dbo].[_GetChangeTrackingVersion];
drop proc [dbo].[_SetChangeTrackingVersion];
drop proc dbo.getproductchanges;
GO

EXEC sp_MSforeachtable
 'ALTER TABLE ?
  Disable Change_tracking;';
go

alter database demo set change_tracking = off;
go

CREATE TABLE [dbo].[_ChangeHistory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [sysname] NOT NULL,
	[PreviousDate] datetime2(7) NULL,
	[ModifyDate] [datetime2](0) NOT NULL
);
go


CREATE proc [dbo].[_GetLastChangeDate]
@tablename sysname,
@lastchangedate varchar(100) output
as

select @lastchangedate = cast(PreviousDate as varchar(100))
from dbo._ChangeHistory
where TableName = @tablename

RETURN
GO

CREATE proc [dbo].[_SetLastChangeDate]
@tablename sysname,
@currentdate datetime2(7)
as

merge dbo._ChangeHistory t
using (
	select 
		@tablename TableName,
		@currentdate CurrentDate
) s
on s.TableName = t.TableName
when matched then update set
	PreviousDate = CurrentDate,
	ModifyDate = sysutcdatetime()
when not matched then insert
(
	TableName
	,PreviousDate
	,ModifyDate
) values (
	s.TableName
	,s.CurrentDate
	,sysutcdatetime()
);


GO

declare @CurrentDate datetime2(7) = sysutcdatetime();

exec dbo._SetLastChangeDate @tablename = 'dbo.Product', @CurrentDate = @CurrentDate;
go













create schema History
go

ALTER TABLE dbo.Product
ADD   
      SysStartTime datetime2(7) GENERATED ALWAYS AS ROW START HIDDEN    
           CONSTRAINT DF_SysStart DEFAULT SYSUTCDATETIME(),

      SysEndTime datetime2(7) GENERATED ALWAYS AS ROW END HIDDEN    
           CONSTRAINT DF_SysEnd DEFAULT CONVERT(datetime2 (7), '9999-12-31 23:59:59.9999999'),   

      PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime);   

GO

ALTER TABLE dbo.Product   
   SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = History.Product))   
;
GO

















CREATE PROC [dbo].[GetProductChanges]
@NextChangeDate datetime2(7) output
as

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;  
BEGIN TRAN

declare @currenttime datetime2(7) = sysutcdatetime()
declare @lastchangedate datetime2(7);

exec dbo._GetLastChangeDate @tablename = 'dbo.Product', @lastchangedate = @lastchangedate output;

select  
	case when p1.sysendtime <= @currenttime then 'DELETE' else 'MERGE' END DMLAction,
	p1.ProductID, 
	p1.Price,
	p1.ProductName
from dbo.Product for system_time all p1
left join dbo.Product for system_time contained in (@lastchangedate,'9999-12-31 23:59:59.9999999') p2
	on p2.ProductID = p1.ProductID
	and p2.[SysEndTime] > p1.[SysEndTime]
where (p1.[SysStartTime] >= @lastchangedate
	or (p1.[SysEndTime] >= @lastchangedate 
		and p1.[SysEndTime] <= @currenttime))
	and p2.ProductID is null

SET @NextChangeDate = @currenttime

COMMIT TRAN;

RETURN

GO

