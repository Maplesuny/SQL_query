SELECT 
	員工工時卡.IN_USERNO as 員工編號 ,
	角色.NAME as 實際員工,
	部門.NAME as 部門,
	管理者.NAME as 管理者,
	專案.NAME as 專案名稱,
	工時紀錄表.SA_TASKCLASS as 任務分類,
	工時紀錄表.SA_WORK_HOURS as 工時,
	--子查詢
	--(select COUNT(專案.OWNED_BY_ID) from [innovator].[PROJECT] as 專案 where 專案.OWNED_BY_ID =角色.ID) as 專案個數,
	(select SUM(工時紀錄表.SA_WORK_HOURS) from [innovator].[IN_TIMERECORD] as 工時紀錄表 where 工時紀錄表.OWNED_BY_ID =角色.ID)as 報工總時數,
	 ddd.分類時數,
	 CC.專案總數
from [innovator].[IN_TIMERECORD] as 工時紀錄表
left join [innovator].[IDENTITY] as 角色 on 工時紀錄表.OWNED_BY_ID = 角色.ID
left join [innovator].[IDENTITY] as 部門 on 角色.IN_DEPT = 部門.ID 
left join [innovator].[IN_PERLWORKRECORD] as 員工工時卡 on 工時紀錄表.OWNED_BY_ID = 員工工時卡.OWNED_BY_ID
left join [innovator].[IDENTITY] as 管理者 on 員工工時卡.MANAGED_BY_ID = 管理者.ID
LEFT JOIN
  (SELECT sum(工時紀錄表.SA_WORK_HOURS)AS 分類時數,
          工時紀錄表.OWNED_BY_ID,
          工時紀錄表.SA_TASKCLASS AS CLASS
   FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
   WHERE 工時紀錄表.SA_TASKCLASS = 工時紀錄表.SA_TASKCLASS
   GROUP BY 工時紀錄表.OWNED_BY_ID,
            工時紀錄表.SA_TASKCLASS)AS ddd ON 工時紀錄表.OWNED_BY_ID =ddd.OWNED_BY_ID
											  AND ddd.CLASS = 工時紀錄表.SA_TASKCLASS
--去project找誰創專案
LEFT JOIN [innovator].[PROJECT] as 專案 on 工時紀錄表.IN_PROJECT = 專案.ID
LEFT JOIN (
	SELECT SUM(BB.計算數量) AS 專案總數,
	BB.NAME
		FROM[innovator].[IN_TIMERECORD] AS 工時紀錄表
		LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID = 角色.ID,
		(
		SELECT 角色.NAME,
		專案.NAME AS 專案名稱,
		工時紀錄表.IN_PROJECT,
		COUNT(專案.NAME) AS 計算數量

		FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
		LEFT JOIN [innovator].[PROJECT] AS 專案 ON 工時紀錄表.IN_PROJECT = 專案.ID
		LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID = 角色.ID
		AND 專案.NAME IS NOT NULL
		GROUP BY 專案.NAME,角色.NAME,工時紀錄表.IN_PROJECT
		) AS BB
		WHERE BB.IN_PROJECT = 工時紀錄表.IN_PROJECT AND BB.NAME = 角色.NAME
		GROUP BY BB.NAME
)CC ON 角色.NAME = CC.NAME

where 角色.NAME ='0013 蔡慶龍' 
