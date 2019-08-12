-- =============================================
-- Author:		Avanade
-- Create date: 01-01-2019
-- Description:	Retrieve data from FACTSALES for use in Daily Snapshot Online Summary
-- 
-- Edit History
-- Date 			Author 				Changes
-- 08/08/19 		Jaymes Cotter 		Adding new returnable fields containing LY Local Sales @ Current AUD FX Rate in order to correctly calculate Comps and GP. 
-- =============================================

USE [CDM]
GO
/****** Object:  StoredProcedure [rpt].[usp_DailySnapshotOnline_Retrieve]    Script Date: 9/08/2019 11:16:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************												
** Name: [rpt].[usp_DailySnapshotOnline_Retrieve] 												
** Description: This Stored Procedure is used to retrieve Daily Snapshot Online group by division and country.
**												
** Change History												
**												
** Date        Author                 Description 	
  2019/04/25   Khalid Mangondato	  Initial Version
  2019/06/07   Jayroll Parreno   	  Sprint 14 PBI [Technical] Refactor code on Daily Snapshot Online report for performance.   

  EXEC [rpt].[usp_DailySnapshotOnline_Retrieve] 
********************************************************************************************************************/		
ALTER PROCEDURE [rpt].[usp_DailySnapshotOnline_Retrieve]
AS

DECLARE @WEEKDAY VARCHAR(20) 
SELECT TOP 1 @WEEKDAY = CAST(DD.WeekNumberOfTradeMonth AS VARCHAR(5)) + '/' +  CAST(dd.WeekdayNumber AS VARCHAR(5))
FROM [DWH].[DimDate] DD
WHERE YesterdayFlag = 1

DECLARE @OtherDept TABLE(OtherDepartment VARCHAR(50))
INSERT INTO @OtherDept
SELECT DISTINCT Department
FROM [dwh].[DimMerch] WHERE DivisionCode = 9 AND DepartmentCode != 91 --Foundation


