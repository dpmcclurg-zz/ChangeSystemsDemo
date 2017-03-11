use demo
go

select 
	CASE ct.SYS_CHANGE_OPERATION WHEN 'D' THEN 'DELETE' ELSE 'MERGE' END DMLAction, 
	ct.ProductID, 
	p.Price,
	p.ProductName
from dbo.Product p
right join changetable(changes dbo.Product, 0) ct
	on ct.ProductID = p.ProductID