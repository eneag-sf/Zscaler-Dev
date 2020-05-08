@istest
public class UpdateLeadStageToSAL_Test{
    public static testmethod void updateleadstagetoSALtest(){
        Profile p = [Select Id from Profile where Name = 'System Administrator' limit 1];
        User u1 = new User(ProfileId = p.Id,LastName = 'Test user', Email = 'testuser@zscaler.com', UserName = 'testuser@zscaler.com', Department = 'demand generation',
        TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                           Alias = 'jliv');
        insert u1;
		
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

        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0);
        insert lead;
        Contact con = new Contact(LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        System.runAs(u1){
        Task t1 = new Task(WhoId = lead.Id,Call_Disposition__c = 'meeting scheduled');
        Task t2 = new Task(WhoId = con.Id,Call_Disposition__c = 'meeting scheduled');
        List<Task> tsklst = new List<Task>();
        tsklst.add(t1);
        tsklst.add(t2);
        insert tsklst;
        UpdateLeadStageToSAL.updateLeadStageToSAL(new List<ID>{t1.Id, t2.Id});
        }
    }
}