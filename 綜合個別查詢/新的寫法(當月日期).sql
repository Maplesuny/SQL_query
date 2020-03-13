-- *** 組合起來 ***

--  參考: [SQL]計算日期之間的工作日  https://dotblogs.com.tw/rainmaker/2015/05/21/151358
DECLARE @startDate  DATETIME, @endDate DATETIME
SELECT @startDate = '2019/11/01' ,@endDate = '2019/11/30';
WITH WorkDays -- 所有日期 扣掉 6、日及節日
AS(
	SELECT @startDate AS WorkDay, DATEDIFF(DAY, @startDate, @endDate) AS DiffDays
	UNION ALL
	SELECT DATEADD(dd, 1, WorkDay),DiffDays -1
	FROM WorkDays wd
	WHERE DiffDays > 0

)

SELECT 
CONVERT(varchar, SWITCHOFFSET(wd.WorkDay, '+08:00'), 111) as 當月日期
FROM WorkDays wd
WHERE DATEPART(dw, WorkDay ) IN (2,3, 4, 5, 6) -- 星期 1 ~ 5
