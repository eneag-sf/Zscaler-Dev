@isTest
public class MasterCaseFlow_Test{
    

    @testSetup static void setupdata(){
    List<Triggers_Switch__c> tslist= new List<Triggers_Switch__c>();
    Triggers_Switch__c ts1= new Triggers_Switch__c(Name='Execute_FeedItem_Trigger',Execute__c=true,Object_Name__c='FeedItem');
    tslist.add(ts1);
    insert tslist;
    
    List<Account>  CreateAccounts= new List<Account>(); 
        Integer numAccts=1;
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i,Type='Customer',Domain__c='TestAccount'+i+'.com',Current_ARR__c=5);
            CreateAccounts.add(a);
        }
        insert CreateAccounts;
    }
    @istest static void TestMethodd1(){
        List<Contact> CntctList= new List<Contact>();
        List<Case> caselist= new List<Case>();
        List<id> Caseidlist= new List<id>();
        
        Account Acc= [Select id,domain__c from Account Limit 1];
        
        Contact Con= new Contact(Accountid=Acc.id,FirstName='Test',LastName='Con1',email='TestCon1@'+acc.domain__c,Head_of_It__c=true,ZPA_Interactive_Prospect__c=true);
        CntctList.add(Con);
        Contact Con2= new Contact(Accountid=Acc.id,FirstName='Test',LastName='Con1',email='TestCon1@'+acc.domain__c,Head_of_Networking__c=true,Head_of_Security__c=true,ZPA_Interactive_Prospect__c=false);
        CntctList.add(Con2);
		ContactTriggerHelper.skipTrigger = true;
		TriggerUtility.realignPatch();
        insert CntctList;
        
        id MstrCaserecordid= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master Case').getRecordTypeId();
        id Supportrecordid= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
                
        Case c1= new Case(Accountid=Acc.id,Contactid=CntctList[0].id,recordtypeid=MstrCaserecordid,Origin='Internal Agent',Status='New',Share_with_Customer__c='Yes',Push_comment_to_child_cases__c='No');
        //caselist.add(c1);
        //insert caselist;
        insert c1;
        
        Case c2= new Case(Accountid=Acc.id,Contactid=CntctList[0].id,recordtypeid=MstrCaserecordid,Origin='Internal Agent',Status='New',Master_case__c=c1.id);
        insert c2;
        
        Caseidlist.add(c1.id);
        
        MasterCaseFlow.saveCaseComment(c1.id,'Yes','No','Test comments',false,null);
        
        SendEmailstoCustomers Q2= new SendEmailstoCustomers(c1.id,'Test comments');
        ID jobID = System.enqueueJob(Q2);
        
        UpdateMasterCaseKeyfields Q3= new UpdateMasterCaseKeyfields (Caseidlist);
        System.enqueueJob(Q3);
                    
    }
}