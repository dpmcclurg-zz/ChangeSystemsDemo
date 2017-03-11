declare @currenttime datetime2(7) = sysutcdatetime()
	,@intermediatetime datetime2(7);

UPDATE dbo.Product
SET
	ProductName = 'Temporal Orange'
WHERE ProductID = 2;

set @intermediatetime = SYSUTCDATETIME();

UPDATE dbo.Product
SET
	ProductName = 'Temporal Green'
WHERE ProductID = 3;

select @currenttime PreviousTime, @intermediatetime IntermediateTime;
