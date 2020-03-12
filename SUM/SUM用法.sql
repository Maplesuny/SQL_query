-- 在SELECT中不能使用 *，會導致在GROUP BY的時候出錯，錯誤訊息如:"資料行 's1.報工日期' 在選取清單中無效，因為它並未包含在彙總函式或 GROUP BY 子句中。"
SELECT s1.報工者,sum(s1.工時)
FROM 
(
	SELECT 
		CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) AS 報工日期,
		(SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) AS 判斷是否假日,
		CASE 
			(SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) WHEN '0' 
		THEN 
			CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) END  非假日,
		專案.NAME AS 專案名稱,
		客戶.IN_NAME_F AS 客戶,
		角色.NAME AS 報工者,
		部門.NAME AS 報工部門,
		工時紀錄表.SA_TASKCLASS AS 任務分類,
		CASE (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) WHEN '0' 
		THEN 工時紀錄表.SA_WORK_HOURS
		END as 工時
	FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
	LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
	LEFT JOIN [innovator].[IDENTITY] AS 部門 ON 角色.IN_DEPT = 部門.ID 
	LEFT JOIN [innovator].[CUSTOMER] AS 客戶 ON 客戶.ID =工時紀錄表.SA_CUSTOMER
	LEFT JOIN [innovator].[PROJECT] AS 專案 ON 專案.ID = 工時紀錄表.IN_PROJECT
	LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON 
	行事曆單身.DAY_DATE = 
		CASE (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) 
		WHEN '0' 
		THEN CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) END
)s1
WHERE 
	NOT EXISTS(
		SELECT s1.非假日 
		FROM (
			SELECT 
				CASE 行事曆單身.day_off 
				WHEN '1' 
				THEN CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) END AS 休假日
			FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
				LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
				LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111)
			)AS x1
		WHERE s1.非假日 =x1.休假日
		)
	and s1.報工者= '0271 楊承檍'

	group by s1.報工者
	
