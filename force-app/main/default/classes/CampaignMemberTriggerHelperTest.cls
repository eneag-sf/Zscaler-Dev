@isTest
public class CampaignMemberTriggerHelperTest {

    public static testMethod void testUpdate()
    {   
    List<ZscalerSetting__c> ZscalerSettinglist= new List<ZscalerSetting__c>();
        ZscalerSetting__c Zsc1= new ZscalerSetting__c(Name='CampaignExceptions1',Value__c='ABC');
        ZscalerSettinglist.add(Zsc1);
        ZscalerSetting__c Zsc2= new ZscalerSetting__c(Name='CampaignExceptions2',Value__c='DEF');
        ZscalerSettinglist.add(Zsc2);
        Insert ZscalerSettinglist;
        
        Account acctTest = new Account(Name = 'Test Account', TAM_Email__c = 'abc@abc.com');
        insert acctTest;
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        
        Contact con = new Contact(AccountId = acctTest.Id, LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        
        List<Campaign> CmpgnList= new List<Campaign>();
        Campaign cm = new Campaign();
        cm.name='ZPA Interactive';
        cm.Department__c = '5000-Corporate Marketing';
        cm.Geo__c = 'GLOBAL';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today()+30;
        cm.Fiscal_Year__c = 'All Time';
        cm.Type = 'Default';
        cm.Campaign_Type__c = 'Assets';
        cm.Activity_Details__c = 'ebook';
        
        CmpgnList.add(cm);
        
        /* Campaign cm2 = new Campaign();
        cm2.name='ZPA Interactive';
        cm2.Department__c = '5000-Corporate Marketing';
        cm2.Geo__c = 'GLOBAL';
        cm2.StartDate = Date.today();
        cm2.EndDate = Date.today()+30;
        cm2.Fiscal_Year__c = 'All Time';
        cm2.Type = 'Default';
        cm2.Campaign_Type__c = 'Assets';
        cm2.Activity_Details__c = 'ebook';
        
        CmpgnList.add(cm2); */
        
        insert CmpgnList;
        
        List<CampaignMember> CmpgnMemList= new List<CampaignMember>();
        CampaignMember CM2= new CampaignMember(Campaignid=cm.id,Leadid=lead.id,Status='Sent');
        CmpgnMemList.add(CM2);
        CampaignMember CM1= new CampaignMember(Campaignid=cm.id,Contactid=con.id,Status='Sent');
        CmpgnMemList.add(CM1);      
        Test.startTest();
        insert CmpgnMemList;
        CampaignMemberTriggerHelper.updateLeadContactForCamp(CmpgnMemList);
        CampaignMemberTriggerHelper.createZPAProvisioningRequest(CmpgnMemList);
        Map<Id,String> LeadTerritory= new Map<Id,String>();
        LeadTerritory.put(lead.id,'ABC test');
        CampaignMemberTriggerHelper.createCase(CmpgnMemList,LeadTerritory);
        Test.stopTest();
        
    }
}