@isTest
public class LWCRenewalNotificationControllerTest {
    static testmethod void test1(){
       
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CSM' LIMIT 1];
        user CSMUser = new User(LastName = 'Lastname3',
                                FirstName='Firstname3',
                                Alias = 'testc',
                                Email = 'dummy@dummy.com3',
                                Username = 'test3@asdf.com',
                                ProfileId = profileId.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'en_US',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'en_US',
                                Show_Rep_Filter_on_Renewal_Console__c = true,
                                GEO__c = 'Americas',
                                Upsell_Placeholder__c = false,
                                Department = 'Renewal'
                               );
        
        insert CSMUser;
        
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
            Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        
        string OppStage1 = Label.Stage_1_Alignment;
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', 
                                          AccountId = account.Id, StageName = OppStage1 , 
                                          SE_name__c = UserInfo.getUserId(),
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', 
                                          AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,
                                          Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf',
                                          Next_Steps__c  = 'fdsjsdk',
                                          Forecast_Category__c = 'Pipeline',
                                          Pricebook2ID=Test.getStandardPricebookId(), 
                                          contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.amount = 10000;
        opp.Contract_End_Date_New__c = date.today().adddays(60);
        update opp;
        
 
        Test.startTest();
        
        LWCRenewalNotificationController.additionalemailtoTerminate();
        LWCRenewalNotificationController.getTerminationTemplateId();
        LWCRenewalNotificationController.getPastdueTemplateId();
        LWCRenewalNotificationController.getFuturenotificationTemplateId();
        LWCRenewalNotificationController.getGeoAndRepPicklistValues();
        
        try{
            
            System.runAs(CSMUser) {
                String filter5 = '[{"fldorigin":"UpcomingRenewals","fieldName":"DB","fieldType":"PickList","fieldValue":"< $25K,$50K - $100K,$25K - $50K,$100K - $250K,$250K - $1M ","isRange":false,"isMulti":true}]';
                LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter5, 0, 'Upcoming Renewals');                    
            }
            
            String filter = '[{"fldorigin":"UpcomingRenewals","fieldName":"DB","fieldType":"PickList","fieldValue":"< $25K, ","isRange":false,"isMulti":true},{"fldorigin":"UpcomingRenewals","fieldName":"Renewal_Notification_Status_Formula__c","fieldType":"PickList","fieldValue":"Yes, ","isRange":false,"isMulti":true},{"fldorigin":"UpcomingRenewals","fieldName":"FC","fieldType":"PickList","fieldValue":"Pipeline, ","isRange":false,"isMulti":true}]';
            String filter0 = '[{"fldorigin":"UpcomingRenewals","fieldName":"DB","fieldType":"PickList","fieldValue":"< $25K,$50K - $100K,$25K - $50K,$100K - $250K,$250K - $1M ","isRange":false,"isMulti":true}]';
            String filter1 = '[{"fldorigin":"ManageExtentions","fieldName":"Past_Due_Notification_Status_Formula__c","fieldType":"PickList","fieldValue":"Yes, ","isRange":false,"isMulti":true},{"fldorigin":"ManageExtentions","fieldName":"DAYSDUE","fieldType":"PickList","fieldValue":"1-10,11-20,21-30,30+","isRange":false,"isMulti":true},{"fldorigin":"ManageExtentions","fieldName":"Next_Renewal_Notification_Date__c","fieldType":"Date","isMulti":false,"isRange":true,"valFrom":"2020-04-01","valTo":"2020-04-03"},{"fldorigin":"ManageExtentions","fieldName":"NOE","fieldType":"PickList","fieldValue":"1, ","isRange":false,"isMulti":true}]';
            String filter2 = '[{"fldorigin":"UpcomingRenewals","fieldName":"DB","fieldType":"PickList","fieldValue":"< $25K, ","isRange":false,"isMulti":true},{"fldorigin":"UpcomingRenewals","fieldName":"Renewal_Notification_Status_Formula__c","fieldType":"PickList","fieldValue":"Yes, ","isRange":false,"isMulti":true},{"fldorigin":"UpcomingRenewals","fieldName":"FC","fieldType":"PickList","fieldValue":"Pipeline, ","isRange":false,"isMulti":true},{"fldorigin":"UpcomingRenewals","fieldName":"Name_Search","fieldType":"Text","fieldValue":"Test","isRange":false,"isMulti":false}]';
            String filter3 = '[{"fldorigin":"UpcomingRenewals","fieldName":"Contract_End_Date_New__c","fieldType":"Date","isMulti":false,"isRange":true,"valFrom":"2020-04-01","valTo":"2020-04-04"}]';
            String filter4 = '[{"fldorigin":"ManageExtentions","fieldName":"Contract_End_Date_New__c","fieldType":"Date","isMulti":false,"isRange":true,"valFrom":"2020-04-01","valTo":"2020-04-04"}]';
            String filter6 = '[{"fldorigin":"ManageExtentions","fieldName":"Contract_End_Date_New__c","fieldType":"Date","isMulti":false,"isRange":true,"valFrom":"2020-04-01"}]';
            String filter7 = '[{"fldorigin":"ManageExtentions","fieldName":"Contract_End_Date_New__c","fieldType":"Date","isMulti":false,"isRange":true,"valTo":"2020-04-01"}]';
            
           	LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter, 0, 'Upcoming Renewals');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter0, 0, 'Upcoming Renewals');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter1, 0, 'ManageExtentions');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter2, 0, 'Upcoming Renewals');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter3, 0, 'Upcoming Renewals');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter4, 0, 'ManageExtentions');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter6, 0, 'Upcoming Renewals');
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter7, 0, 'Upcoming Renewals');
           
            LWCRenewalNotificationController.getOpportunityRecords('', 0, 'Manage Extentions');
            
            LWCRenewalNotificationController.updateOpportunityRecord(opp.id,'Name', 'Test opportunity1');
            LWCRenewalNotificationController.updateOpportunityRecord(opp.id,'Name1', 'Test opportunity1');
            
            LWCRenewalNotificationController.getFieldSetMember('Contract_Extension_Request__c','Contract_Extension_Creation_Renewal_Noti');
            
            LWCRenewalNotificationController.AddContactWrraper acw = LWCRenewalNotificationController.getcontactlist(opp,account.id,'Partner');
            LWCRenewalNotificationController.AddContactWrraper acw1 = LWCRenewalNotificationController.getcontactlist(opp,account.id,'Contact');
            
            
            LWCRenewalNotificationController.savecontacts( acw,  opp, 'Partner');
            LWCRenewalNotificationController.savecontacts( acw1,  opp, 'Contact');
            
            
            Contract_Extension_Request__c cer = new Contract_Extension_Request__c();
            cer.Opportunity__c = opp.Id;
            cer.Contract_Extension_Date__c = date.today().adddays(-1);
            LWCRenewalNotificationController.createAndAddExtension(opp,cer);
            
            cer = new Contract_Extension_Request__c();
            cer.Reason_for_Extension__c = 'Technical Issue';
            cer.Opportunity__c = opp.Id;
            cer.Contract_Extension_Date__c = date.today().adddays(5);
            LWCRenewalNotificationController.createAndAddExtension(opp,cer);
			
            
        }catch(Exception ex){
            
        }
      
        Test.stopTest();
        
    }
    
    
    
    
     static testmethod void test2(){
       
        
        Account account = new Account(Name = 'Test Account1');
        insert account;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test3';
        con1.LastName = 'Test3';
        con1.AccountId = account.Id;
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test4';
        con2.LastName = 'Test4';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
            Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        
        string OppStage1 = Label.Stage_1_Alignment;
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', 
                                          AccountId = account.Id, StageName = OppStage1 , 
                                          SE_name__c = UserInfo.getUserId(),
                                          NextStep = 'Test 1',
                                          CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', 
                                          AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true,
                                          Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf',
                                          Next_Steps__c  = 'fdsjsdk',
                                          Forecast_Category__c = 'Pipeline',
                                          Pricebook2ID=Test.getStandardPricebookId(), 
                                          contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.amount = 10000;
        opp.Contract_End_Date_New__c = date.today().adddays(60);
        update opp;
        
                
        opportunity op1 = [Select StageName,Amount,Renewal_Notification_Status_Formula__c,Forecast_Category__c,Contract_End_Date_New__c,Owner.Department,Owner.Upsell_Placeholder__c from opportunity where id = :opp.id];
        System.debug('---op1---'+op1);
        System.debug('---op1---'+op1.Owner.Upsell_Placeholder__c);
        System.debug('---op1---'+op1.Owner.Department);
        System.debug('---op1---'+op1.StageName);
         
       	
        Test.startTest();
        
        
        User u = [Select ID,Name,Department from User Where id = :UserInfo.getUserId()];
        System.debug('---u---'+u);
        u.Department = 'Renewal';
        update u;
                
        try{
            
            String filter = '[{"fldorigin":"UpcomingRenewals","fieldName":"DB","fieldType":"PickList","fieldValue":"< $25K,$50K - $100K,$25K - $50K,$100K - $250K,$250K - $1M ","isRange":false,"isMulti":true}]';
            LWCRenewalNotificationController.getOpportunityRecordsUnCached(filter, 0, 'Upcoming Renewals');
        }catch(Exception ex){      
        }
              
       
        Test.stopTest();
        
    }
}