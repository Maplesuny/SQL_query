/*
可到使用者選"當日工時上限"，並且乘上所有工時紀錄的工時
工作天數  不等於  一個月的天數， 是在工時紀錄表上   0271 楊承檍  所繼載的天數
*/
select 
使用者.KEYED_NAME,
使用者.in_day_hour as 日工時上限,
cc.工作天數 as 工作天數,
使用者.IN_DAY_HOUR * cc.工作天數 應報工工時上限,
CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) as 報工日期

from [innovator].[IN_TIMERECORD] as 工時紀錄表 
left join [innovator].[IDENTITY] as 角色 on 工時紀錄表.OWNED_BY_ID = 角色.ID
left join [innovator].[USER] as 使用者 on 角色.KEYED_NAME = 使用者.KEYED_NAME,
(
--
		SELECT
		bb.報工者,
		count(bb.非假日) as 工作天數
		FROM
		  (SELECT 
  
				CASE
					 (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5)
				WHEN '0' THEN CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)
				END AS 非假日,

				CASE (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) WHEN '0' 
				THEN 工時紀錄表.SA_WORK_HOURS
				END as 工時,

				角色.name as 報工者,
				CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) as 報工日期
		  
		   FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
		   LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
		   ) AS bb
  
		WHERE bb.非假日 IS NOT NULL
		  AND NOT EXISTS
			(SELECT *
			 FROM
			   (SELECT CASE 行事曆單身.day_off WHEN '1' THEN CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) END AS 休假日
				FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
				LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111))AS cc
			 WHERE cc.休假日 IS NOT NULL
			   AND bb.非假日 = cc.休假日)
			group by bb.報工者
--
) as cc

where 角色.NAME = cc.報工者
and 角色.NAME ='0249 劉昇泰'
order by CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)
