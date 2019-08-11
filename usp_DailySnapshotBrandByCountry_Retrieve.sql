USE [CDM]
GO
/****** Object:  StoredProcedure [rpt].[usp_DailySnapshotBrandByCountry_Retrieve]    Script Date: 12/08/2019 9:06:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----SUMMARY TABLIX 2 & 5
----EXEC [rpt].[usp_DailySnapshotBrandByCountry_Retrieve] '1 - Cottonon','13 - Menswear' 
----EXEC [rpt].[usp_DailySnapshotBrandByCountry_Retrieve] '1 - Cottonon',NULL 
----EXEC [rpt].[usp_DailySnapshotBrandByCountry_Retrieve] NULL,NULL,NULL 
ALTER PROCEDURE [rpt].[usp_DailySnapshotBrandByCountry_Retrieve]
  @Division       VARCHAR(65) = NULL
 ,@Department     VARCHAR(65) = NULL
 ,@OnlineStoreLicenseeMega    VARCHAR(65) = NULL


AS
		
		 SELECT
		 [WeekDay]																									    AS 'Week_Day', 					
		 CASE WHEN T.Region = 'Middle East' THEN T.Region ELSE T.Country END											AS 'Country_Name',							
		 T.SnapshotChannel																								AS 'OnlineStoreLicenseeMega',
		 CASE T.SnapshotChannel  WHEN 'Store'  THEN 1  
							     WHEN 'Mega'   THEN 2  
								 WHEN 'Online' THEN 3  
								 ELSE 4
		 END 											                                                                AS 'SnapshotChannelOrder',																								
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [DaySalesThisYearAUD] ELSE 0 END) 											AS 'Sales_DailyA_Door',--
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [DaySalesLastYearAUD] ELSE 0 END) 											AS 'Sales_LY_DailyA_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDSalesThisYearAUD] ELSE 0 END) 											AS 'Sales_MTDA_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDSalesLastYearAUD] ELSE 0 END) 											AS 'Sales_LY_MTDA_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDBudgetSalesThisYearAUD] ELSE 0 END) 									AS 'Sales_MTDB_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDBudgetSalesLastYearAUD] ELSE 0 END) 									AS 'Sales_LY_MTDB_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [FullMonthSalesThisYearAUD] ELSE 0 END) 									AS 'Sales_FullMth_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [FullMonthBudgetSalesThisYearAUD] ELSE 0 END) 								AS 'Sales_FullMthB_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [FullMonthSalesLastYearAUD] ELSE 0 END) 									AS 'Sales_LY_FullMth_Door',--
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [FullMonthBudgetSalesLastYearAUD] ELSE 0 END) 								AS 'Sales_LY_FullMthB_Door',--

		 SUM([DaySalesThisYearAUD]) 																					AS 'Sales_DailyA',
		 SUM([MTDSalesThisYearAUD])																						AS 'Sales_MTDA', 
		 SUM([MTDBudgetSalesThisYearAUD])																				AS 'Sales_MTDB', 
		 SUM([FullMonthSalesThisYearAUD])																				AS 'Sales_FullMth',
		 SUM([FullMonthBudgetSalesThisYearAUD])																			AS 'Sales_FullMthB', 

		 SUM([DaySalesLastYearAUD]) 																					AS 'Sales_LY_DailyA',
		 SUM([MTDSalesLastYearAUD])																						AS 'Sales_LY_MTDA', 
		 SUM([MTDBudgetSalesLastYearAUD])																				AS 'Sales_LY_MTDB', 
		 SUM([FullMonthSalesLastYearAUD])																				AS 'Sales_LY_FullMth',
		 SUM([FullMonthBudgetSalesLastYearAUD])																			AS 'Sales_LY_FullMthB',

		 SUM([DayGrossProfitThisYearAUD]) 																				AS 'GPDollar_DailyA',
		 SUM([MTDGrossProfitThisYearAUD])																				AS 'GPDollar_MTDA', 
		 SUM([MTDBudgetGrossProfitThisYearAUD])																			AS 'GPDollar_MTDB', 
		 SUM([FullMonthBudgetGrossProfitThisYearAUD])																	AS 'GPDollar_FullMthB',

		 SUM(CASE WHEN DoorCompFlag = 1 THEN [DayGrossProfitThisYearAUD] ELSE 0 END) 									AS 'GrossProfit_DailyA_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [DayGrossProfitLastYearAUD] ELSE 0 END) 									AS 'GrossProfit_LY_DailyA_Door',
	 	 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDGrossProfitThisYearAUD] ELSE 0 END) 									AS 'GrossProfit_MTDA_Door',
		 SUM(CASE WHEN DoorCompFlag = 1 THEN [MTDGrossProfitLastYearAUD] ELSE 0 END) 									AS 'GrossProfit_LY_MTDA_Door'
		FROM [rpt].[ReportData] T
		WHERE 
					  (@Division	IS NULL OR		@Division =	T.Division)
				 AND  (@Department	IS NULL OR		@Department =	T.Department)
				 AND  (@OnlineStoreLicenseeMega IS NULL OR    @OnlineStoreLicenseeMega  = T.SnapshotChannel)
				 AND  T.Division NOT IN ('9 - Foundation','11 - Community')
				 
		GROUP BY [WeekDay],
				 CASE WHEN T.Region = 'Middle East' THEN T.Region ELSE T.Country END, 	
				 T.SnapshotChannel
