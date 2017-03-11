use demo
go

DECLARE @previousversion BIGINT, @intermediateversion BIGINT

SET @previousversion = CHANGE_TRACKING_CURRENT_VERSION();


--FIRST TRANSACTION
UPDATE dbo.Product
SET
	ProductName = 'New Orange'
WHERE ProductID = 1;




SET @intermediateversion = CHANGE_TRACKING_CURRENT_VERSION();

--SECOND TRANSACTION
DELETE dbo.Product
WHERE ProductID = 1;





select @previousversion, @intermediateversion