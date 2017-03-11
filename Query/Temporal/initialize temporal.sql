use demo
go

declare @CurrentDate datetime2(7) = sysutcdatetime();

exec dbo._SetLastChangeDate @tablename = 'dbo.Product', @CurrentDate = @CurrentDate;