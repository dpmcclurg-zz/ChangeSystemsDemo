use demo
go

ALTER DATABASE Demo
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

GO

ALTER TABLE [dbo].[Sale]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = OFF);

ALTER TABLE [dbo].[Customer]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = OFF);

ALTER TABLE [dbo].[Product]
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = OFF);
GO

--for management concerns see: https://msdn.microsoft.com/en-us/library/hh710064.aspx






















CREATE PROC dbo.GetProductChanges
@nextversion bigint output
AS

DECLARE @last_synchronization_version bigint;

EXEC [dbo].[_GetChangeTrackingVersion] @tablename = 'dbo.Product', @previousversion = @last_synchronization_version output;

IF (@last_synchronization_version >= CHANGE_TRACKING_MIN_VALID_VERSION(  
                                   OBJECT_ID('dbo.Product')))  
BEGIN  
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;  
	BEGIN TRAN  
	  
	  DECLARE @currentversion bigint = change_tracking_current_version();

		select 
			CASE ct.SYS_CHANGE_OPERATION WHEN 'D' THEN 'DELETE' ELSE 'MERGE' END DMLAction, 
			ct.ProductID, 
			p.Price,
			p.ProductName
		from dbo.Product p
		right join changetable(changes dbo.Product, @last_synchronization_version) ct
			on ct.ProductID = p.ProductID;
	   
	   SET @nextversion = @currentversion;
	COMMIT TRAN;
END
ELSE
BEGIN
	THROW 51000, 'INVALID LAST SYNC VERSION!', 1;
END;

GO


declare @MinVersion bigint = change_tracking_min_valid_version(OBJECT_ID('dbo.Product'));

exec dbo._SetChangeTrackingVersion @tablename = 'dbo.Product', @currentversion = @MinVersion;
go




