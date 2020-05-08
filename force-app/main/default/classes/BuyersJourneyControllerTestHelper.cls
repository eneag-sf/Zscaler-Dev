/*****************************************************************************************
Name: BuyersJourneyControllerTestHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Test data factory class to be used in BuyersJourneyControllerTest class
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     25-Feb-2017    Initial Development
******************************************************************************************/
@isTest
public class BuyersJourneyControllerTestHelper {
    public static Map<String, Account> mapAccounts;
    public static Map<String, Contact> mapContacts;
    public static Map<String, String> mapAccountContactMapping;
    public static Map<String, User> mapUsers;

    public static User channelManager, accountManager, areaDirector, geoLeader;
    public static Map<String, PatchTeam__c> mapPatchTeams;
    public static Map<String, Patch__c> mapPatches;

    public static Buyers_Journey_Checklist__c testChecklist;
    public static Opportunity testOpportunity;
    public static Opportunity testOpportunity2;
    public static Map<String, OpportunityContactRole> mapOpptyRoles;
    public static Map<String, AccountPartner> mapAccountPartners;

    /**
     * Utility method to create Sales Territories
     * @return Map of Sales Territories
     */
    public static Map<String, PatchTeam__c> createPatchTeams() {
        List<PatchTeam__c> lstPatchTeamsToInsert = new List<PatchTeam__c>();
        mapPatchTeams = new Map<String, PatchTeam__c>();

        PatchTeam__c amerPatchTeam1 = new PatchTeam__c();
        amerPatchTeam1.Area__c = 'AMERICAS';
        amerPatchTeam1.Region__c = 'AMERICAS';
        amerPatchTeam1.Territory_Type__c = 'Catch All';
        amerPatchTeam1.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam1);

