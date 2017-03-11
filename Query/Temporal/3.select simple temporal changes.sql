use demo
go

select *
--,[SysStartTime], [SysEndTime]
from dbo.Product
for system_time all

where ProductID in (2,3)
order by ProductID, [SysEndTime] desc

select *
from dbo.Product
for system_time as of ''
where ProductID in (2,3)
order by ProductID