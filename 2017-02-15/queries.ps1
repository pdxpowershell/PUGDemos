$queries = @{}

$queries.databases = @"
Select
	name,
	create_date,
	compatibility_level
From sys.databases
"@

$queries.people = @"
Select
top 100 *
FROM Person.Person
WHERE
	 LastName = @lastName
"@

$queries.queryPlans = @"
SELECT plan_handle, query_plan, objtype, text   
FROM sys.dm_exec_cached_plans   
CROSS APPLY sys.dm_exec_query_plan(plan_handle)
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
"@