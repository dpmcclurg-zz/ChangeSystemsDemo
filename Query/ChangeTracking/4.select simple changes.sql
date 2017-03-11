use demo
go

select *
from changetable(changes dbo.Product, null) ct

select *
from changetable(changes dbo.Product, 0) ct

select *
from changetable(changes dbo.Product, 1) ct

--select *
--from changetable(changes dbo.Sale, null) ct