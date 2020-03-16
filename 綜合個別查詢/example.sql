/*
利用宣告變數讓SQL更容易維護，套用在別處可直接替換
*/
DECLARE 
	@startDate DATETIME,
	@endDate DATETIME,
	@報工者 varchar(20)

select 	@startDate = '2019/11/01',	@endDate = '2019/11/30' , @報工者 ='0271 楊承檍'

;with  
a1 as  -- 上班日 
(
	SELECT * from
	  ( SELECT 
		CASE
		 (SELECT DATEDIFF(DAY, '17530101', CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) 
		WHEN '0' 
		THEN CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)  END AS 非假日,
		角色.NAME as 報工者,
		工時紀錄表.IN_START_TIME as 工作日期
	   FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
	   LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID ) AS bb
	WHERE bb.非假日 IS NOT NULL
),
a2 as -- 非假日 
(
	SELECT * from(SELECT 
		CASE 行事曆單身.day_off 
		WHEN '1' 
		THEN CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) END AS 休假日
	FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
		LEFT JOIN [innovator].[BUSINESS_CALENDAR_EXCEPTION] AS 行事曆單身 ON CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = CONVERT(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111)
	)as cc
	where cc.休假日 is not null
),
b as  -- 實際總工時(他在Aras有報的工時)  可以依據時間來加總
(
	select 
		角色.name as 報工者,
		sum(工時紀錄表.SA_WORK_HOURS) as 實際總工時
	from [innovator].[IN_TIMERECORD] as 工時紀錄表
	left join [innovator].[IDENTITY] as 角色 on 工時紀錄表.OWNED_BY_ID = 角色.ID
	where 角色.NAME = @報工者
	AND (CONVERT(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) BETWEEN CONVERT(varchar, SWITCHOFFSET(@startDate, '+08:00'), 111) AND CONVERT(varchar, SWITCHOFFSET(@endDate, '+08:00'), 111))
	group by 角色.name
)


select a1.報工者,a1.非假日,b.實際總工時
from a1,b
where NOT EXISTS    -- 挑選日期不一樣的，(休假日 != 上班日 ) 
(
	-- 我要從休假日裡面去找"休假日=上班日"
	select a1.非假日
	from a2
	where a1.非假日 = a2.休假日
)
and  a1.報工者 = @報工者
AND (a1.非假日 BETWEEN CONVERT(varchar, SWITCHOFFSET(@startDate, '+08:00'), 111) AND CONVERT(varchar, SWITCHOFFSET(@endDate, '+08:00'), 111))
order by 非假日
