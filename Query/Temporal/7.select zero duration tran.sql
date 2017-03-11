with cte as (
	select *, SysStartTime, SysEndTime, 'Base Table' SourceTable
	from dbo.Product
	where ProductID = 3

	union

	select *, 'History Table' SourceTable
	from History.Product
	where ProductID = 3
)
select * from cte
order by sysendtime desc