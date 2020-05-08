/*****************************************************************************************
Name: QBRSCIReportBatchScheduler
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to schedule and run QBRSCIReportBatch 
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     12-Jun-2017      Initial Development
******************************************************************************************/
global class QBRSCIReportBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        QBRSCIReportBatch b = new QBRSCIReportBatch();
        database.executebatch(b);
    }
}