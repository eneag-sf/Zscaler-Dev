@isTest
public class UpdateCampaignTypeTest {

    public static testMethod void testUpdate()
    {
        Campaign cm = new Campaign();
        cm.name='Test';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Assets';
        cm.Activity_Details__c = 'ebook';
        
        insert cm;
        
        List<Id> cmIds = new List<Id>();
        cmIds.add(cm.Id);
        Test.startTest();
        UpdateCampaignType.updateCampaigns(cmIds);
        Test.stopTest();
        
    }
}