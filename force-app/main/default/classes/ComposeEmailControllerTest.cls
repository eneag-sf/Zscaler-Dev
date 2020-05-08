@isTest
public class ComposeEmailControllerTest {
   
     static testmethod void test1(){
        
        Test.startTest();
        
        List<OrgWideEmailAddress> orgEmails = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Zscaler Support'  limit 1];
        Map<Object, Object> objMAP = new  Map<Object, Object>();
        objMAP.put('fromAddress','cszdfsdf');
        objMAP.put('toAddress','tset@testmail.com;test1@testmail.com');
        objMAP.put('ccAddress','tset@testmail.com;test1@testmail.com');
        objMAP.put('bccAddress','tset@testmail.com;test1@testmail.com');
        objMAP.put('additionalTo','tset@testmail.com;test1@testmail.com');
        objMAP.put('subject','test');
        objMAP.put('emailBody','test ssdsd');
        
         list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Subscription_Termination'];
        
        try{
            ComposeEmailController.sendEmail(objMAP);
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
        insert con1;
        Contact con2 = new Contact();
        con2.FirstName = 'Test4';
        con2.LastName = 'Test4';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        insert con2;

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
        
        Test.startTest();
        
        List<OrgWideEmailAddress> orgEmails = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Zscaler Support'  limit 1];
        Map<Object, Object> objMAP = new  Map<Object, Object>();
        objMAP.put('fromAddress',orgEmails[0].Id);
        objMAP.put('toAddress','tset@testmail.com,test1@testmail.com');
        objMAP.put('ccAddress','tset@testmail.com,test1@testmail.com');
        objMAP.put('bccAddress','tset@testmail.com,test1@testmail.com');
        objMAP.put('additionalTo','tset@testmail.com,test1@testmail.com');
        objMAP.put('subject','test');
        objMAP.put('emailBody','test ssdsd');
        
         list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Subscription_Termination'];
        
        try{
            ComposeEmailController.getOrgWideId();
            ComposeEmailController.sendEmail(objMAP);
           	ComposeEmailController.getTemplateBody(etlst[0].id,opp.id);
        }catch(Exception ex){      
        }
        Test.stopTest();
        
    }
}