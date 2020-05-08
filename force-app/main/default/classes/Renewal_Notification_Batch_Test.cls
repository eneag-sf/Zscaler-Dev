@isTest
public class Renewal_Notification_Batch_Test{
    static testmethod void test1(){
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
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',
                            CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf', Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), contract_end_date_new__c = date.today().adddays(65));
        insert opp;
        
        opp.Contract_End_Date_New__c = date.today().adddays(60);
        update opp;
        
        Renewal_Notification_Batch batch;
        batch = new Renewal_Notification_Batch ();
        batch.errorlst.add('abc');
        Database.executeBatch(batch,1);
        
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
       Product2 productSO = new Product2();
       productSO.Name = ProductName;
       productSO.Family = pfamily;
       productSO.ProductCode = pcode;
       productSO.IsActive = true;
       productSO.Apttus_Config2__ConfigurationType__c = sConfigType;
       productSO.Apttus_Config2__HasAttributes__c = false;
       productSO.Apttus_Config2__HasOptions__c = false;
       return productSO;
   }

}