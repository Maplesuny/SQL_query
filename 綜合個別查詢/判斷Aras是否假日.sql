select 
	convert(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) as 報工日期,
	(select DATEDIFF(DAY, '17530101', convert(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)) % 7 / 5) as 判斷是否假日

from [innovator].[IN_TIMERECORD] as 工時紀錄表
left join [innovator].[IDENTITY] as 角色 on 工時紀錄表.OWNED_BY_ID =角色.ID

where 角色.name ='0013 蔡慶龍'
