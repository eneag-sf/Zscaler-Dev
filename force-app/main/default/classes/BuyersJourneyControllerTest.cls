@isTest
public class BuyersJourneyControllerTest {
	
	@testSetup static void setup() {
        Skip_Triggers__c skipTriggers = new Skip_Triggers__c();
        skipTriggers.Skip_Account_Triggers__c = true;
        skipTriggers.Skip_Opportunity_Triggers__c = true;
        skipTriggers.Name = 'SkipTriggers';
        insert skipTriggers;
               
    }

	
	@isTest static void testHappyPathScenario() {
		User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        BuyersJourneyControllerTestHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.BuyersJourneyPage);
            ApexPages.currentPage().getParameters().put('id', BuyersJourneyControllerTestHelper.testOpportunity.Id);

            Opportunity opptyToTest = new Opportunity();
            ApexPages.StandardController stdController = new ApexPages.StandardController(opptyToTest);
            BuyersJourneyController controller = new BuyersJourneyController(stdController);
            controller.pageload();

            //Navigation between tabs
            controller.newStage = 1;
            controller.setCurrentStage();
            controller.newStage = 2;
            controller.setCurrentStage();
            controller.newStage = 3;
            controller.setCurrentStage();
            controller.newStage = 4;
            controller.setCurrentStage();

            controller.checklist.Agrees_to_review_F90_MAP_Implementation__c = true;
            controller.checklist.Business_case_submitted_internally__c = true;
            controller.checklist.Colloborated_on_business_case__c = true;
            controller.checklist.Combine_POC_and__c = true;
            controller.checklist.Customer_Responded_to_Promise_Email__c = true;
            controller.checklist.Due_Diligence_to_Understand_Use_Cases__c = true;
            controller.checklist.F90_Handoff_Status_flag__c = true;
            controller.checklist.Finalize_VMO_Business_Case__c = true;
            controller.checklist.Get_Agreement_to_Start_POC_Pilot_Feva__c = true;
            controller.checklist.Has_spoken_with_references__c = true;
            controller.checklist.Have_Customer_Run_Security_Preview__c = true;
            controller.checklist.Identify_Change_Agents__c = true;
            controller.checklist.Identify_Key_Stakeholders__c = true;
            controller.checklist.Identify_Partner_Name__c = true;
            controller.checklist.Identify_Partner_Type__c = 'true';
            controller.checklist.Interaction_with_Business_Case__c = true;
            controller.checklist.Introduce_VMO_Concept__c = true;
            controller.checklist.Introductory_Meeting__c = true;
            controller.checklist.MAP_Review__c = true;
            controller.checklist.Multiple_Unique_Leads_from_Account__c = true;
            controller.checklist.Name_of_Identified_Change_Agents__c = 'Test';
            controller.checklist.Participated_in_Architectural_Workshop__c = true;
            controller.checklist.Participated_in_POC_Planning__c = true;
            controller.checklist.POC_Exec_Findings_Meeting_Conducted__c = true;
            controller.checklist.Post_Sales_Support_Team_Intros__c = true;
            controller.checklist.Provide_Customer_References__c = true;
            controller.checklist.Provide_Relevant_Use_Cases__c = true;
            controller.checklist.Schedule_Architectural_Workshop__c = true;
            controller.checklist.Schedule_conduct_POC_planning_meeting__c = true;
            controller.checklist.SecurityPreview_Grade__c = 'A';
            controller.checklist.Sent_Promise_to_Proceed_Email__c = true;
            controller.checklist.VMO_Plan_in_SFDC__c = true;
            controller.checklist.Zscaler_Advantages_Reflected_in__c = true;
            controller.checklist.Create_and_Share_POC_Plan_Criteria__c = true;
            controller.checklist.Create_and_share_Mutual_Activity_Plan__c = true;
            controller.checklist.Conduct_POC_Kick_Off_Meeting__c = true;
            controller.checklist.Schedule_POC_Exec_Findings_Meeting__c = true;
            controller.checklist.Confirm_Budget_To_Purchase_Solution__c = true;
            controller.checklist.Customer_Agrees_And_Returns_MAP__c = true;
            controller.checklist.Customer_Accepts_Tech_Validation_Plan__c = true;
            controller.checklist.Date_of_POC_Kick_off_Meeting__c = Date.today();
            controller.checklist.Date_of_POC_Exec_Findings_Meeting__c = Date.today();
            controller.checklist.Conduct_POC_Execs_Findings_Meeting__c = true;

            controller.saveStart();
            controller.save();

            controller.getStage1Score();
            controller.getStage2Score();
            controller.getStage3Score();
            controller.getStage4Score();
            Test.StopTest();
        }
	}
	
	@isTest static void testHappyPathScenarioChangeAgents() {
		User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        BuyersJourneyControllerTestHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.BuyersJourneyPage);
            ApexPages.currentPage().getParameters().put('id', BuyersJourneyControllerTestHelper.testOpportunity2.Id);

            Opportunity opptyToTest = new Opportunity();
            ApexPages.StandardController stdController = new ApexPages.StandardController(opptyToTest);
            BuyersJourneyController controller = new BuyersJourneyController(stdController);
            controller.pageload();

            controller.changeAgentSearchText = 'Test3';
            BuyersJourneyController.searchContacts(controller.changeAgentSearchText, BuyersJourneyControllerTestHelper.testChecklist.Opportunity__r.AccountId);

            controller.changeAgentContactId = BuyersJourneyControllerTestHelper.mapContacts.get('Test3 Test3').Id;
            controller.addChangeAgent();
            controller.changeAgentContactId = BuyersJourneyControllerTestHelper.mapContacts.get('Test4 Test4').Id;
            controller.addChangeAgent();
            controller.changeAgentToDeleteId = BuyersJourneyControllerTestHelper.mapContacts.get('Test4 Test4').Id;
            controller.deleteChangeAgent();
            controller.getChangeAgents();

            controller.enableAddChangeAgentMode();
            controller.disableAddChangeAgentMode();
            controller.enableEditChangeAgentMode();
            controller.disableEditChangeAgentMode();
            Test.StopTest();
        }
	}

    @isTest static void testHappyPathScenarioEndorsers() {
        User me = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        BuyersJourneyControllerTestHelper.createTestData();
        
        System.runAs(me) {
            Test.startTest();
            Test.setCurrentPage(Page.BuyersJourneyPage);
            ApexPages.currentPage().getParameters().put('id', BuyersJourneyControllerTestHelper.testOpportunity2.Id);

            Opportunity opptyToTest = new Opportunity();
            ApexPages.StandardController stdController = new ApexPages.StandardController(opptyToTest);
            BuyersJourneyController controller = new BuyersJourneyController(stdController);
            controller.pageload();

            controller.endorsersSearchText = 'Test3';
            BuyersJourneyController.searchContacts(controller.endorsersSearchText, BuyersJourneyControllerTestHelper.testChecklist.Opportunity__r.AccountId);

            controller.endorsersContactId = BuyersJourneyControllerTestHelper.mapContacts.get('Test3 Test3').Id;
            controller.addEndorsers();
            controller.endorsersContactId = BuyersJourneyControllerTestHelper.mapContacts.get('Test4 Test4').Id;
            controller.addEndorsers();
            controller.endorsersToDeleteId = BuyersJourneyControllerTestHelper.mapContacts.get('Test4 Test4').Id;
            controller.deleteEndorsers();
            controller.getEndorsers();

            controller.enableAddEndorsersMode();
            controller.disableAddEndorsersMode();
            controller.enableEditEndorsersMode();
            controller.disableEditEndorsersMode();
            Test.StopTest();
        }
    }
	
}