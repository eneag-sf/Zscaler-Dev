@isTest
private class UpdateLeadLeadStageTest {
    private static Lead lead { get; set; }
    private static Patch__c patch { get; set; }

    static {
        ZscalerSetting__c setting = new ZscalerSetting__c(Name='CampaginExceptions', Value__c='70170000000cGzmAAE');
        insert setting;
		
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

        Campaign leadCampaign = new Campaign(
                                    Name = 'Lead Campaign Test',
                                    IsActive = true
                                );
        insert leadCampaign;

        Lead_Lifecycle_Campaigns__c orgDefaultSetting = new Lead_Lifecycle_Campaigns__c(SetupOwnerId=UserInfo.getOrganizationId(), Lead_Campaign_Id__c=leadCampaign.Id);
        insert orgDefaultSetting;

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'US North Central';
        amerPatchTeam1.Region__c = 'US Central';
        amerPatchTeam1.Territory_Type__c = 'General Business';
        amerPatchTeam1.Theater__c = 'AMERICAS';
        insert amerPatchTeam1;

        patch  = new Patch__c();
        patch.Active__c = true;
        patch.PatchTeam__c = amerPatchTeam1.Id ;
        patch.PatchName__c = 'Test Patch';
        insert patch;

        lead = new Lead(FirstName = 'Test', LeadSource = 'Marketing Campaign' , LastName = 'Lead', Company = 'Test Lead Company', Status = 'Inquiry', Lead_Stage__c = '', MKTO71_Lead_Score__c = 0);
        insert lead;
    }

    @isTest static void testUpdateLeadLeadStage() {
        lead.MKTO71_Lead_Score__c = 10;
        lead.Patch__c = patch.Id;
        update lead;
        UpdateLeadLeadStage.updateLeadLeadStage(new List<Id>{lead.Id});
    }
}