@isTest
public class TemporaryAccountAccessController_Test {
    @testSetup static void setup() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Core Sales'];
        User u = new User(
            Alias = 'testu',
            Email = 'test@unitingambition.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles',
            ProfileId = p.Id,
            UserName='test@unitingambition.com'
        );
        INSERT u;
        
        PatchFieldMapping__c mapping = new PatchFieldMapping__c(Name='acme', Object__c='Lead', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping;
        PatchFieldMapping__c mapping2 = new PatchFieldMapping__c(Name='acme acc', Object__c='Account', Type__c='Field', Field__c='Name', Value__c='Company');
        insert mapping2;
        
        PatchTeam__c pateam = new PatchTeam__c();
        pateam.Name = 'patchteam';
        pateam.Theater__c='AMERICAS';
        pateam.Region__c ='US West';
        pateam.Area__c ='US South West';
        pateam.Territory_Type__c ='Channel';
        pateam.Area_Director__c = u.Id;
        insert pateam;
        PatchTeamMember__c member = new PatchTeamMember__c(PatchTeam__c=pateam.Id, Role__c='TBH Coverage', User__c=UserInfo.getUserId());
        insert member;
        
        Patch__c patch = new Patch__c(PatchName__c='acme', Active__c=true,PatchTeam__c=pateam.Id);
        insert patch;
        
        Account acc =new Account(Name='acme acc');
        Insert acc;
        acc.Patch__c = patch.Id;
        acc.PatchLocked__c = true;
        update acc;
        
        opportunity opp = new opportunity(Name = 'Test opportunity', Primary_Quote_Exception__c  = true, AccountId = acc.Id, StageName = label.Stage_1_Alignment, CloseDate = system.Today()+30);
        insert opp;
        
        AccountShare acctShr = new AccountShare();
        acctShr.UserOrGroupId = u.Id;
        acctShr.AccountId = acc.Id;
        acctShr.AccountAccessLevel = 'Edit';
        acctShr.OpportunityAccessLevel = 'Edit';
        acctShr.CaseAccessLevel = 'Edit';  
        insert acctShr;
        
        OpportunityTeamMember teamMember1 = new OpportunityTeamMember();
        teamMember1.OpportunityId = opp.Id;
        teamMember1.OpportunityAccessLevel = 'Edit';
        teamMember1.UserId = UserInfo.getUserId(); 
        teamMember1.TeamMemberRole = 'Vacation Coverage';
        insert teamMember1;
        
        ZscalerSetting__c Settings = new ZscalerSetting__c();
        Settings.Name = 'AMER Sales VP';
        Settings.Value__c = UserInfo.getUserId();
        insert Settings;
        
        Apttus_Proposal__Proposal__c Proposal = new Apttus_Proposal__Proposal__c();
        Proposal.Apttus_Proposal__Account__c = acc.Id;
        Proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        insert Proposal;
        
        Apttus_Proposal__Proposal__share PropShare = new Apttus_Proposal__Proposal__share();
        PropShare.ParentId = Proposal.Id;
        PropShare.UserOrGroupId = UserInfo.getUserId();
        PropShare.RowCause = 'Opportunity_Team__c';
        PropShare.AccessLevel = 'Edit';
        insert PropShare;
        
        Id VacationCoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Vacation Coverage').getRecordTypeId();
        Access_Request__c accessRequestRecord = new Access_Request__c();
        accessRequestRecord.Request_Type__c = 'Vacation Coverage';
        accessRequestRecord.Request_Status__c = 'Active';
        accessRequestRecord.Requested_For__c = u.Id;
        accessRequestRecord.Requested_To__c = UserInfo.getUserId();
        accessRequestRecord.RecordTypeId = VacationCoverageRecordTypeId;
        insert accessRequestRecord;
        
        Id TBH_CoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('TBH Coverage').getRecordTypeId();
        Access_Request__c accessRequestTBHRecord = new Access_Request__c();
        accessRequestTBHRecord.Request_Type__c = 'TBH Coverage';
        accessRequestTBHRecord.Request_Status__c = 'Active';
        accessRequestTBHRecord.Requested_To__c = UserInfo.getUserId();
        accessRequestTBHRecord.Requested_For__c = u.Id;
        accessRequestTBHRecord.Sales_Territory__c = pateam.Id;
        accessRequestTBHRecord.Object_Type__c = 'Sales Territory';
        accessRequestTBHRecord.RecordTypeId = TBH_CoverageRecordTypeId;
        insert accessRequestTBHRecord;
    }
    
