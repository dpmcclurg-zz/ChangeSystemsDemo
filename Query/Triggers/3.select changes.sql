USE [demo]
GO

declare @lastchangedate datetime2(7);

exec dbo._GetLastChangeDate @tablename = 'dbo.Product', @lastchangedate = @lastchangedate output;

SELECT * FROM [dbo].[ProductChanges] (@lastchangedate)
GO


