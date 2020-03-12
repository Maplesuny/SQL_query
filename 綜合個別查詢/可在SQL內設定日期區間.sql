SELECT s1.非假日
FROM
	(SELECT CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) AS 報工日期,
          角色.NAME AS 報工者,
	          CASE 
	             (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5)
	             WHEN '0' THEN CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)
	          END AS 非假日,
          
	          CASE
	              (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5)
	          WHEN '0' THEN 工時紀錄表.SA_WORK_HOURS
	          END AS 工時
	 FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
	 LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
   	) AS s1
WHERE NOT EXISTS
	(
		SELECT s1.非假日
	    FROM
	     -- FROM內可以在塞SELECT子查詢
	       (SELECT CASE 行事曆單身.day_off WHEN '1' THEN CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) END AS 休假日
	        FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
		        LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
		        LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111)
		   )AS x1
     	WHERE s1.非假日 =x1.休假日 
     )
  	AND s1.報工者= '0272 陳柏仁'
  	AND (s1.非假日 BETWEEN CONVERT(VARCHAR(10),DATEADD(MONTH,-5,getdate()),111) AND CONVERT(VARCHAR(10),DATEADD(MONTH,-3,getdate()),111))
ORDER BY s1.非假日
