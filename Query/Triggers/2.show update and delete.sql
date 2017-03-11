UPDATE dbo.Product
SET
	ProductName = 'Trigger Orange'
WHERE ProductID = 4;

UPDATE dbo.Product
SET
	ProductName = 'Trigger Green'
WHERE ProductID = 5;

DELETE dbo.Product
WHERE ProductID = 6;