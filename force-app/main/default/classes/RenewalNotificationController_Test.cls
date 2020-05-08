@isTest
public class RenewalNotificationController_Test{
    static testmethod void test1(){
        Test.startTest();
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
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = OppStage1 /*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.Contract_End_Date_New__c = date.today().adddays(60);
        update opp;
        
        RenewalNotificationController ctrl = new RenewalNotificationController();
        system.debug(ctrl.additionalemailtoTerminate);
        system.debug(ctrl.pastdueTemplateId);
        system.debug(ctrl.futurenotificationTemplateId);
        system.debug(ctrl.terminationTemplateId);
        system.debug(ctrl.getGeoAndRepPicklistValues());
        system.debug(ctrl.opportunityList );
        system.debug(ctrl.RenewalRecipientList  );
        system.debug(ctrl.NonRenewalRecipientList  );
        ctrl.getDaysPastDueVals();
        ctrl.getNumberofExtensionsVals();
        ctrl.ContactAddtionaccId = account.Id;
        ctrl.ContactAddtionoppId = opp.Id;
        try{
        ctrl.getcontactlists();
        }catch(Exception ex){}
        ctrl.oppIdtoSave = opp.Id;
        ctrl.ContactAddtionoppId = opp.Id;
        ctrl.saveoppty();
        ctrl.savecontacts();
        system.debug(ctrl.opportunityList );
        ctrl.ContactAddtionoppId = opp.Id;
        try{
        ctrl.showNewExtensionrequestCreation();
        }catch(Exception ex){
        
        }
        try{
        ctrl.createAndAddExtension();
        }catch(Exception ex){
        
        }
        ctrl.cancelExtensionpopup();
        ctrl.closepopup();
        ctrl.showNewContactPopup();
        ctrl.createAndAddContact();
        try{
        ctrl.cancelPopup();
        }catch(Exception ex){}
        ctrl.showEditOppPopup();
        
        opp.Primary_Reason_For_Loss__c = 'Price - Price was too high';
        opp.Secondary_Reason_For_Loss__c = 'No Secondary Reason';
        opp.Deal_Lost_To__c = 'Don\'t Know';
        RenewalNotificationController.terminateOppty(opp.Id, 'Price - Price was too high', 'No Secondary Reason', 'Don\'t Know', '');
        ctrl.cancelOpptyPopup();
        ctrl.getstatus();
        Test.stopTest();
        
    }
}