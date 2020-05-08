public with sharing class customLookUpClass {
    
    /**
    	Updated BY : Sateesh U 
    	To Display the selected Look up results on lightning component.
    **/
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String partnerType) {
        //system.debug('ObjectName-->' + ObjectName);
        String sQuery;
        String searchKey = searchKeyWord + '%';
        List <sObject> returnList = new List <sObject>();
        //Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        if(partnerType == 'Tech Partner'){
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Technology Partner\' order by createdDate DESC limit 10';
        }
        else{
            sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey and Type = \'Partner\' order by createdDate DESC limit 10';
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}