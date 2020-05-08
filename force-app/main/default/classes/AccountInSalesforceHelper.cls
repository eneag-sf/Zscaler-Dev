public with sharing class AccountInSalesforceHelper 
{
	public static List < UserRecordAccess> getAccessRecords(List<string> accidList)
    {
        return [SELECT RecordId,HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId IN : accidList Limit 200];
    }
        
}