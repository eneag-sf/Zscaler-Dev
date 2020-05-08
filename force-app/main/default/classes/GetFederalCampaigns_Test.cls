@IsTest
public class GetFederalCampaigns_Test{
    static testMethod void GetFederalCampaigns_Test(){
        //create federal sales territory
        PatchTeam__c federalTerritory = new PatchTeam__c();
        federalTerritory.Name = 'Federal';
        insert federalTerritory;

        //create test lead
        Lead testLead = new Lead();
        testLead.LastName = 'Test Lead';
        testLead.Status = 'Attempted';
        testLead.Company = 'Test Co.';
        testLead.Project_Role__c = 'Other';
        testLead.Phone = '555-555-5555';
        testLead.No_Employees_Users__c = '0 - 99';
        testLead.Email = 'test@zscaler.com';
        insert testLead;

        //create test campaign marked to be pushed to FedRAMP
        Campaign testCampaign = new Campaign();
        testCampaign.Department__c = '5210-ADR';
        testCampaign.Name = 'Test Campaign';
        testCampaign.StartDate = Date.today();
        testCampaign.EndDate = Date.today();
        testCampaign.Marketing_Initiatives__c = 'Brand';
        testCampaign.Campaign_Type__c = 'Email';
        testCampaign.Geo__c = 'APAC';
        testCampaign.Fiscal_Year__c = 'All Time';
        testCampaign.Push_to_FedRAMP__c = true;
        insert testCampaign;

        //create test campaign member
        CampaignMember testMember = new CampaignMember();
        testMember.LeadId = testLead.Id;
        testMember.CampaignId = testCampaign.Id;
        testMember.Territory__c = federalTerritory.Id;
        insert testMember;

        //create test request
        RestRequest campaignGetRequest = new RestRequest(); 
        String startdate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() + ' 00:00:00';
        String enddate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() + ' 23:59:59';
        campaignGetRequest.params.put('type', EncodingUtil.urlEncode('get_camps','UTF-8'));
        campaignGetRequest.params.put('Start_Date', EncodingUtil.urlEncode(startdate,'UTF-8'));
        campaignGetRequest.params.put('End_Date', EncodingUtil.urlEncode(enddate,'UTF-8'));

        //create empty test response and set RestContext
        RestResponse campaignGetResponse = new RestResponse();
        RestContext.request = campaignGetRequest;
        RestContext.response = campaignGetResponse;

        //run test
        GetFederalCampaigns.doGet();
    }
}