        PatchTeam__c amerPatchTeam2 = new PatchTeam__c();
        amerPatchTeam2.Area__c = 'US Public Sector';
        amerPatchTeam2.Region__c = 'US Public Sector';
        amerPatchTeam2.Territory_Type__c = 'Enterprise';
        amerPatchTeam2.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam2);

        PatchTeam__c amerPatchTeam3 = new PatchTeam__c();
        amerPatchTeam3.Area__c = 'US West';
        amerPatchTeam3.Region__c = 'US West';
        amerPatchTeam3.Territory_Type__c = 'Large Enterprise';
        amerPatchTeam3.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam3);

        PatchTeam__c amerPatchTeam4 = new PatchTeam__c();
        amerPatchTeam4.Area__c = 'US North Central';
        amerPatchTeam4.Region__c = 'US Central';
        amerPatchTeam4.Territory_Type__c = 'General Business';
        amerPatchTeam4.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam4);

        PatchTeam__c amerPatchTeam5 = new PatchTeam__c();
        amerPatchTeam5.Area__c = 'US South East';
        amerPatchTeam5.Region__c = 'US East';
        amerPatchTeam5.Territory_Type__c = 'Hybrid';
        amerPatchTeam5.Theater__c = 'AMERICAS';
        lstPatchTeamsToInsert.add(amerPatchTeam5);

        PatchTeam__c emeaPatchTeam1 = new PatchTeam__c();
        emeaPatchTeam1.Area__c = 'EMEA';
        emeaPatchTeam1.Region__c = 'EMEA';
        emeaPatchTeam1.Territory_Type__c = 'Catch All';
        emeaPatchTeam1.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam1);

        PatchTeam__c emeaPatchTeam2 = new PatchTeam__c();
        emeaPatchTeam2.Area__c = 'Nordics';
        emeaPatchTeam2.Region__c = 'Benelux/Nordics';
        emeaPatchTeam2.Territory_Type__c = 'Enterprise';
        emeaPatchTeam2.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam2);

        PatchTeam__c emeaPatchTeam3 = new PatchTeam__c();
        emeaPatchTeam3.Area__c = 'Benelux';
        emeaPatchTeam3.Region__c = 'Benelux/Nordics';
        emeaPatchTeam3.Territory_Type__c = 'Large Enterprise';
        emeaPatchTeam3.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam3);

        PatchTeam__c emeaPatchTeam4 = new PatchTeam__c();
        emeaPatchTeam4.Area__c = 'Benelux/Nordics';
        emeaPatchTeam4.Region__c = 'Benelux/Nordics';
        emeaPatchTeam4.Territory_Type__c = 'General Business';
        emeaPatchTeam4.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam4);

        PatchTeam__c emeaPatchTeam5 = new PatchTeam__c();
        emeaPatchTeam5.Area__c = 'UK/Ireland/Israel/SA/ME';
        emeaPatchTeam5.Region__c = 'UK/Ireland/Israel/SA/ME';
        emeaPatchTeam5.Territory_Type__c = 'All';
        emeaPatchTeam5.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam5);

        PatchTeam__c emeaPatchTeam6 = new PatchTeam__c();
        emeaPatchTeam6.Area__c = 'Iberia';
        emeaPatchTeam6.Region__c = 'Southern Europe';
        emeaPatchTeam6.Territory_Type__c = 'Hybrid';
        emeaPatchTeam6.Theater__c = 'EMEA';
        lstPatchTeamsToInsert.add(emeaPatchTeam6);

        PatchTeam__c apacPatchTeam1 = new PatchTeam__c();
        apacPatchTeam1.Area__c = 'APAC';
        apacPatchTeam1.Region__c = 'APAC';
        apacPatchTeam1.Territory_Type__c = 'Catch All';
        apacPatchTeam1.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam1);

        PatchTeam__c apacPatchTeam2 = new PatchTeam__c();
        apacPatchTeam2.Area__c = 'ANZ';
        apacPatchTeam2.Region__c = 'ANZ';
        apacPatchTeam2.Territory_Type__c = 'Large Enterprise';
        apacPatchTeam2.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam2);

        PatchTeam__c apacPatchTeam3 = new PatchTeam__c();
        apacPatchTeam3.Area__c = 'ANZ';
        apacPatchTeam3.Region__c = 'ANZ';
        apacPatchTeam3.Territory_Type__c = 'Enterprise';
        apacPatchTeam3.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam3);

        PatchTeam__c apacPatchTeam4 = new PatchTeam__c();
        apacPatchTeam4.Area__c = 'India';
        apacPatchTeam4.Region__c = 'India';
        apacPatchTeam4.Territory_Type__c = 'Enterprise';
        apacPatchTeam4.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam4);

        PatchTeam__c apacPatchTeam5 = new PatchTeam__c();
        apacPatchTeam5.Area__c = 'Greater China Region';
        apacPatchTeam5.Region__c = 'GCR';
        apacPatchTeam5.Territory_Type__c = 'Hybrid';
        apacPatchTeam5.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam5);

        PatchTeam__c apacPatchTeam6 = new PatchTeam__c();
        apacPatchTeam6.Area__c = 'India';
        apacPatchTeam6.Region__c = 'India';
        apacPatchTeam6.Territory_Type__c = 'All';
        apacPatchTeam6.Theater__c = 'APAC';
        lstPatchTeamsToInsert.add(apacPatchTeam6);

        try {
            insert lstPatchTeamsToInsert;
        } catch (Exception ex) {
            System.debug('Error occurred while creating test Patch Teams:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }

        for (PatchTeam__c patchTeam : lstPatchTeamsToInsert) {
            mapPatchTeams.put(patchTeam.Theater__c + '|' + patchTeam.Territory_Type__c, patchTeam);
        }

        mapPatches = new Map<String, Patch__c>();
        
        Patch__c patch1 = new Patch__c();
        patch1.Active__c = true;
        patch1.Catchall__c = false;
        patch1.Comments__c = 'test';
        patch1.Type__c = 'GEO Based';
        patch1.PatchName__c = 'EMEA|Enterprise';
        patch1.PatchTeam__c = mapPatchTeams.get('EMEA|Enterprise').Id;
        insert patch1;
        mapPatches.put('EMEA|Enterprise', patch1);

        Patch__c patch2 = new Patch__c();
        patch2.Active__c = true;
        patch2.Catchall__c = false;
        patch2.Comments__c = 'test';
        patch2.Type__c = 'GEO Based';
        patch2.PatchName__c = 'EMEA|General Business';
        patch2.PatchTeam__c = mapPatchTeams.get('EMEA|General Business').Id;
        insert patch2;
        mapPatches.put('EMEA|General Business', patch2);
        
        return mapPatchTeams;
    }

    /**
     * Utility method to create Patch Members
     */
    public static void createUsersForPatchTeamMembers() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        channelManager = new User(
                FirstName = 'Channel Manager',
                LastName = 'CAM',
                Email = 'camuser@zscaler.com',
                Username = 'camuser@zscaler.com',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'camusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = sysAdminProfile.Id
            );

        accountManager = new User(
                FirstName = 'Account Manager',
                LastName = 'RSM',
                Email = 'rsmuser@zscaler.com',
                Username = 'rsmuser@zscaler.com',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'rsmusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = sysAdminProfile.Id
            );

        areaDirector = new User(
                FirstName = 'Area Director',
                LastName = 'AD',
                Email = 'aduser@zscaler.com',
                Username = 'aduser@zscaler.com',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'adusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = sysAdminProfile.Id
            );

        geoLeader = new User(
                FirstName = 'Geo Leader',
                LastName = 'GL',
                Email = 'gluser@zscaler.com',
                Username = 'gluser@zscaler.com',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'glusr',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = sysAdminProfile.Id
            );

        try {
            insert new List<User> { channelManager, accountManager, areaDirector, geoLeader };

            mapUsers = new Map<String, User>();
            mapUsers.put('CM', channelManager);
            mapUsers.put('AM', accountManager);
            mapUsers.put('AD', areaDirector);
            mapUsers.put('GL', geoLeader);
        } catch (Exception ex) {
            System.debug('Error occurred while creating test users:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }
    }

    /**
     * Utility method to create sales team members
     */
    public static void createPatchTeamMembers() {
        List<PatchTeamMember__c> lstPatchTeamMembersToInsert = new List<PatchTeamMember__c>();

        //Channel Managers
        for (String key : mapPatchTeams.keySet()) {
            lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(
                    PatchTeam__c = mapPatchTeams.get(key).Id,
                    Role__c = 'Channer Manager',
                    User__c = channelManager.Id
                ));
        }

        //Account Managers
        for (String key : mapPatchTeams.keySet()) {
            lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(
                    PatchTeam__c = mapPatchTeams.get(key).Id,
                    Role__c = 'Account Manager',
                    User__c = accountManager.Id
                ));
        }

        //Area Directors
        for (String key : mapPatchTeams.keySet()) {
            lstPatchTeamMembersToInsert.add(new PatchTeamMember__c(
                    PatchTeam__c = mapPatchTeams.get(key).Id,
                    Role__c = 'Area Director',
                    User__c = areaDirector.Id
                ));
        }

        try {
            insert lstPatchTeamMembersToInsert;
        } catch (Exception ex) {
            System.debug('Error occurred while creating patch team members:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create new test accounts
     */
    public static void createAccounts() {
        Account testAccount1 = new Account(
                                            Name = 'Test Account1',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288',
                                            Sales_Territory__c = mapPatchTeams.get('APAC|All').Id
                                        );

        Account testAccount2 = new Account(
                                            Name = 'Test Account2',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288',
                                            Sales_Territory__c = mapPatchTeams.get('EMEA|Enterprise').Id
                                        );

        Account testAccount3 = new Account(
                                            Name = 'Test Account3',
                                            Amber_Road_Integration_Status__c = null,
                                            Amber_Road_Status__c = null,
                                            BillingCity = 'San Jose',
                                            BillingCountry = 'United States',
                                            BillingPostalCode = '95134',
                                            BillingState = 'California',
                                            BillingStreet = '110 Rose Orchard Way',
                                            Fax = '',
                                            Phone = '+1 408.533.0288',
                                            Sales_Territory__c = mapPatchTeams.get('EMEA|Enterprise').Id
                                        );

        try {
            insert new List<Account> { testAccount1, testAccount2, testAccount3 };
            mapAccounts = new Map<String, Account>();
            mapAccounts.put(testAccount1.Name, testAccount1);
            mapAccounts.put(testAccount2.Name, testAccount2);
            mapAccounts.put(testAccount3.Name, testAccount3);
        } catch (Exception ex) {
            System.debug('Exception occurred while creating test accounts: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create new test contacts and map them to test accounts
     */
    public static void createContacts() {
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.Head_of_IT__c = true;
        con1.AccountId = mapAccounts.get('Test Account1').Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Head_of_Networking__c = true;
        con2.AccountId = mapAccounts.get('Test Account2').Id;

        Contact con3 = new Contact();
        con3.FirstName = 'Test3';
        con3.LastName = 'Test3';
        con3.Head_of_Security__c = true;
        con3.AccountId = mapAccounts.get('Test Account3').Id;

        Contact con4 = new Contact();
        con4.FirstName = 'Test4';
        con4.LastName = 'Test4';
        con4.Budget_Authority__c = true;
        con4.Procurement_Contact__c = true;
        con4.Head_of_networking__c = true;
        con4.Head_of_Security__c = true;
        con4.AccountId = mapAccounts.get('Test Account3').Id;

        try {
            insert new List<Contact> { con1, con2, con3, con4 };
            
            mapContacts = new Map<String, Contact>();
            mapContacts.put(con1.FirstName + ' ' + con1.LastName, con1);
            mapContacts.put(con2.FirstName + ' ' + con2.LastName, con2);
            mapContacts.put(con3.FirstName + ' ' + con3.LastName, con3);
            mapContacts.put(con4.FirstName + ' ' + con4.LastName, con4);
            System.debug('>>>> mapContacts: ' + mapContacts);
            mapAccountContactMapping = new Map<String, String>();
            mapAccountContactMapping.put('Test Account1', con1.Name);
            mapAccountContactMapping.put('Test Account2', con1.Name);
            mapAccountContactMapping.put('Test Account3', con3.Name);
            mapAccountContactMapping.put('Test Account3', con4.Name);
        } catch (Exception ex) {
            System.debug('Error occurred while creating contacts: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create a test opportunity
     */
    public static void createOpportunities() {
        testOpportunity = new Opportunity(Name = 'Test opportunity', 
                                          AccountId = mapAccounts.get('Test Account3').Id, 
                                          StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, 
                                          CloseDate = System.Today()+30,
                                          Patch__c = mapPatches.get('EMEA|Enterprise').Id
                                        );

        testOpportunity2 = new Opportunity(Name = 'Test opportunity', 
                                          AccountId = mapAccounts.get('Test Account3').Id, 
                                          StageName = label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, 
                                          CloseDate = System.Today()+30,
                                          Patch__c = mapPatches.get('EMEA|Enterprise').Id
                                        );

        try {
            insert testOpportunity;
            insert testOpportunity2;            
        } catch(Exception ex) {
            System.debug('Error occurred while creating opportunity: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create test contact roles under opportunity
     */
    public static void createOpptyContactRoles(String opportunityId) {
        List<OpportunityContactRole> lstContactRoles = new List<OpportunityContactRole>();

        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.Role = 'Change Agent';
        ocr1.IsPrimary = True;
        ocr1.OpportunityId = OpportunityId;
        ocr1.ContactId = mapContacts.get('Test1 Test1').Id;
        lstContactRoles.add(ocr1);

        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.Role = 'Endorser';
        ocr2.IsPrimary = True;
        ocr2.OpportunityId = OpportunityId;
        ocr2.ContactId = mapContacts.get('Test2 Test2').Id;
        lstContactRoles.add(ocr2);

        try {
            insert lstContactRoles;
        } catch(Exception ex) {
            System.debug('Error occurred while creating opportunity contact roles: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create test account partners
     */
    //public static void createAccountPartners() {
    //    AccountPartner ap1 = new AccountPartner();
    //    //ap1.Role = 'ISP';
    //    //ap1.AccountFromId = mapAccounts.get('Test Account1').Id;
    //    ap1.AccountToId = mapAccounts.get('Test Account3').Id;
    //    ap1.OpportunityId = testOpportunity.Id;
    //    ap1.IsPrimary = true;

    //    try {
    //        insert ap1;
    //    } catch(Exception ex) {
    //        System.debug('Error occurred while creating account partners: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
    //    }
    //}
    
    public static void createTestChecklist() {
        testChecklist = new Buyers_Journey_Checklist__c(Opportunity__c = testOpportunity2.Id);
        testChecklist.Agrees_to_review_F90_MAP_Implementation__c = true;
        testChecklist.Business_case_submitted_internally__c = true;
        testChecklist.Colloborated_on_business_case__c = true;
        testChecklist.Combine_POC_and__c = true;
        testChecklist.Customer_Responded_to_Promise_Email__c = true;
        testChecklist.Due_Diligence_to_Understand_Use_Cases__c = true;
        testChecklist.F90_Handoff_Status_flag__c = true;
        testChecklist.Finalize_VMO_Business_Case__c = true;
        testChecklist.Get_Agreement_to_Start_POC_Pilot_Feva__c = true;
        testChecklist.Has_spoken_with_references__c = true;
        testChecklist.Have_Customer_Run_Security_Preview__c = true;
        testChecklist.Identify_Change_Agents__c = true;
        testChecklist.Identify_Key_Stakeholders__c = true;
        testChecklist.Identify_Partner_Name__c = true;
        testChecklist.Identify_Partner_Type__c = 'true';
        testChecklist.Interaction_with_Business_Case__c = true;
        testChecklist.Introduce_VMO_Concept__c = true;
        testChecklist.Introductory_Meeting__c = true;
        testChecklist.MAP_Review__c = true;
        testChecklist.Multiple_Unique_Leads_from_Account__c = true;
        testChecklist.Name_of_Identified_Change_Agents__c = 'Test';
        testChecklist.Participated_in_Architectural_Workshop__c = true;
        testChecklist.Participated_in_POC_Planning__c = true;
        testChecklist.POC_Exec_Findings_Meeting_Conducted__c = true;
        testChecklist.Post_Sales_Support_Team_Intros__c = true;
        testChecklist.Provide_Customer_References__c = true;
        testChecklist.Provide_Relevant_Use_Cases__c = true;
        testChecklist.Schedule_Architectural_Workshop__c = true;
        testChecklist.Schedule_conduct_POC_planning_meeting__c = true;
        testChecklist.SecurityPreview_Grade__c = 'A';
        testChecklist.Sent_Promise_to_Proceed_Email__c = true;
        testChecklist.VMO_Plan_in_SFDC__c = true;
        testChecklist.Zscaler_Advantages_Reflected_in__c = true;
        testChecklist.Create_and_Share_POC_Plan_Criteria__c = true;
        testChecklist.Create_and_share_Mutual_Activity_Plan__c = true;
        testChecklist.Conduct_POC_Kick_Off_Meeting__c = true;
        testChecklist.Schedule_POC_Exec_Findings_Meeting__c = true;
        testChecklist.Confirm_Budget_To_Purchase_Solution__c = true;
        testChecklist.Customer_Agrees_And_Returns_MAP__c = true;
        testChecklist.Customer_Accepts_Tech_Validation_Plan__c = true;
        testChecklist.Date_of_POC_Kick_off_Meeting__c = Date.today();
        testChecklist.Date_of_POC_Exec_Findings_Meeting__c = Date.today();
        testChecklist.Conduct_POC_Execs_Findings_Meeting__c = true;

        try {
            insert testChecklist;
        } catch(Exception ex) {
            System.debug('Error occurred while creating buyers journey: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
    }

    /**
     * Method to create all test data (handled dependencies between other methods)
     */
    public static void createTestData() {
        createUsersForPatchTeamMembers();

        User me = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(me) {
            createPatchTeams();
            createPatchTeamMembers();
            createAccounts();
            createContacts();
            createOpportunities();
            createOpptyContactRoles(testOpportunity.Id);
            //createAccountPartners();
            createTestChecklist();
        }
    }
}