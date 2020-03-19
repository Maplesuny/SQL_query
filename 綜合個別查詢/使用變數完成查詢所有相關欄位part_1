DECLARE @startDate DATETIME,
        @endDate DATETIME,
        @報工者 varchar(20)
SELECT @startDate = '2019/11/01', @endDate = '2019/12/02' 

;WITH 
	 A AS (-- 此為上班日(包含休假日)

   	 		SELECT * 
    		FROM
       			(SELECT -- 0為上班日，1為六日
 					CASE
 						 (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) 
 					WHEN '0' 
 					THEN CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) END AS 上班日, 角色.NAME AS 報工者
              	FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
              	LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID) 判斷上班日
           WHERE 判斷上班日.上班日 IS NOT NULL),
     A2 AS (-- 休假日

            SELECT * 
            FROM
              	(SELECT 
              		CASE 行事曆單身.day_off 
              		WHEN '1' 
              		THEN CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) END AS 休假日
               	FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
               	LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) )AS cc
            WHERE cc.休假日 IS NOT NULL),
     A3 AS ( -- 不包含六日、休假日的日期 (上班日)
            SELECT *
            FROM A
            WHERE NOT EXISTS
                ( SELECT A.上班日
                 FROM A2
                 WHERE A.上班日 = A2.休假日
                   AND 上班日 BETWEEN @startDate AND @endDate --
 )),
	b as  -- 實際總工時(他在Aras有報的工時)  可以依據時間來加總
		(
			select 角色.NAME as 報工者,
				SUM(工時紀錄表.SA_WORK_HOURS) as 實際總工時
			from [innovator].[IN_TIMERECORD] as 工時紀錄表
			left join [innovator].[IDENTITY] as 角色 on 工時紀錄表.OWNED_BY_ID = 角色.ID

			where CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) IN (SELECT 上班日 FROM A3 WHERE A3.上班日 between @startDate and @endDate)
			
           GROUP BY 角色.NAME 

		),

     C AS (-- 計算不重複的日期

           SELECT COUNT(DISTINCT A3.上班日) AS COUNT0,
                  A3.報工者
           FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
           LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 角色.id = 工時紀錄表.OWNED_BY_ID, A3
           WHERE A3.上班日 BETWEEN @startDate AND @endDate --

           GROUP BY a3.報工者 )
SELECT t1.上班日,
       t1.報工者,
       c.COUNT0,
	   b.實際總工時
FROM A3 AS t1,c,b
--LEFT JOIN C AS t2 ON t1.報工者=t2.報工者,b
WHERE 上班日 BETWEEN @startDate AND @endDate
and t1.報工者 = c.報工者
and b.報工者 = t1.報工者
ORDER BY t1.報工者,
         t1.上班日
