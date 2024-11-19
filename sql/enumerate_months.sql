SELECT DATENAME(MONTH, DATEADD(MM, s.number, CONVERT(DATETIME, 0))) AS [MonthName], 
MONTH(DATEADD(MM, s.number, CONVERT(DATETIME, 0))) AS [MonthNumber] 
FROM master.dbo.spt_values s 
WHERE [type] = 'P' AND s.number BETWEEN 0 AND 11
ORDER BY 2

;WITH months(MonthNumber) AS
(
    SELECT 1
    UNION ALL
    SELECT MonthNumber+1 
    FROM months
    WHERE MonthNumber < 12
)
select *
from months;