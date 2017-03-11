declare @currenttime datetime2(7) = sysutcdatetime()
	,@intermediatetime datetime2(7);

begin tran

UPDATE dbo.Product
SET
	ProductName = 'Multiple Orange'
WHERE ProductID = 3;

set @intermediatetime = SYSUTCDATETIME();

UPDATE dbo.Product
SET
	ProductName = 'Change Green'
WHERE ProductID = 3;

commit tran

select @currenttime PreviousTime, @intermediatetime IntermediateTime;
