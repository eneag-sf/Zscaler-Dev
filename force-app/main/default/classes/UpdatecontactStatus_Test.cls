@isTest
public class UpdatecontactStatus_Test{
    public static testmethod void testconstatus(){
		
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

        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', First_Lead_Date__c = date.today(), Company = 'Test Lead Company', Status = 'Inquiry',Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0,LeadSource = 'Marketing Campaign');
        insert lead;
        Contact con = new Contact(converted_Lead_Id__c = String.valueof(lead.id).substring(0,15),LeadSource = 'Marketing Campaign', LastName = 'test con', First_Lead_Date__c = date.today(), Lead_Stage__c = 'Lead', MKTO71_Lead_Score__c = 0, Contacts_That_Matter__c  = true);
        insert con;
        UpdatecontactStatus.updateContactStatus(new List<Id>{lead.Id});
    }
}