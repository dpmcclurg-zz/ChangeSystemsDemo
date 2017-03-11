use demo
go

DECLARE @previousversion BIGINT, @nextversion BIGINT




SET @previousversion = CHANGE_TRACKING_CURRENT_VERSION();

UPDATE dbo.Product
SET
	ProductName = 'New Orange'
WHERE ProductID = 2;




SET @nextversion = CHANGE_TRACKING_CURRENT_VERSION();

UPDATE dbo.Product
SET
	ProductName = 'New Green'
WHERE ProductID = 3;





select @previousversion, @nextversion