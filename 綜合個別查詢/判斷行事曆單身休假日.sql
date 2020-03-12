-- 休假日
select 
 case 行事曆單身.day_off when '1' 
	then convert(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111) end as 休假日

from [innovator].[IN_TIMERECORD] as 工時紀錄表
left join [innovator].[BUSINESS_CALENDAR_EXCEPTION] as 行事曆單身 on convert(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) = convert(varchar, SWITCHOFFSET(行事曆單身.DAY_DATE, '+08:00'), 111)

