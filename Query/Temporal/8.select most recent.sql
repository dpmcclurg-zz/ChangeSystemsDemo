select  
	p1.ProductID, 
	p1.Price,
	p1.ProductName
from dbo.Product for system_time all p1
left join dbo.Product for system_time all p2
	on p2.ProductID = p1.ProductID
	and p2.[SysEndTime] > p1.[SysEndTime]
where p2.ProductID is null --filter to most recent versions only
order by ProductID