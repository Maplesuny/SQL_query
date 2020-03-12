SELECT 專案.NAME AS 專案名稱,
       部門.NAME AS 部門,
       (角色.NAME +' ' +'總工時:' + 
       convert(varchar, (SELECT SUM(工時紀錄表.SA_WORK_HOURS)
                          FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
                          WHERE 工時紀錄表.OWNED_BY_ID =角色.ID))) AS 報工者,
       convert(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111) AS 報工日期,
       (SELECT SUM(工時紀錄表.SA_WORK_HOURS)   
       	FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
       	WHERE 工時紀錄表.OWNED_BY_ID =角色.ID)AS 報工總時數,
       工時紀錄表.sa_taskclass AS 任務分類,
       客戶.IN_NAME_F AS 客戶名稱,
       團隊.NAME AS 團隊,
       工時紀錄表.SA_WORK_HOURS AS 工時,
       工時紀錄表.sa_start_time_h AS 報工開始時,
  --先轉換小數點之後再換成整數
  	(SELECT Convert(int,CONVERT(decimal(18,1), 工時紀錄表.sa_start_time_m) *60)) AS 報工開始分,
    工時紀錄表.sa_end_time_h AS 報工結束時,
	(SELECT Convert(int,CONVERT(decimal(18,1), 工時紀錄表.sa_end_time_m) *60)) AS 報工結束分,
	工時紀錄表.SA_TRANSGOING AS '交通工具(去程)',
	工時紀錄表.sa_transreturn AS '交通工具(回程)',
	工時紀錄表.description AS 工作說明
FROM [innovator].[IN_TIMERECORD] AS 工時紀錄表
	LEFT JOIN [innovator].[IDENTITY] AS 角色 ON 工時紀錄表.OWNED_BY_ID =角色.ID
	LEFT JOIN [innovator].[IDENTITY] AS 部門 ON 角色.IN_DEPT = 部門.ID
	LEFT JOIN [innovator].[CUSTOMER] AS 客戶 ON 工時紀錄表.SA_CUSTOMER = 客戶.ID
	LEFT JOIN [innovator].[TEAM] AS 團隊 ON 工時紀錄表.TEAM_ID = 團隊.ID
	LEFT JOIN [innovator].[PROJECT] AS 專案 ON 工時紀錄表.in_project =專案.ID
WHERE 1=1
ORDER BY convert(varchar, SWITCHOFFSET(工時紀錄表.IN_START_TIME, '+08:00'), 111)
