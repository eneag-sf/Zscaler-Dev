@isTest
private class UpdateLeadStageToSQLBatchTest {
    private static Lead lead { get; set; }
    private static Contact contact { get; set; }
    public static Account acc { get; set; }

    static {
        ZscalerSetting__c zs = new ZscalerSetting__c();
         zs.Name = 'CampaignExceptions1';
         zs.Value__c = '70170000000cGzmAAE';
         insert zs;

        ZscalerSetting__c zs1 = new ZscalerSetting__c();
         zs1.Name = 'CampaignExceptions2';
         zs1.Value__c = '70170000000cGzmAAE';
         insert zs1;
        
        List<OnOffSwitch__c>  OnOfflist= new List<OnOffSwitch__c>();
        OnOffSwitch__c zcs1= new OnOffSwitch__c();
        zcs1.name='updateContactStatus';
        zcs1.Deactivate_Component__c=false;
        OnOfflist.add(zcs1);

        OnOffSwitch__c zcs2= new OnOffSwitch__c();
        zcs2.name='UpdateLeadLeadStage';
        zcs2.Deactivate_Component__c=false;
        OnOfflist.add(zcs2);

        OnOffSwitch__c zcs3= new OnOffSwitch__c();
        zcs3.name='updateLeadStageToSAL';
        zcs3.Deactivate_Component__c=false;
        OnOfflist.add(zcs3); 

        OnOffSwitch__c zcs4= new OnOffSwitch__c();
        zcs4.name='UpdateLeadStageToSQLBatch';
        zcs4.Deactivate_Component__c=false;
        OnOfflist.add(zcs4);
        insert OnOfflist;
        
        lead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'SAL');
        insert lead;

        acc = new Account(Name = 'Test Account', APTS_Platform_Subscription_End_Date__c = Date.today().addDays(5000));
        insert acc;

        contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert contact;

        Opportunity oppty = new Opportunity(Name = 'Test Oppty for SQL', AccountId = acc.Id, Amount = 10000, CloseDate = Date.today().addDays(10), StageName = label.Stage_4_Economic_Buyer_Signoff /*'8 - Expecting Order'*/);
        insert oppty;

        OpportunityContactRole ocr = new OpportunityContactRole(
                                            ContactId = contact.Id,
                                            OpportunityId = oppty.Id,
                                            Role = 'Change Agent'
                                        );
        insert ocr;
    }

    @isTest static void testSQLBatch() {
        Test.startTest();
        Datetime today = Datetime.now().addDays(1);
        Datetime yesterday = Datetime.now().addDays(-1);
        String startDate = yesterday.format('yyyy') + '-' + yesterday.format('MM') + '-' + yesterday.format('dd') + 'T00:00:00Z';
        String endDate = today.format('yyyy') + '-' + today.format('MM') + '-' + today.format('dd') + 'T11:59:59Z';
        UpdateLeadStageToSQLBatch b = new UpdateLeadStageToSQLBatch(startDate, endDate);
        Database.executeBatch(b);
        Test.stopTest();

    }

}