declare @currenttime datetime2(7) = sysutcdatetime()
declare @lastchangedate datetime2(7);

exec dbo._GetLastChangeDate @tablename = 'dbo.Product', @lastchangedate = @lastchangedate output;

select  
	case when p1.sysendtime <= @currenttime then 'DELETE' else 'MERGE' END DMLAction,
	p1.ProductID, 
	p1.Price,
	p1.ProductName
from dbo.Product for system_time all p1
left join dbo.Product for system_time contained in (@lastchangedate,'9999-12-31 23:59:59.9999999') p2
	on p2.ProductID = p1.ProductID
	and p2.[SysEndTime] > p1.[SysEndTime]

where (p1.[SysStartTime] >= @lastchangedate --filter to incremental changes only
	or (p1.[SysEndTime] >= @lastchangedate 
		and p1.[SysEndTime] <= @currenttime)) --append deletes
	and p2.ProductID is null --filter to most recent versions only
order by ProductID