;WITH CTE_DailySnapshotOnline AS (
SELECT 
@WEEKDAY																												AS 'WeekDay',
T.Country																										        AS 'Country',
REPLACE(T.Division,'Other','Foundation')																				AS 'Division',
SUM(DaySalesThisYearAUD)																								AS 'ThisYearDaySalesAUD',  --DS, DS var LWDS
SUM(SDLWSalesThisYearAUD)										                                                     	AS 'ThisYearSameDayLastWeekAUD', --SDLW,  DS var LWDS
SUM(CASE WHEN DoorCompFlag = 1 THEN [DaySalesThisYearAUD] ELSE 0 END)													AS 'ThisYearDaySalesAUDComp', --DC
SUM(CASE WHEN DoorCompFlag = 1 THEN [DaySalesLastYearAUD] ELSE 0 END)                           						AS 'LastYearDaySalesAUDComp', --DC
SUM(CASE WHEN DivisionCompFlag = 1 THEN [DaySalesThisYearAUD] ELSE 0 END)												AS 'ThisYearDaySalesAUDCompDiv', --DC
SUM(CASE WHEN DivisionCompFlag = 1 THEN [DaySalesLastYearAUD] ELSE 0 END)												AS 'LastYearDaySalesAUDCompDiv', --DC
SUM(WTDSalesThisYearAUD)			                                       								                AS 'ThisYearWeekToDateSaleAUD',  --WTD TW, WTD Comp to Bud
SUM(LWTDSalesThisYearAUD)																								AS 'ThisYearLastWeekToDateSaleAUD', --WTD LW
SUM(CASE WHEN DoorCompFlag		= 1 THEN WTDSalesThisYearAUD ELSE 0 END)												AS 'ThisYearWeekToDateSaleAUDComp', --WTD Comp
SUM(CASE WHEN DoorCompFlag		= 1 THEN WTDSalesLastYearAUD ELSE 0 END)												AS 'LastYearWeekToDateSaleAUDComp', --WTD Comp
SUM(CASE WHEN DivisionCompFlag  = 1 THEN WTDSalesThisYearAUD ELSE 0 END)												AS 'ThisYearWeekToDateSaleAUDCompDiv', --WTD Comp
SUM(CASE WHEN DivisionCompFlag  = 1 THEN WTDSalesLastYearAUD ELSE 0 END)												AS 'LastYearWeekToDateSaleAUDCompDiv', --WTD Comp
SUM(WTDBudgetSalesThisYearAUD)											                                                AS 'ThisYearWeekToDateBudgetAUD', --WTD Comp to Bud
SUM(MTDBudgetSalesThisYearAUD)																					        AS 'ThisYearMonthToDateBudgetAUD', --
SUM(MTDSalesThisYearAUD)																								AS 'ThisYearMonthToDateSaleAUD', --MTD
SUM(MTDSalesLastYearAUD)																								AS 'LastYearMonthToDateSaleAUD', --MTD
SUM(CASE WHEN DoorCompFlag       = 1 THEN MTDSalesThisYearAUD ELSE 0 END)						                        AS 'ThisYearMonthToDateSaleAUDComp', --MTD
SUM(CASE WHEN DoorCompFlag       = 1 THEN MTDSalesLastYearAUD ELSE 0 END)						                        AS 'LastYearMonthToDateSaleAUDComp', --MTD
SUM(CASE WHEN DivisionCompFlag   = 1 THEN MTDSalesThisYearAUD ELSE 0 END)					                            AS 'ThisYearMonthToDateSaleAUDCompDiv', --MTD
SUM(CASE WHEN DivisionCompFlag   = 1 THEN MTDSalesLastYearAUD ELSE 0 END)					                            AS 'LastYearMonthToDateSaleAUDCompDiv', --MTD
SUM(MTDGrossProfitThisYearAUD)																						    AS 'ThisYearMonthToDateGrossProfitAUD',
SUM(MTDTransactionCountThisYear)																						AS 'ThisYearMonthToDateTxnCount'--,

/* NEW */
-- SUM(CASE WHEN DoorCompFlag = 1 THEN [DaySalesLastYearCompAUD] ELSE 0 END)                           							AS 'LastYearDaySalesAUDComp', --DC
-- SUM(CASE WHEN DivisionCompFlag = 1 THEN [DaySalesLastYearCompAUD] ELSE 0 END)												AS 'LastYearDaySalesAUDCompDiv', --DC
-- SUM(CASE WHEN DoorCompFlag		= 1 THEN WTDSalesLastYearCompAUD ELSE 0 END)												AS 'LastYearWeekToDateSaleAUDComp', --WTD Comp
-- SUM(CASE WHEN DivisionCompFlag  = 1 THEN WTDSalesLastYearCompAUD ELSE 0 END)													AS 'LastYearWeekToDateSaleAUDCompDiv', --WTD Comp
-- SUM(MTDSalesLastYearCompAUD)																									AS 'LastYearMonthToDateSaleAUD', --MTD
-- SUM(CASE WHEN DoorCompFlag       = 1 THEN MTDSalesLastYearCompAUD ELSE 0 END)						                        AS 'LastYearMonthToDateSaleAUDComp', --MTD
-- SUM(CASE WHEN DivisionCompFlag   = 1 THEN MTDSalesLastYearCompAUD ELSE 0 END)					                            AS 'LastYearMonthToDateSaleAUDCompDiv' --MTD																						    AS 'ThisYearMonthToDateGrossProfitAUD',

-- Rename the above AS names, or will they just end up replacing the existing ones with the new/correct numbers?

FROM [rpt].[ReportData] T
LEFT JOIN @OtherDept od
	ON T.Department = od.OtherDepartment
WHERE T.SnapshotChannel = 'Online' AND T.StoreModel = 'Online'
AND T.DivisionCode != '11' --Community
AND od.OtherDepartment IS NULL
GROUP BY 
T.Country,																					
REPLACE(T.Division,'Other','Foundation'))

SELECT 
*,
CAST(LEFT(Division, CHARINDEX('-',Division)-1) AS INT)																	AS 'DivisionCode'
FROM CTE_DailySnapshotOnline
