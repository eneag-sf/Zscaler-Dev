/*****************************************************************************************
Name: DealRegistrationServiceTest
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to unit test the DealRegistrationService class code
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     02-Sept-2016    Initial Development
******************************************************************************************/
@isTest
public class DealRegTestDataFactory {
    public static User channelManager, accountManager, areaDirector, geoLeader;
    public static Map<String, PatchTeam__c> mapPatchTeams;
    public static Map<Account, List<Contact>> mapAccountsAndContacts;

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
     * Utility method to create Geo leaders mapping
     */
    public static void createGeoLeadersMapping() {
        Deal_Reg_GEO_Leaders__c americas = new Deal_Reg_GEO_Leaders__c(SetupOwnerId = areaDirector.Id, Geo__c = 'AMERICAS');
        Deal_Reg_GEO_Leaders__c others = new Deal_Reg_GEO_Leaders__c(SetupOwnerId = geoLeader.Id, Geo__c = 'EMEA;APAC;CHANNEL');

        try {
            insert new List<Deal_Reg_GEO_Leaders__c> { americas, others };
        } catch (Exception ex) {
            System.debug('Error occurred while geo leader mapping:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }
    }

    /**
     * Utility method to create campaign and Zscaler settings
     */
    public static void createCampaignAndZscalerSettings() {
        Campaign camp = new Campaign();
        camp.Name = 'Deal Registration';
        camp.EndDate = system.today() + 30;
        camp.IsActive = true;
        insert camp;

        ZscalerSetting__c zs = new ZscalerSetting__c();
        zs.Name = 'DealRegCampaign';
        zs.Value__c = ''+camp.Id;
        insert zs;

        ZscalerSetting__c zs1 = new ZscalerSetting__c();
        zs1.Name = 'DealRegCaseReviewOwnerId';
        zs1.Value__c = ''+userInfo.getuserId();
        insert zs1;
    }

    /**
     * Utility method to create Account and Contact records
     * @param  accountName      Name of the account
     * @param  domain           Account Domain
     * @param  territoryId      Sales Territory Id
     * @param  marketSegment    Market Segment
     * @param  numberOfContacts Number of contacts to create
     * @return                  Map of Account and List of contacts
     */
    public static Map<Account, List<Contact>> createAccountAndContact(String accountName, String domain, Id territoryId, String marketSegment, Integer numberOfContacts) {
        List<Contact> lstContactsToInsert = new List<Contact>();

        Account newAccount = new Account();
        newAccount.Name = accountName;
        newAccount.Domain__c = domain;
        newAccount.Sales_Territory__c = territoryId;
        newAccount.Market_Segment__c = marketSegment;

        try {
            insert newAccount;
        } catch (Exception ex) {
            System.debug('Error occurred while account creation:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }

        for (Integer counter = 0; counter < numberOfContacts; counter++) {
            Contact newContact = new Contact();
            newContact.FirstName = 'Test';
            newContact.LastName = 'Contact ' + counter;
            newContact.AccountId = newAccount.Id;
            newContact.Email = 'testContact' + counter + '@' + domain;

            lstContactsToInsert.add(newContact);
        }

        try {
            insert lstContactsToInsert;
        } catch (Exception ex) {
            System.debug('Error occurred while contacts creation:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }

        if (null == mapAccountsAndContacts || mapAccountsAndContacts.isEmpty()) {
            mapAccountsAndContacts = new Map<Account, List<Contact>>();
        }

        mapAccountsAndContacts.put(newAccount, lstContactsToInsert);

        return mapAccountsAndContacts;
    }

    /**
     * Method to create a deal registration
     * @param  partnerEmail    Partner Email Id
     * @param  partnerCompany  Partner Company Name
     * @param  customerCompany Customer Company Name
     * @param  customerDomain  Customer Domain
     * @param  customerCountry Customer Country
     * @param  territory       Sales Territory Id
     * @param  marketSegment   Market Segment
     * @return                 Returns the list of Deal Regs created
     */
    public static Deal_Reg__c createDealReg(String partnerEmail, String partnerCompany, String customerCompany, String customerDomain, String customerCountry, PatchTeam__c territory, String marketSegment) {
        Deal_Reg__c dealReg = new Deal_Reg__c();
        dealReg.Customer_Role_And_Title__c = 'Other';
        dealReg.Comments__c = 'test deal reg';
        dealReg.Deal_Description__c = 'test deal reg';
        dealReg.End_Customer_Contact_Last_Name__c = 'customerLastName';
        dealReg.End_Customer_Contact_Name__c = 'customerFirstName';
        dealReg.End_Customer_Country__c = customerCountry;
        dealReg.End_Customer_Domain__c = customerDomain;
        dealReg.End_Customer_Email__c = 'testemail@' + customerDomain;
        dealReg.End_Customer_Name__c = customerCompany;
        dealReg.End_Customer_Phone__c = '98765432234';
        dealReg.End_Customer_State__c = 'Karnataka';
        dealReg.End_Customer_Street_Address__c = '1234, Hello world way';
        dealReg.End_Customer_City__c = 'San Fransisco';
        dealReg.End_Customer_Postal_Code__c = '10010';
        dealReg.Estimated_Amount__c = 20000.0;
        dealReg.Expected_Close_Date__c = Date.today().addDays(10);
        dealReg.Number_of_Users__c = 2000;
        dealReg.Partner_Company_Name__c = partnerCompany;
        dealReg.Partner_Contact_Email__c = partnerEmail;
        dealReg.Partner_Contact_Last_Name__c = 'partnerLastName';
        dealReg.Partner_Contact_Name__c = 'partnerFirstName';
        dealReg.Source__c = 'Zscaler Website';
        dealReg.DS_Review_Status__c = 'Pending';
        dealReg.Status__c = 'Submitted';
        dealReg.Approval_Status__c = 'Pending';

        try {
            insert dealReg;
        } catch (Exception ex) {
            System.debug('Error occurred while inserting deal reg:' + ex.getMessage() + ';' + ex.getStackTraceString());
        }

        System.debug('>>>>> dealReg: ' + dealReg);
        
        //dealReg.Sales_Territory__c = territory.Id;
        //dealReg.Channel_Manager__c = channelManager.Id;
        //dealReg.Account_Manager__c = accountManager.Id;
        //dealReg.Area_Director__c = areaDirector.Id;
        //dealReg.Market_Segment__c = marketSegment;

        //try {
        //    update dealReg;
        //} catch (Exception ex) {
        //    System.debug('Error occurred while updating deal reg:' + ex.getMessage() + ';' + ex.getStackTraceString());
        //}

        return dealReg;
    }

    /**
     * Encapsulated method to create all test data
     */
    public static void createPatchTeamsAndGeoLeaderMappings() {
        createUsersForPatchTeamMembers();

        User me = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(me) {
            createPatchTeams();
            createPatchTeamMembers();
            createGeoLeadersMapping();
            createCampaignAndZscalerSettings();
        }
    }
}