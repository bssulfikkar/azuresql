DECLARE @retval varchar(max);
DECLARE @sSQL nvarchar(max);
DECLARE @sSQL1 nvarchar(max);
DECLARE @ParmDefinition nvarchar(max);
DECLARE @id int = 1;
DECLARE @tablecount int ;

IF OBJECT_ID('tempdb..#test', 'U') IS NOT NULL
DROP TABLE #test


-- update where condition in the below query according to your requirement

SELECT distinct concat(table_schema,'.',table_name) as name , ROW_NUMBER() OVER( order by table_name) AS Row_Id into #test from INFORMATION_SCHEMA.COLUMNS 
where 
-- table_schema = 'dbo' and 
TABLE_NAME not like '%MigrationLog%' 
and TABLE_NAME not like '%SchemaSnapshot%'
and table_schema not like 'sys'
group by table_schema,table_name


SET @tablecount = (select COUNT(*) from #test);

WHILE (@id < @tablecount) 

BEGIN

SELECT @sSQL = N'SELECT @retvalOUT = name FROM #test where  Row_Id='  +CAST(@id AS varchar(max))

SET @ParmDefinition = N'@retvalOUT varchar(max) OUTPUT';

print @sSQL

EXEC sp_executesql @sSQL, @ParmDefinition, @retvalOUT=@retval OUTPUT;

print @retval

SELECT @sSQL1 = N'EXEC sys.sp_spaceused @objname = N'+ ''''   +@retval + ''''

print @sSQL1

EXEC sp_executesql @sSQL1;

set @id = @id+1 

END