    static testMethod void testmethod1(){
        test.startTest();
        user userCoreSales = [Select id from user where username = 'test@unitingambition.com'];
        PatchTeam__c patchTeamRecord = [Select id,Name from PatchTeam__c Where name='patchteam' limit 1];
        Access_Request__c TBHAccess = [Select id,Request_Type__c,Request_Status__c,Requested_To__c,Sales_Territory__c,Object_Type__c,Requested_For__c From Access_Request__c Where Request_Type__c ='TBH Coverage' Limit 1];
        Access_Request__c VacationAccess = [Select id,Request_Type__c,Request_Status__c,Requested_To__c,Sales_Territory__c,Object_Type__c,Requested_For__c From Access_Request__c Where Request_Type__c ='Vacation Coverage' Limit 1];
        //System.runAs(userCoreSales) {
        string coverageProfileName = TemporaryAccountAccessController.getCoverageAccessFromProfile();
        list<TemporaryAccountAccessController.picklistWrap> wrapList = TemporaryAccountAccessController.getAreaListWrap();
        list<TemporaryAccountAccessController.picklistWrap> territoryList = TemporaryAccountAccessController.getTerritorieWrap('US South West');
        list<TemporaryAccountAccessController.picklistWrap> managerList = TemporaryAccountAccessController.getManagerWrap();
        list<TemporaryAccountAccessController.picklistWrap> vacationManagerList = TemporaryAccountAccessController.getVacationManagerWrap();
        list<TemporaryAccountAccessController.picklistWrap> userManagerList = TemporaryAccountAccessController.getUserManagerWrap();
        string todayDateStr = Datetime.now().format('yyyy-MM-dd'); 
        TemporaryAccountAccessController.response responseResult = TemporaryAccountAccessController.TBHCoverageCreate('US South West',string.valueOf(patchTeamRecord.Id),'Patch',string.valueOf(userCoreSales.Id),'Test user',todayDateStr);
         List<TemporaryAccountAccessController.TBHCaseWrap> TBHCases = TemporaryAccountAccessController.getTBHCases(string.valueOf(userCoreSales.Id));
        List<TemporaryAccountAccessController.VacationCoverageWrap> VacationCoverageList = TemporaryAccountAccessController.getVacationCoverageList(UserInfo.getUserId(),string.valueOf(userCoreSales.Id),true);
        List<TemporaryAccountAccessController.VacationCaseWrap> VacationCases = TemporaryAccountAccessController.getVacationCases(UserInfo.getUserId(),true);
        List<TemporaryAccountAccessController.TBHCoverageWrap> TBHCoverageList = TemporaryAccountAccessController.getTBHCoverageList(string.valueOf(patchTeamRecord.Id));
        list<TemporaryAccountAccessController.TBHCaseWrap> caseWrapList= new list<TemporaryAccountAccessController.TBHCaseWrap>();
        TemporaryAccountAccessController.TBHCaseWrap rec = new TemporaryAccountAccessController.TBHCaseWrap();
        rec.accessRequestRecord = TBHAccess;
        rec.isSelected = true;
        //rec.requestedToId = UserInfo.getUserId();
        caseWrapList.add(rec);
		String JSONString = JSON.serialize(caseWrapList);
        string vacationRemove = TemporaryAccountAccessController.TBHCoverageRemove(UserInfo.getUserId(),'All',JSONString);
        string vacationRemoveSelected = TemporaryAccountAccessController.TBHCoverageRemove(UserInfo.getUserId(),'Selected',JSONString);
        string todayVacationDateStr = Datetime.now().format('yyyy-MM-dd'); 
        TemporaryAccountAccessController.response responseVacationResult = TemporaryAccountAccessController.VacationCoverageCreate(string.valueOf(userCoreSales.Id),'test for',UserInfo.getUserId(),'test to',todayVacationDateStr);
        TemporaryAccountAccessController.response responseVacationResult2 = TemporaryAccountAccessController.VacationCoverageCreate(UserInfo.getUserId(),'test for',string.valueOf(userCoreSales.Id),'test to',todayVacationDateStr);
		list<TemporaryAccountAccessController.VacationCaseWrap> caseWrapVacList= new list<TemporaryAccountAccessController.VacationCaseWrap>();
        TemporaryAccountAccessController.VacationCaseWrap rec1 = new TemporaryAccountAccessController.VacationCaseWrap();
        rec1.accessRequestRecord = VacationAccess;
        rec1.isSelected = true;
        rec1.requestedToId = UserInfo.getUserId();
        caseWrapVacList.add(rec1);
		String JSONString1 = JSON.serialize(caseWrapVacList);
        string vactRemove = TemporaryAccountAccessController.VacationCoverageRemove(UserInfo.getUserId(),'All',JSONString1); 
        string vactRemove1 = TemporaryAccountAccessController.VacationCoverageRemove(UserInfo.getUserId(),'Selected',JSONString1);
        test.stopTest();
        //}
    }
    static testMethod void testmethod2(){
        test.startTest();
        user userCoreSales = [Select id from user where username = 'test@unitingambition.com'];
        System.runAs(userCoreSales) {
            string coverageProfileName = TemporaryAccountAccessController.getCoverageAccessFromProfile();
            list<TemporaryAccountAccessController.picklistWrap> wrapList = TemporaryAccountAccessController.getAreaListWrap();
            list<TemporaryAccountAccessController.picklistWrap> territoryList = TemporaryAccountAccessController.getTerritorieWrap('US South West');
            list<TemporaryAccountAccessController.picklistWrap> managerList = TemporaryAccountAccessController.getManagerWrap();
            list<TemporaryAccountAccessController.picklistWrap> vacationManagerList = TemporaryAccountAccessController.getVacationManagerWrap();
        	list<TemporaryAccountAccessController.picklistWrap> userManagerList = TemporaryAccountAccessController.getUserManagerWrap();
        }
        test.stopTest();
    }
}