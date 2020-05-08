/*****************************************************************************************
Name: ProjectControllerTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test class for ProjectTriggerHandler Apex Class.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Pankaj Verma           18-12-2019    Initial Development
******************************************************************************************/ 


@isTest(SeeAllData=false)
private class ProjectHandlerTest{
    @isTest(SeeAllData=false)
     static void testCreateInspireProject(){
     Account a = new Account(Name='TEST-Z');
     insert a;
     Inspire1__Project__c IP = new Inspire1__Project__c();
         IP.inspire1__Account__c=a.ID;
         IP.inspire1__Project_Status__c='In Progress';
        
     test.startTest();
         insert IP;
     test.stopTest();
    }
     @isTest(SeeAllData=false)
    static void testupdateInspireProject(){
     Account a = new Account(Name='TEST-Z');
         insert a;
     Inspire1__Project__c IP = new Inspire1__Project__c();
         IP.inspire1__Account__c=a.ID;
         IP.inspire1__Project_Status__c='In Progress';
        insert IP;
        IP.Region__c='Transformation';
     test.startTest();
         update IP;
     test.stopTest();
    }
     @isTest(SeeAllData=false)
     static void testbulkupdateInspireProject(){
         list<Inspire1__Project__c> IPList= new List<Inspire1__Project__c>();
          list<Inspire1__Project__c> IPListUpdate= new List<Inspire1__Project__c>();
     Account a = new Account(Name='TEST-Z');
          insert a;
         for(integer i=1;i<=100;i++){
         Inspire1__Project__c IP = new Inspire1__Project__c();
         IP.inspire1__Account__c=a.ID;
         IP.inspire1__Project_Status__c='In Progress';
         IPList.add(Ip);
         }
        if(!IPList.isempty())
          insert IPList;
        
     test.startTest();
          for(Inspire1__Project__c IP : IPList)
          {
              IP.Region__c='Transformation';
              IPListUpdate.add(Ip);
          }
         if(!IPListUpdate.isEmpty())
         update IPListUpdate;
     test.stopTest();
    }
    
    
}