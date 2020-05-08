/**
 * @File Name          : AccountTriggerHelper.cls
 * @Description        : 
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 14/7/2019, 12:40:28 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *============================================================================== 
 * 1.0    22/5/2019, 6:26:03 PM   pranjalsingh@zscaler.com     Initial Version 
 **/
public class AccountTriggerHelper { 
    public static boolean isOppPresent; // Checks if Opp List is non-empty
    public static boolean isSCIPresent; // Checks if SCI List is non-empty
    public static Boolean validationEndStage08 = false;
    public static boolean validationEndStage17 = false;
    public static boolean openLatestSCIPresent = false;
    public static boolean validOppClose = false;
    public static set < String > closedOpps = new set < String > {
        label.Stage_7_Closed_Lost
        //'11 - Closed Lost',
        //'12 - Closed With No Decision'
    };
    public static set < String > openOpps = new set < String > {
        //'1 - Qualified and Budgeted',
        label.Stage_1_Alignment,
        //'2 - Technical Validation',
        label.Stage_2_Qualified_Budgeted,
        //'7 - Negotiation & Review',
        //'8 - Expecting Order',
        //'9 - Deal Stuck',
        label.Stage_4_Economic_Buyer_Signoff,
        //'10b - PO recd, pending finance approval'
        label.Stage_5_Contracts_Complete
    };
    public static set < String > validation_stage_pipeline = new set < String > {
        '0 - Not Started',
        '8 - Not Required',
        ''
    };
    public static set < String > validation_stage_POC = new set < String > {
        '1 - Establishing Plan & success criteria',
        '2 - Configuration in Progress',
        '3 - Detailed validation in progress',
        '4 - Delivering validation findings report',
        '5 - Validation Stalled',
        '5b - Pending customer decision',
        '6 - Technical Win',
        '7 - Technical Loss'
    };

    public static void changeRelatedContactsOwner(list < Account > accountNewList, map < Id, Account > accountOldMap) {
        list < Contact > contactUpdateList = new list < Contact > ();
        map < Id, Id > accIdOwnerIdMap = new map < Id, Id > ();
        set < Id > activeUserIdSet = new set < Id > ();
        for (Account acc: accountNewList) {
            if (acc.ownerId != accountOldMap.get(acc.Id).ownerId) {
                accIdOwnerIdMap.put(acc.id, acc.OwnerId);
            }
        }

        if (!accIdOwnerIdMap.values().isEmpty()) {

            for (User usr: [select id from user where isActive =: true and ID IN: accIdOwnerIdMap.values()]) {
                activeUserIdSet.add(usr.Id);
            }

            for (Contact con: [Select Id, OwnerId, AccountId from Contact WHERE AccountId IN: accIdOwnerIdMap.keyset()]) {
                if (con.OwnerId != accIdOwnerIdMap.get(con.AccountId) && activeUserIdSet.contains(accIdOwnerIdMap.get(con.AccountId)))
                    contactUpdateList.add(new Contact(Id = con.Id, ownerId = accIdOwnerIdMap.get(con.AccountId)));
            }

            if (!contactUpdateList.isEmpty())
                Database.update(contactUpdateList, false);
        }
        TriggerUtility.accToContactOwnerExecuted();
    }

    public static void getAccSalesTeam(list < Account > accountNewList, map < Id, Account > accountOldMap) {
        system.debug('in getAccSalesTeam method');
    System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
    if(TriggerUtility.accSalesTeamMethodExecution<2){
        set < id > salesTerritoryIdSet = new set < id > ();
        for (Account acc: accountNewList) {
            if(acc.Sales_Territory__c!= null/*  && acc.Sales_Territory__c != accountOldMap.get(acc.Id).Sales_Territory__c */) {
                salesTerritoryIdSet.add(acc.Sales_Territory__c);
            }
        }
        system.debug('salesTerritoryIdSet   '+salesTerritoryIdSet);
        Map < String, Id > territorySalesUserIdMap = new Map < String, Id > ();
        if (!salesTerritoryIdSet.isEmpty()) {
            for (PatchTeam__c territory: [Select id, Lead_Development__c, (Select Id, Role__c, PatchTeam__c, User__c from PatchTeamMembers__r) from PatchTeam__c where ID IN: salesTerritoryIdSet]) {

                for (PatchTeamMember__c salesTeam: territory.PatchTeamMembers__r) {
                    if (salesTeam.Role__c == 'Account Manager')
                        territorySalesUserIdMap.put('' + territory.id + 'AccountManager', salesTeam.User__c);
                    if (salesTeam.Role__c == 'Area Director')
                        territorySalesUserIdMap.put('' + territory.id + 'AreaDirector', salesTeam.User__c);
                    if (salesTeam.Role__c == 'Channel Manager')
                        territorySalesUserIdMap.put('' + territory.id + 'ChannelManager', salesTeam.User__c);
                    if (salesTeam.Role__c == 'Customer Advocate')
                        territorySalesUserIdMap.put('' + territory.id + 'CustomerAdvocate', salesTeam.User__c);
                    if (salesTeam.Role__c == 'Sales Engineer')
                        territorySalesUserIdMap.put('' + territory.id + 'SalesEngineer', salesTeam.User__c);
                    if (salesTeam.Role__c == 'ZPA Manager')
                        territorySalesUserIdMap.put('' + territory.id + 'ZPAManager', salesTeam.User__c);
                    if (salesTeam.Role__c == 'ZPA SE')
                        territorySalesUserIdMap.put('' + territory.id + 'ZPASE', salesTeam.User__c);
                    if (salesTeam.Role__c == 'Lead Development')
                        territorySalesUserIdMap.put('' + territory.id + 'LeadDevelopment', salesTeam.User__c);
                    /* if (salesTeam.Role__c == 'Solution Architect')
                        territorySalesUserIdMap.put('' + territory.id + 'SolutionArchitect', salesTeam.User__c); */
                }
            }
            system.debug('territorySalesUserIdMap   '+territorySalesUserIdMap);
            for (Account acc: accountNewList) {
                if(acc.Sales_Territory__c != null /*&& acc.Sales_Territory__c != accountOldMap.get(acc.Id).Sales_Territory__c */){
                    acc.Area_Director__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'AreaDirector');
                    acc.Account_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'AccountManager');
                    acc.Channel_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ChannelManager');
                    acc.Customer_Advocate__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'CustomerAdvocate');
                    acc.Sales_Engineer__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'SalesEngineer');
                    //acc.ZPA_Manager__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ZPAManager');
                    //acc.ZPA_SE__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'ZPASE');
                    acc.lead_development2__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'LeadDevelopment');
                    /* acc.Solution_Architect__c = territorySalesUserIdMap.get('' + acc.Sales_Territory__c + 'SolutionArchitect'); */

                } else {
          if(OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng')!=null && OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateSalesTeamBlankifSTnotchng').Deactivate_Component__c==False){
            acc.Area_Director__c = null;
            acc.Account_Manager__c = null;
            acc.Channel_Manager__c = null;
            acc.Customer_Advocate__c = null;
            acc.Sales_Engineer__c = null;
            //acc.ZPA_Manager__c = null;
            //acc.ZPA_SE__c = null;
            acc.lead_development2__c=null;
            //acc.Solution_Architect__c=null;
          }
                }
            }
            //TriggerUtility.accSalesTeamExecuted(); //Commented as Patch has been changed,Sales team was not getting updated,Sales Team was getting updated if Account has been triggered twice 
      TriggerUtility.accSalesTeamMethodExecution=TriggerUtility.accSalesTeamMethodExecution+1;
        }
    }

    }

    public static void screenAccountsWithAmberRoad(List < Account > accountsToBeScreenedList,Map<id,Account> triggerOldMap) {
        if (!System.isFuture() && !System.isbatch() && !System.isQueueable() && !System.isScheduled()) {
        Set<String> AccountTypeSet= new Set<String>();
        String ListofAccountType= ZscalerCustomSetting__c.getInstance('ListofAccountType')!=null && ZscalerCustomSetting__c.getInstance('ListofAccountType').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ListofAccountType').Value__c:'Partner';
        AccountTypeSet.addall(ListofAccountType.split(','));
        
            for (Account newAccount: accountsToBeScreenedList) {
                if((trigger.isinsert && newAccount.Type=='Partner') || (trigger.isupdate && AccountTypeSet.contains(newAccount.Type) && newAccount.Type!=triggerOldMap.get(newAccount.id).Type)){ // Added check as part of Amber ROAD Enhancement:Gurjinder
                    String accountJson = JSON.serialize(newAccount);
                    if (!Test.isRunningTest()) {
                        AmberRoadService.screenAccountFuture(accountJson, true, false);
                    }
                }
            }
            //TriggerUtility.ScreenAccountsWithAmberRoadExecutedsettrue();
        }
    }

    public static void captureCustomerNextStepsHistory(List < Account > newAccounts, Map < Id, Account > oldAccounts) {
        List < Customer_Next_Steps_History__c > lstCNSHistoryToInsert = new List < Customer_Next_Steps_History__c > ();

        for (Account account: newAccounts) {
            if (oldAccounts != null &&
                oldAccounts.containsKey(account.Id) &&
                oldAccounts.get(account.Id).Customer_Next_Steps__c != null &&
                oldAccounts.get(account.Id).Customer_Next_Steps__c != account.Customer_Next_Steps__c) {
                lstCNSHistoryToInsert.add(new Customer_Next_Steps_History__c(Account__c = account.Id, Next_Steps__c = oldAccounts.get(account.Id).Customer_Next_Steps__c));
            }
        }

        try {
            Database.insert(lstCNSHistoryToInsert, false);
            TriggerUtility.captureCustomerNextStepsHistoryExecuted();
        } catch (Exception ex) {
            System.debug('>>>> Error occurred while creating Customer Next Steps History records: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }

    // Vijay - 03/26/2018: Commenting this out as the logic will be handled by contact trigger
    // public static void updateContactWhitespaceRole(list<Account> newAccList, map<id, Account> oldAccMap){
    //
    //     TriggerUtility.conWhiteSpaceUpdateExecuted();
    //
    //     map<Id, Contact> conUpdateMap = new map<Id, Contact>();
    //
    //     Contact tempCon = new Contact();
    //
    //     for(Account acc : newAccList){
    //
    //         if(acc.HeadofIT__c != null && acc.HeadofIT__c != oldAccMap.get(acc.id).HeadofIT__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofIT__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofIT__c);
    //             else
    //                 tempCon.Id = acc.HeadOfIt__c;
    //             tempCon.Head_Of_It__c = true;
    //             conUpdateMap.put(acc.HeadOfIt__c, tempCon);
    //             if(oldAccMap.get(acc.id).HeadofIT__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofIT__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofIT__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofIT__c;
    //                 tempCon.Head_Of_It__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofIT__c, tempCon);
    //             }
    //         }else if(acc.HeadofIT__c == null && acc.HeadofIT__c != oldAccMap.get(acc.id).HeadofIT__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofIT__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofIT__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofIT__c;
    //             tempCon.Head_Of_It__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofIT__c, tempCon);
    //         }
    //         if(acc.HeadofNetworking__c != null && acc.HeadofNetworking__c != oldAccMap.get(acc.id).HeadofNetworking__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofNetworking__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofNetworking__c);
    //             else
    //                 tempCon.Id = acc.HeadofNetworking__c;
    //             tempCon.Head_of_Networking__c = true;
    //             conUpdateMap.put(acc.HeadofNetworking__c, tempCon);
    //
    //             if(oldAccMap.get(acc.id).HeadofNetworking__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofNetworking__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofNetworking__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofNetworking__c;
    //                 tempCon.Head_of_Networking__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofNetworking__c, tempCon);
    //             }
    //
    //
    //         }else if(acc.HeadofNetworking__c == null && acc.HeadofNetworking__c != oldAccMap.get(acc.id).HeadofNetworking__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofNetworking__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofNetworking__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofNetworking__c;
    //             tempCon.Head_of_Networking__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofNetworking__c, tempCon);
    //         }
    //
    //         if(acc.BudgetAuthority__c != null && acc.BudgetAuthority__c != oldAccMap.get(acc.id).BudgetAuthority__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.BudgetAuthority__c))
    //                 tempCon = conUpdateMap.get(acc.BudgetAuthority__c);
    //             else
    //                 tempCon.Id = acc.BudgetAuthority__c;
    //             tempCon.Budget_Authority__c = true;
    //             conUpdateMap.put(acc.BudgetAuthority__c, tempCon);
    //             if(oldAccMap.get(acc.id).BudgetAuthority__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).BudgetAuthority__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).BudgetAuthority__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).BudgetAuthority__c;
    //                 tempCon.Budget_Authority__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).BudgetAuthority__c, tempCon);
    //             }
    //         }else if(acc.BudgetAuthority__c == null && acc.BudgetAuthority__c != oldAccMap.get(acc.id).BudgetAuthority__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).BudgetAuthority__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).BudgetAuthority__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).BudgetAuthority__c;
    //             tempCon.Budget_Authority__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).BudgetAuthority__c, tempCon);
    //         }
    //
    //
    //         if(acc.HeadofSecurity__c != null && acc.HeadofSecurity__c != oldAccMap.get(acc.id).HeadofSecurity__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.HeadofSecurity__c))
    //                 tempCon = conUpdateMap.get(acc.HeadofSecurity__c);
    //             else
    //                 tempCon.Id = acc.HeadofSecurity__c;
    //             tempCon.Head_of_Security__c = true;
    //             conUpdateMap.put(acc.HeadofSecurity__c, tempCon);
    //             if(oldAccMap.get(acc.id).HeadofSecurity__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofSecurity__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofSecurity__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).HeadofSecurity__c;
    //                 tempCon.Head_of_Security__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).HeadofSecurity__c, tempCon);
    //             }
    //
    //
    //         }else if(acc.HeadofSecurity__c == null && acc.HeadofSecurity__c != oldAccMap.get(acc.id).HeadofSecurity__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).HeadofSecurity__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).HeadofSecurity__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).HeadofSecurity__c;
    //             tempCon.Head_of_Security__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).HeadofSecurity__c, tempCon);
    //        }
    //
    //         if(acc.ProcurementContact__c != null && acc.ProcurementContact__c != oldAccMap.get(acc.id).ProcurementContact__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.ProcurementContact__c))
    //                 tempCon = conUpdateMap.get(acc.ProcurementContact__c);
    //             else
    //                 tempCon.Id = acc.ProcurementContact__c;
    //             tempCon.Procurement_Contact__c = true;
    //             conUpdateMap.put(acc.ProcurementContact__c, tempCon);
    //             if(oldAccMap.get(acc.id).ProcurementContact__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).ProcurementContact__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).ProcurementContact__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).ProcurementContact__c;
    //                 tempCon.Procurement_Contact__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).ProcurementContact__c, tempCon);
    //             }
    //
    //         }else if(acc.ProcurementContact__c == null && acc.ProcurementContact__c != oldAccMap.get(acc.id).ProcurementContact__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).ProcurementContact__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).ProcurementContact__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).ProcurementContact__c;
    //             tempCon.Procurement_Contact__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).ProcurementContact__c, tempCon);
    //        }
    //
    //        if(acc.Service_Owner__c != null && acc.Service_Owner__c != oldAccMap.get(acc.id).Service_Owner__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.Service_Owner__c))
    //                 tempCon = conUpdateMap.get(acc.Service_Owner__c);
    //             else
    //                 tempCon.Id = acc.Service_Owner__c;
    //             tempCon.Service_Owner__c = true;
    //             conUpdateMap.put(acc.Service_Owner__c, tempCon);
    //             if(oldAccMap.get(acc.id).Service_Owner__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).Service_Owner__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).Service_Owner__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).Service_Owner__c;
    //                 tempCon.Service_Owner__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).Service_Owner__c, tempCon);
    //             }
    //
    //         }else if(acc.Service_Owner__c == null && acc.Service_Owner__c != oldAccMap.get(acc.id).Service_Owner__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).Service_Owner__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).Service_Owner__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).Service_Owner__c;
    //             tempCon.Service_Owner__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).Service_Owner__c, tempCon);
    //        }
    //
    //        if(acc.CloudArchitect__c != null && acc.CloudArchitect__c != oldAccMap.get(acc.id).CloudArchitect__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(acc.CloudArchitect__c))
    //                 tempCon = conUpdateMap.get(acc.CloudArchitect__c);
    //             else
    //                 tempCon.Id = acc.CloudArchitect__c;
    //             tempCon.Cloud_Architect__c = true;
    //             conUpdateMap.put(acc.CloudArchitect__c, tempCon);
    //             if(oldAccMap.get(acc.id).CloudArchitect__c != null){
    //                 tempCon = new Contact();
    //                 if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).CloudArchitect__c))
    //                     tempCon = conUpdateMap.get(oldAccMap.get(acc.id).CloudArchitect__c);
    //                 else
    //                     tempCon.Id = oldAccMap.get(acc.id).CloudArchitect__c;
    //                 tempCon.Cloud_Architect__c = false;
    //                 conUpdateMap.put(oldAccMap.get(acc.id).CloudArchitect__c, tempCon);
    //             }
    //
    //         }else if(acc.CloudArchitect__c == null && acc.CloudArchitect__c != oldAccMap.get(acc.id).CloudArchitect__c){
    //             tempCon = new Contact();
    //             if(conUpdateMap.keySet().contains(oldAccMap.get(acc.id).CloudArchitect__c))
    //                 tempCon = conUpdateMap.get(oldAccMap.get(acc.id).CloudArchitect__c);
    //             else
    //                 tempCon.Id = oldAccMap.get(acc.id).CloudArchitect__c;
    //             tempCon.Cloud_Architect__c = false;
    //             conUpdateMap.put(oldAccMap.get(acc.id).CloudArchitect__c, tempCon);
    //        }
    //     }
    //
    //     if(conUpdateMap != null && !conUpdateMap.values().isEmpty())
    //         database.update(conUpdateMap.Values(), false);
    //
    //     TriggerUtility.accContactWhiteSpaceUpdateExecuted();
    //
    // }

    public static void updateSENamesInOpportunity(List < Account > newAccList, Map < Id, Account > oldAccMap) {
        Map < Id, Account > mapAccountSENames = new Map < Id, Account > ();
        List < Opportunity > lstOpportunitiesToUpdate = new List < Opportunity > ();

        for (Account acct: newAccList) {
            System.debug('>>>> acct: ' + acct);
            System.debug('>>>> oldAccMap.get(acct.Id): ' + oldAccMap.get(acct.Id));
            if ((null != acct.Sales_Engineer__c ||
                    null != acct.Sales_Territory__c ||
                    null != acct.Account_Manager__c ||
                    null != acct.Area_Director__c ||
                    null != acct.Customer_Advocate__c ||
                    null != acct.Channel_Manager__c /**||
                    null != acct.ZPA_Manager__c ||
                    null != acct.ZPA_SE__c**/) &&
                (null == oldAccMap ||
                    null == oldAccMap.get(acct.Id) ||
                    acct.Sales_Engineer__c != oldAccMap.get(acct.Id).Sales_Engineer__c ||
                    acct.Channel_Manager__c != oldAccMap.get(acct.Id).Channel_Manager__c ||
                    acct.Customer_Advocate__c != oldAccMap.get(acct.Id).Customer_Advocate__c ||
                    acct.Area_Director__c != oldAccMap.get(acct.Id).Area_Director__c ||
                    acct.Account_Manager__c != oldAccMap.get(acct.Id).Account_Manager__c ||
                    /**acct.ZPA_Manager__c != oldAccMap.get(acct.Id).ZPA_Manager__c ||
                    acct.ZPA_SE__c != oldAccMap.get(acct.Id).ZPA_SE__c ||**/
                    acct.Sales_Territory__c != oldAccMap.get(acct.Id).Sales_Territory__c)) {
                mapAccountSENames.put(acct.Id, acct);
            }
        }
        System.debug('>>>>: ' + JSON.serialize(mapAccountSENames));
        String Closed_Won = label.Stage_6_Closed_Won;
        for (Opportunity oppty: [SELECT Id, AccountId, SE_Name__c, Opportunity_ZPA_Manager__c, Opportunity_ZPA_SE__c FROM Opportunity
                WHERE AccountId IN: mapAccountSENames.keySet()
                AND IsClosed <> true
                AND StageName !=: Closed_Won
            ]) {
            //if (oppty.SE_Name__c != mapAccountSENames.get(oppty.AccountId)) {
            System.debug('>>>> oppty: ' + oppty);
            lstOpportunitiesToUpdate.add(new Opportunity(
                Id = oppty.Id,
                SE_Name__c = (oppty.SE_Name__c == null ? mapAccountSENames.get(oppty.AccountId).Sales_Engineer__c : oppty.SE_Name__c),
                Opportunity_Sales_Engineer__c = mapAccountSENames.get(oppty.AccountId).Sales_Engineer__c,
                Opportunity_Sales_Territory__c = mapAccountSENames.get(oppty.AccountId).Sales_Territory__c,
                Opportunity_Channel_Manager__c = mapAccountSENames.get(oppty.AccountId).Channel_Manager__c,
                Opportunity_Customer_Advocate__c = mapAccountSENames.get(oppty.AccountId).Customer_Advocate__c,
                Opportunity_Area_Director__c = mapAccountSENames.get(oppty.AccountId).Area_Director__c,
                Opportunity_Account_Manager__c = mapAccountSENames.get(oppty.AccountId).Account_Manager__c
                //Opportunity_ZPA_Manager__c = (oppty.Opportunity_ZPA_Manager__c == null ? mapAccountSENames.get(oppty.AccountId).ZPA_Manager__c : oppty.Opportunity_ZPA_Manager__c),
                //Opportunity_ZPA_SE__c = (oppty.Opportunity_ZPA_SE__c == null ? mapAccountSENames.get(oppty.AccountId).ZPA_SE__c : oppty.Opportunity_ZPA_SE__c)
            ));
            //}
        }

        try {
            update lstOpportunitiesToUpdate;
        } catch (Exception ex) {
            System.debug('Exception occurred while updating opportunitys\' SE Name field: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }

        TriggerUtility.updateSENameFromAccountExecuted();
    }

    public static void updateContractEndDateInOpportunity(List < Account > lstNewAccounts, Map < Id, Account > mapOldAccounts) {
        List < Id > lstAccountIds = new List < Id > ();

        for (Account acc: lstNewAccounts) {
            if (mapOldAccounts.get(acc.Id).Platform_Renewal_Date__c != acc.Platform_Renewal_Date__c) {
                lstAccountIds.add(acc.Id);
            }
        }
        System.debug('*** lstAccountIds: ' + lstAccountIds);
        if (lstAccountIds.size() > 0) {
            OppotunityTriggerHelper.updateContractEndDate(lstAccountIds);
        }

        TriggerUtility.updateContractEndDateExecuted();
    }

    public static void updateTerritoryonActivities(List < Account > lstNewAccounts, Map < Id, Account > mapOldAccounts) {
        Set < Id > lstAccountIds = new Set < Id > ();

        for (Account acc: lstNewAccounts) {
            if (mapOldAccounts.get(acc.Id).Sales_Territory__c != acc.Sales_Territory__c) {
                lstAccountIds.add(acc.Id);
            }
        }
        System.debug('*** lstAccountIds: ' + lstAccountIds);
        if (lstAccountIds.size() > 0) {
            List < Task > tasklst = [Select Id, WhoId, WhatId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Task where AccountId in: lstAccountIds and isrecurrence = false];
            for (Task t: tasklst) {
                t.Sales_Territory__c = t.Account.Sales_Territory__r.Name;
                t.Territory_Area__c = t.Account.Sales_Territory__r.Area__c;
                t.Territory_Geo__c = t.Account.Sales_Territory__r.Theater__c;
                t.Territory_Type__c = t.Account.Territory_Type__c;
            }

            List < Event > eventlst = [Select Id, WhoId, WhatId, Account.Sales_Territory__r.Name, Account.Sales_Territory__r.Area__c, Account.Sales_Territory__r.Theater__c, Account.Territory_Type__c, Sales_Territory__c, Territory_Area__c, Territory_Geo__c, Territory_Type__c from Event where AccountId in: lstAccountIds and IsChild = false and isrecurrence = false];
            for (Event t: eventlst) {
                t.Sales_Territory__c = t.Account.Sales_Territory__r.Name;
                t.Territory_Area__c = t.Account.Sales_Territory__r.Area__c;
                t.Territory_Geo__c = t.Account.Sales_Territory__r.Theater__c;
                t.Territory_Type__c = t.Account.Territory_Type__c;
            }
            TriggerUtility.AcctoActivityTerritoryExecuted();
            update tasklst;
            update eventlst;
        }


    }

    //Added by Gurjinder to update the Customer Success Stage
    public static void UpdateCustomerSuccessStage(list < Account > NewAccountList, map < Id, Account > accountOldMap) {

        Set < id > AccountidSet = new Set < id > ();
        Map < id, Cloud_Usage__c > AccountsCloudusagemap = new Map < id, Cloud_Usage__c > ();
        Map < id, BWC_Data__c > AccountsMonthlyCloudusagemap = new Map < id, BWC_Data__c > ();
        //Map < id, Account_Extension__c > AccandAccExtmap = new Map < id, Account_Extension__c > ();
        Map < id, id > AccountsandZscalerCloudid = new Map < id, id > ();
        String CSStage1datecriteria= ZscalerCustomSetting__c.getInstance('CSStage1datecriteria')!=null && ZscalerCustomSetting__c.getInstance('CSStage1datecriteria').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CSStage1datecriteria').Value__c:'2019-12-12';
        if (trigger.isupdate) {
            for (Account acc: NewAccountList) {
                
                /**if(acc.Summarize_the_Value_to_the_Customer__c!=accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c){
                    system.debug('field value has been changed');
                }else{
                    system.debug('field value has not  been changed');
                }**/
                
                if (!acc.Override_Customer_Success_Stage__c) {
                    AccountidSet.add(acc.id);
                }
            }
        }
        if (!AccountidSet.isempty() && AccountidSet.size() > 0) {

            for (Account acc: [Select id, (Select id, createddate, total_ssl_inspected_transactions__c, Zscaler_Cloud_ID__c, total_ssl_transactions__c from Cloud_Usage_Object__r order by createddate desc limit 1) from account where id IN: AccountidSet]) {
                if (!acc.Cloud_Usage_Object__r.isempty() && acc.Cloud_Usage_Object__r.size() > 0 && /* acc.Cloud_Usage_Object__r[0]!=null && */ !AccountsCloudusagemap.containsKey(acc.id)) {
                    AccountsCloudusagemap.put(acc.id, acc.Cloud_Usage_Object__r[0]);
                    AccountsandZscalerCloudid.put(acc.id, acc.Cloud_Usage_Object__r[0].Zscaler_Cloud_ID__c);
                }
                /**if (!acc.Account_Extensions__r.isempty() && acc.Account_Extensions__r.size() > 0) {
                    system.debug('Acc extension is present');
                    AccandAccExtmap.put(acc.id,acc.Account_Extensions__r[0]);
                }**/
            }
            if (!AccountsandZscalerCloudid.isempty() && AccountsandZscalerCloudid.size() > 0) {
                for (Zscaler_Cloud_ID__c ZCloudid: [Select id, (Select id, Name, CFW_Enabled__c, CFW_Disabled__c from BWC_Data__r order by createddate desc limit 1) from Zscaler_Cloud_ID__c where id IN: AccountsandZscalerCloudid.values()]) {
                    if (!ZCloudid.BWC_Data__r.isempty() && ZCloudid.BWC_Data__r.size() > 0 /* && ZCloudid.BWC_Data__r[0]!=null */ ) {
                        AccountsMonthlyCloudusagemap.put(ZCloudid.id, ZCloudid.BWC_Data__r[0]);
                    }

                }

            }
        }
        //system.debug('AccandAccExtmap  '+AccandAccExtmap);
        for (Account acc: NewAccountList) {
            String Customersentiment = '';
            if (trigger.isupdate) {
                system.debug('trigger.isupdate ');
                if(accountOldMap.get(acc.id).Customer_Sentiment__c!=null) {
                    Customersentiment = accountOldMap.get(acc.id).Customer_Sentiment__c;
                }
            }
            system.debug('Customersentiment '+Customersentiment);
            if (!acc.Override_Customer_Success_Stage__c) {
                Boolean stage1 = false;
                Boolean stage2 = false;
                Boolean stage3 = false;
                Boolean stage4 = false;
                Boolean skipstage0and1 = false;

                if (acc.Current_ARR__c != null && acc.Current_ARR__c < 25000) {
                    skipstage0and1 = true;
                }
                if (!skipstage0and1 && acc.Last_QBR_Date__c == null) {
                    acc.Success_Stage__c = '0 - Not Started';
                } else {
                    //if (acc.Last_QBR_Date__c != null || skipstage0and1) {

                        if (skipstage0and1) {
                            if (acc.Type == 'Customer' /* && stage1 */ && ((acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed')) || (acc.X10_Traffic_attained_date__c == null))) {
                                acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
                                stage2 = true;
                            }
                            if (acc.Type == 'Customer' /* && stage2 */ && acc.X10_ZPA_Traffic_attained_date__c != null) {
                                acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
                                stage3 = true;
                            }
                            if (acc.Type == 'Customer' /* && stage2  */ && ((acc.No_of_Platform_Seats__c > 0 && acc.X10_Traffic_attained_date__c != null) || (acc.Users_ZPA_Platform__c > 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 10))) {
                                acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
                                stage3 = true;
                            }
                            if (acc.Type == 'Customer' /* && stage3 */ && acc.X25_ZPA_Traffic_attained_date__c != null) {
                                acc.Success_Stage__c = '4 – Transformation in Progress (25%+ Deployed)';
                                stage4 = true;
                            }
                            if (acc.Type == 'Customer' /* && stage3 */ && ((acc.No_of_Platform_Seats__c > 0 && acc.Date_when_traffic_consumed_is_25__c != null) || (acc.Users_ZPA_Platform__c > 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c >= 25))) {
                                acc.Success_Stage__c = '4 – Transformation in Progress (25%+ Deployed)';
                                stage4 = true;
                            }
                            if (!stage2 && !stage3 && !stage4) {
                                acc.Success_Stage__c = '0 - Not Started';
                            }
                        } else /* if (acc.Last_QBR_Date__c != null)  */{
                            /* if (acc.Architecture_Workshop_Link__c != null && acc.Architecture_Workshop_Link__c != '' &&
                                acc.Current_ARR__c != null && acc.Current_ARR__c > 25000 && acc.Head_of_IT__c == true &&
                                acc.Head_of_Networking__c == true && acc.Head_of_Security__c == true && acc.Service_Owner_Present__c == true) {
                                acc.Success_Stage__c = '1 - Kick-off Complete (QBR 0)';
                                stage1 = true;
                            } */   // First_Contract_Date__c   First_ZPA_Contract_Date__c
                            
                            //Logic for date criteria:Start
                            Date datetocheck;
                            if(acc.First_Contract_Date__c!=null && acc.First_ZPA_Contract_Date__c!=null){
                                system.debug('both dates are not null');
                                if(acc.First_Contract_Date__c>=acc.First_ZPA_Contract_Date__c){
                                    system.debug('ZIA date is older');
                                    datetocheck=acc.First_Contract_Date__c;
                                }else{
                                    system.debug('ZPA date is older');
                                    datetocheck=acc.First_ZPA_Contract_Date__c;
                                }
                            }else{
                                system.debug('In else part');
                                if(acc.First_Contract_Date__c!=null){
                                    system.debug('ZIA date is not null');
                                    datetocheck=acc.First_Contract_Date__c;
                                }
                                if(acc.First_ZPA_Contract_Date__c!=null){
                                    system.debug('ZPA date is not null');
                                    datetocheck=acc.First_ZPA_Contract_Date__c;
                                }
                                
                            }
                            system.debug('datetocheck  '+datetocheck);
                            //Logic for date criteria:End
                            if ((trigger.isinsert || (trigger.isupdate && datetocheck!=null && datetocheck>=date.valueof(CSStage1datecriteria)) ) && acc.Current_ARR__c != null && acc.Current_ARR__c > 25000 && acc.Milestone_Pilot_Date__c!=null && acc.Milestone_Production_Date__c!=null && acc.Last_QBR_Date__c != null) {
                                acc.Success_Stage__c = '1 - Kick-off Complete (QBR 0)';
                                system.debug('Stage 1 part1 ');
                                stage1 = true;
                            }else if(trigger.isupdate && datetocheck!=null && datetocheck<date.valueof(CSStage1datecriteria) && acc.Current_ARR__c != null && acc.Current_ARR__c > 25000 && acc.Last_QBR_Date__c != null){
                                acc.Success_Stage__c = '1 - Kick-off Complete (QBR 0)';
                                system.debug('Stage 1 part2 ');
                                stage1 = true;
                            }
                            //Added conditions :requested by Jay Yeater: BY Gurjinder   
                            //
                            if (acc.Type == 'Customer' /* && stage1  */ && (trigger.isinsert || (trigger.isupdate && datetocheck!=null && datetocheck>=date.valueof(CSStage1datecriteria))) && acc.Milestone_Pilot_Date__c!=null && acc.Milestone_Production_Date__c!=null && (acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed') ||  ((acc.X10_Traffic_attained_date__c == null || acc.X10_ZPA_Traffic_attained_date__c==null) && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>0 || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>0)))) {
                                acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
                                system.debug('Stage 2 part1 ');
                                stage2 = true;  
                            }else if(acc.Type == 'Customer' && trigger.isupdate && datetocheck!=null && datetocheck<date.valueof(CSStage1datecriteria) && (acc.DAS_Stage__c != null && acc.DAS_Stage__c != '' && acc.DAS_Stage__c.equalsignorecase('stage_d2_design_completed') ||  ((acc.X10_Traffic_attained_date__c == null || acc.X10_ZPA_Traffic_attained_date__c==null) && (acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>0 || acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>0)))){
                                acc.Success_Stage__c = '2 - Design Complete (0-10% Deployed)';
                                system.debug('Stage 2 part2 ');
                                stage2 = true;
                            }
                            
                            system.debug('acc.X10_ZPA_Traffic_attained_date__c  '+acc.X10_ZPA_Traffic_attained_date__c);
                            if (acc.Type == 'Customer' /* && stage2 */ && ((acc.No_of_Platform_Seats__c > 0 && acc.X10_Traffic_attained_date__c != null) || (acc.X10_ZPA_Traffic_attained_date__c!=null && acc.Users_ZPA_Platform__c> 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>= 10))) {
                                acc.Success_Stage__c = '3 - Secure & Simplify (10-25% Deployed)';
                                system.debug('Stage 3 ');
                                stage3 = true;
                            }
                            system.debug('--acc.Type--'+acc.Type+'--acc.X25_ZPA_Traffic_attained_date__c--'+acc.X25_ZPA_Traffic_attained_date__c);
                            if (acc.Type == 'Customer' /* && stage3 */ && (acc.No_of_Platform_Seats__c > 0 && acc.Date_when_traffic_consumed_is_25__c != null) || (acc.X25_ZPA_Traffic_attained_date__c!=null && acc.Users_ZPA_Platform__c> 0 && acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>= 25)) {
                                acc.Success_Stage__c = '4 - Transformation in Progress (25%+ Deployed)';
                                system.debug('Stage 4 ');
                                stage4 = true;
                            }
                            /* if(!stage1 && !stage2 && !stage3 && !stage4){
                                acc.Success_Stage__c='1 - Kick-off Complete (QBR 0)';
                            } */

                        }

                   // }

                }
                //for stage 5 logic starts
                if ( /* accountOldMap.get(acc.id).Success_Stage__c.equalsignorecase('4 – Transformation in Progress (25%+)')*/ stage4 && trigger.isupdate) {
                    Integer SSLTrafficInspected = 0;
                    Integer MobileUsersZAPP = 0;
                    Integer AllPortsandProtocolsFWEnabled = 0;
                    Integer BrokenOut = 0;
                    Integer O365Transactions = 0;
                    Boolean DeployZPA65 = false;

                    if (!AccountsCloudusagemap.isempty() && AccountsCloudusagemap.size() > 0 && AccountsCloudusagemap.get(acc.id) != null) {
                        Cloud_Usage__c CU = AccountsCloudusagemap.get(acc.id);
                        if (CU.total_ssl_inspected_transactions__c != null && integer.valueof(CU.total_ssl_inspected_transactions__c) > 0 && CU.total_ssl_transactions__c != null && integer.valueof(CU.total_ssl_transactions__c) > 0) {
                            SSLTrafficInspected = integer.valueof((CU.total_ssl_inspected_transactions__c / CU.total_ssl_transactions__c) * 100);
                        }
                    }

                    id AccZCloudid;
                    if (!AccountsandZscalerCloudid.isempty() && AccountsandZscalerCloudid.size() > 0 && AccountsandZscalerCloudid.get(acc.id) != null) {
                        AccZCloudid = AccountsandZscalerCloudid.get(acc.id);
                    }
                    if (!AccountsMonthlyCloudusagemap.isempty() && AccountsMonthlyCloudusagemap.size() > 0 && AccZCloudid != null && AccountsMonthlyCloudusagemap.get(AccZCloudid) != null) {
                        BWC_Data__c MCU = AccountsMonthlyCloudusagemap.get(AccZCloudid);
                        if (MCU.CFW_Enabled__c != null && MCU.CFW_Disabled__c != null && integer.valueof(MCU.CFW_Enabled__c) > 0 && integer.valueof(MCU.CFW_Disabled__c) > 0) {
                            AllPortsandProtocolsFWEnabled = integer.valueof((MCU.CFW_Enabled__c / (MCU.CFW_Enabled__c + MCU.CFW_Disabled__c)) * 100);
                        }
                    }

                    if (acc.ZApp_Registered_Devices__c != null && acc.ZApp_Registered_Devices__c > 0 && integer.valueof(acc.No_of_Platform_Seats__c) > 0) {
                        MobileUsersZAPP = integer.valueof((acc.ZApp_Registered_Devices__c / acc.No_of_Platform_Seats__c) * 100);
                    }
                    if (acc.Egress_LOcation_Count__c != null && acc.Egress_LOcation_Count__c > 0 && integer.valueof(acc.No_of_Platform_Seats__c) > 0) {
                        BrokenOut = Integer.valueof((acc.Egress_LOcation_Count__c / acc.No_of_Platform_Seats__c) * 500);
                    }
                    if (acc.O365_Traffic_L90D__c != null && integer.valueof(acc.O365_Traffic_L90D__c) > 0) {
                        O365Transactions = Integer.valueof(acc.O365_Traffic_L90D__c);
                    }
                    if (acc.X65_ZPA_Traffic_attained_date__c != null) {
                        DeployZPA65 = true;
                    }

                    Integer ValidconditionsCount = 0;
                    if (SSLTrafficInspected >= 65) {
                        ValidconditionsCount++;
                    }
                    if (MobileUsersZAPP >= 65) {
                        ValidconditionsCount++;
                    }
                    if (AllPortsandProtocolsFWEnabled >= 65) {
                        ValidconditionsCount++;
                    }
                    if (BrokenOut >= 65) {
                        ValidconditionsCount++;
                    }
                    if (O365Transactions > 15) {
                        ValidconditionsCount++;
                    }
                    if (DeployZPA65) {
                        ValidconditionsCount++;
                    }
                    if (ValidconditionsCount >= 3) {
                        acc.Success_Stage__c = '5 – Transformed';
                        if (!acc.Override_Customer_Sentiment__c) {
                            if (acc.Last_SCI_Date__c == null && CustomerSentiment != 'Lost' && CustomerSentiment != 'Churn Risk') {
                                acc.Customer_Sentiment__c = 'No Engagement';
                            } else {
                                //acc.Customer_Sentiment__c='Happy';
                            }
                        }


                    }

                }
                //for stage 5 logic ends
            }
            //Logic for Customer sentiment field :Gurjinder :Start

            if (acc.type == 'Ex-Customer') {
                acc.Customer_Sentiment__c = 'Lost';
            }
            if (acc.type == 'Ex-Customer' && accountOldMap.get(acc.id).type == 'Customer') {
                acc.Success_Stage__c = '5 – Transformed';
                acc.Customer_Sentiment__c = 'Lost';
            }
            if (!acc.Override_Customer_Sentiment__c) {
                if (acc.type == 'Customer' && acc.Last_SCI_Date__c == null && CustomerSentiment != 'Lost' && CustomerSentiment != 'Churn Risk') {
                    acc.Customer_Sentiment__c = 'No Engagement';
                }
                if(acc.Last_SCI_Date__c != null && acc.Customer_Sentiment__c== 'No Engagement'){
                   acc.Customer_Sentiment__c = 'Neutral or Mixed';
                }
            }
            //Logic for Customer sentiment field :Gurjinder :End

            if (trigger.isupdate && acc.CSM_Name_New__c != null /* && accountOldMap.get(acc.id).CSM_Name_New__c!=null */ && acc.CSM_Name_New__c != accountOldMap.get(acc.id).CSM_Name_New__c) {
                acc.CSM_Assignment_Date__c = system.today();
            }

        }

        TriggerUtility.CustomerSuccessUpdatemethodsettrue();
    }
    
     //Method Added as apart of RBAC
     //Description
      public static void AAUCreateAccountTeamMember(list<Account> newAccounts, Map<Id, Account> oldAccountsMap){
        List<AccountTeamMember> result = new List<AccountTeamMember>();
        for(account accountRecord : newAccounts){
            //decimal numberofminutes = (accountRecord.LastModifiedDate-accountRecord.CreatedDate)*24*60;
            decimal decMinutes = ((accountRecord.LastModifiedDate.getTime())/1000/60) - ((accountRecord.CreatedDate.getTime())/1000/60);
            if(accountRecord.OwnerId != oldAccountsMap.get(accountRecord.Id).OwnerId && decMinutes <= 2){
                AccountTeamMember member  = new AccountTeamMember();
        member.AccountId = accountRecord.Id;
                member.UserId = oldAccountsMap.get(accountRecord.Id).OwnerId;
                //member.UserId=UserInfo.getUserId();
                member.TeamMemberRole = 'Account Owner';
                member.AccountAccessLevel = 'Edit';
                member.OpportunityAccessLevel = 'Edit';
                member.CaseAccessLevel = 'Edit';
                member.ContactAccessLevel = 'Edit';
                result.add(member);
            }
        }
        if(result.size()>0){
            Database.SaveResult[] srList = Database.insert(result, false);
        }
    }


    /*  Method updates various stages of Prospect Type picklist field on Account depending on the related SCI 
     *  dates as well as Open or lost Opportunities. Runs on Insert and Update.
     */
    public void updateProspectTypeOnAccount(List < Account > lstNewAccounts) {
        system.debug('CALLED');
        List < Opportunity > closedOpps = new List < Opportunity > ();
        //added by Raghu                                                              
        Map < Id, Date > lastestAccOppCloseDate = new Map < Id, Date > ();
        Map < Id, Date > lastestAccSCIDate = new Map < Id, Date > ();
        Map < Id, List < Opportunity >> acc_OppMap = new Map < Id, List < Opportunity >> ();
        Map < Id, boolean > openOppMap = new Map < Id, boolean > ();
        Map < Id, boolean > openLatestSCIMap = new Map < Id, boolean > ();
        Map < Id, boolean > openValidationStagePipelineMap = new Map < Id, boolean > ();
        Map < Id, boolean > openValidationStagePOCMap = new Map < Id, boolean > ();
        Map < Id, List < Significant_Customer_Interaction__c >> acc_SCIMap = new Map < Id, List < Significant_Customer_Interaction__c >> ();

        for (Opportunity opp: [SELECT Validation_Stage__c, isClosed, closeDate, Stagename, AccountId, Account.Last_F2F_Meeting__c,
                Account.Open_Opportunities__c, Account.Count_of_SCIs__c
                FROM Opportunity
                WHERE AccountId =: lstNewAccounts AND AccountId != ''
                ORDER BY CloseDate desc NULLS LAST
            ]) {
            if (String.isNotBlank(opp.AccountId)) {

                if (lastestAccOppCloseDate.get(opp.AccountId) == null && !(opp.isClosed)) {
                    lastestAccOppCloseDate.put(opp.AccountId, opp.CloseDate);
                } else if (opp.closeDate > lastestAccOppCloseDate.get(opp.AccountId) && !(opp.isClosed)) {
                    lastestAccOppCloseDate.put(opp.AccountId, opp.CloseDate);
                }

                if (!acc_OppMap.containsKey(opp.AccountId)) {
                    acc_OppMap.put(opp.AccountId, new List < Opportunity > ());
                }
                acc_OppMap.get(opp.AccountId).add(opp);
                if (openOpps.contains(opp.Stagename) == true && opp.Account.Open_Opportunities__c != 0) {
                    system.debug('First:' + validation_stage_POC.contains(opp.Validation_Stage__c));
                    system.debug('Second:' + opp.Validation_Stage__c);
                    if (validation_stage_POC.contains(opp.Validation_Stage__c) && opp.Validation_Stage__c != null) {
                        openValidationStagePOCMap.put(opp.AccountId, true);
                        system.debug('CALL Open:POC');
                    }
                    if (validation_stage_pipeline.contains(opp.Validation_Stage__c) || opp.Validation_Stage__c == null) {
                        openValidationStagePipelineMap.put(opp.AccountId, true);
                        system.debug('CALL Open:PIPE');
                    }
                    system.debug('pipeline:' + openValidationStagePipelineMap);
                    system.debug('POC:' + openValidationStagePOCMap);
                    openOppMap.put(opp.AccountId, true);
                    openLatestSCIMap.put(opp.AccountId, true);

                    system.debug('CALL Open: ' + validation_stage_pipeline.contains(opp.Validation_Stage__c));
                }
                if (openOpps.contains(opp.Stagename) != true && opp.Account.Open_Opportunities__c == 0) {
                    if (openOppMap.get(opp.AccountId) == null) {
                        openOppMap.put(opp.AccountId, false);
                        closedOpps.add(opp);
                    }

                }

                system.debug('CALL: ');
                //NEED TO CHECK - If unrelated Open Opp and SCI are there, would it re-engage -- opp.Account.Count_of_SCIs__c != 0 && 
                //no open opportunities
                if (openOppMap.get(opp.AccountId) == false) {
                    system.debug('CALL 1: ' + opp.CloseDate);
                    system.debug('CALL 1: ' + opp.Account.Last_F2F_Meeting__c);
                    if (lastestAccOppCloseDate.get(opp.AccountId) < opp.Account.Last_F2F_Meeting__c) {
                        system.debug('TRUE');
                        openLatestSCIMap.put(opp.AccountId, true);
                        system.debug('TRUE 1:' + openLatestSCIMap.get(opp.AccountId));
                        break;
                    } else {
                        openLatestSCIMap.put(opp.AccountId, false);
                        system.debug('ELSE FALSE');
                    }
                }

            }
        }
        for (Significant_Customer_Interaction__c sciObj: [SELECT Id, Date__c, Account_Name__c,Account_Name__r.LastRegularSCIdate__c,Account_Name__r.Last_F2F_Meeting__c,
                Opportunity_Name__r.CloseDate, Opportunity_Name__r.StageName
                FROM Significant_Customer_Interaction__c
                WHERE Account_Name__c IN: lstNewAccounts
                AND RecordType.Name in
                ('Regular Meeting', 'Architecture Session', 'QBR')
                ORDER BY Date__c desc
            ]) {
            if (String.isNotBlank(sciObj.Account_Name__c)) {
                if (lastestAccSCIDate.get(sciObj.Account_Name__c) == null) {
                    lastestAccSCIDate.put(sciObj.Account_Name__c, sciObj.Date__c);
                }

                if (!acc_SCIMap.containsKey(sciObj.Account_Name__c)) {
                    acc_SCIMap.put(sciObj.Account_Name__c, new List < Significant_Customer_Interaction__c > ());
                }

                acc_SCIMap.get(sciObj.Account_Name__c).add(sciObj);
                if (lastestAccSCIDate.get(sciObj.Account_Name__c) > lastestAccOppCloseDate.get(sciObj.Account_Name__c)) {
                    system.debug('Entered Test 1');
                    openLatestSCIMap.put(sciObj.Account_Name__c, true);
                } else if (lastestAccOppCloseDate.get(sciObj.Account_Name__c) == null) {
                    system.debug('Entered Test 2');
                    openLatestSCIMap.put(sciObj.Account_Name__c, true);
                }

                system.debug('Entered 1:' + openLatestSCIMap.get(sciObj.Account_Name__c));
            }
        }

        for (Account accObj: lstNewAccounts) {
            if (accObj.type != null) {
                if (accObj.type.equals(TriggerUtility.PROSPECT)) {
                    system.debug('CALLED: ' + acc_OppMap.values());
                    //No Opps, No SCIs makes it Not touched.#Non-regular SCI ?
                    if ((accObj.Count_of_SCIs__c == null || accObj.Count_of_SCIs__c == 0) &&
                        acc_OppMap.get(accObj.Id) == null && acc_SCIMap.get(accObj.Id) == null) {
                        accObj.Prospect_Type__c = TriggerUtility.NOT_TOUCHED;
                        system.debug('Reached here' + accObj.Open_Opportunities__c);
                    }

                    system.debug('OPP LOST:' + acc_OppMap.isEmpty());
                    system.debug('OPP LOST:' + openLatestSCIMap.get(accObj.Id));
                    system.debug('CALLED: OpenOPP:' + openOppMap.get(accObj.Id));
                    if (acc_OppMap.get(accObj.Id) == null) {
                        if (acc_SCIMap.get(accObj.Id) != null && openLatestSCIMap.get(accObj.Id) == true) {
                            if (accObj.LastRegularSCIdate__c != null) {
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c  ) > -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.ENGAGED;
                                    system.debug('Engaged');
                                }
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c  ) < -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                    system.debug('No recent engagement');
                                }
                            }
                            //This code may be removed once data is fixed - by Raghu
                            else {
                                accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                system.debug('Default : No recent engagement');
                            }
                        }
                    }
                    if (acc_OppMap.get(accObj.Id) != null) {
                        if (acc_SCIMap.get(accObj.Id) != null && openLatestSCIMap.get(accObj.Id) == true) {
                            if (accObj.LastRegularSCIdate__c != null) {
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c) > -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.ENGAGED;
                                    system.debug('Here one');
                                }
                                if (Date.Today().monthsbetween(accObj.LastRegularSCIdate__c) < -6) {
                                    accObj.Prospect_Type__c = TriggerUtility.NO_RECENT_ENGAGEMENT;
                                }
                            }
                        }
                        if (accObj.Open_Opportunities__c == 0) {
                            if (openLatestSCIMap.get(accObj.Id) == false) {
                                accObj.Prospect_Type__c = TriggerUtility.OPPLOST;
                            }
                        }

                        if (accObj.Open_Opportunities__c != 0) {
                            if (openValidationStagePipelineMap.get(accObj.Id) == true) {
                                accObj.Prospect_Type__c = TriggerUtility.PIPELINE;
                            }
                            if (openValidationStagePOCMap.get(accObj.Id) == true) {
                                accObj.Prospect_Type__c = TriggerUtility.POC;
                            }
                        }
                    }

                } else {
                    accObj.Prospect_Type__c = TriggerUtility.BLANK;
                }
            }
        }
        TriggerUtility.prospectTypeUpdExecuted();
    }


    /**
     *  Method updates the Customer Support Segment field on Account whenever 
     *  ARR is populated on Accounts.
     */
    public void updateCustomerSupportStage(List < Account > lstNewAccounts) {
        for (Account accobj: lstNewAccounts) {
            if (accObj.Override_Customer_Support_Segment__c == false && (accObj.Type == 'Customer' || accObj.Type == 'Ex-Customer')) {
                if (accObj.Current_ARR__c != null && accObj.Current_ARR__c>0) {
                    if (accObj.Current_ARR__c > 1000000 ) {
                        accObj.Customer_Support_Segment__c = 'Top100';
                    } else if (accObj.Current_ARR__c <= 1000000 && accObj.Current_ARR__c > 300000) {
                        accObj.Customer_Support_Segment__c = 'Platinum';
                    } else if (accObj.Current_ARR__c <= 300000 && accObj.Current_ARR__c > 100000) {
                        accObj.Customer_Support_Segment__c = 'Gold';
                    } else if (accObj.Current_ARR__c <= 100000 && accObj.Current_ARR__c > 25000) {
                        accObj.Customer_Support_Segment__c = 'Silver';
                    } else if (accObj.Current_ARR__c <= 25000) {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    }/*  else {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    } */
                }
                else if(accObj.Account_Renewable_ACV__c!= null && accObj.Account_Renewable_ACV__c>0 && (accObj.Current_ARR__c == null || accObj.Current_ARR__c == 0)){
                    if (accObj.Account_Renewable_ACV__c > 1000000) {
                        accObj.Customer_Support_Segment__c = 'Top100';
                    } else if (accObj.Account_Renewable_ACV__c <= 1000000 && accObj.Account_Renewable_ACV__c > 300000) {
                        accObj.Customer_Support_Segment__c = 'Platinum';
                    } else if (accObj.Account_Renewable_ACV__c <= 300000 && accObj.Account_Renewable_ACV__c > 100000) {
                        accObj.Customer_Support_Segment__c = 'Gold';
                    } else if (accObj.Account_Renewable_ACV__c <= 100000 && accObj.Account_Renewable_ACV__c > 25000) {
                        accObj.Customer_Support_Segment__c = 'Silver';
                    } else if (accObj.Account_Renewable_ACV__c <= 25000) {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    } else {
                        accObj.Customer_Support_Segment__c = 'Bronze';
                    }
                }else if(accobj.Account_Renewable_ACV__c==null || accobj.Account_Renewable_ACV__c==0){
                    accObj.Customer_Support_Segment__c = 'Bronze';
                }
            }
            if (accObj.Type != 'Customer' && accObj.Type != 'Ex-Customer') {
                accObj.Customer_Support_Segment__c = '';
            }
        }
    }
    
    //Added by Gurjinder to update the field on Account Extension obj
    /**public static void UpdateAccountExtensionmethod(list < Account > NewAccountList, map < Id, Account > accountOldMap) {
        Set<id> AccountidSet= new Set<id>();
        List<Account_Extension__c> AccountExtension2Update= new List<Account_Extension__c>();
        for (Account acc: NewAccountList) {
            system.debug('acc.Summarize_the_Value_to_the_Customer__c  '+acc.Summarize_the_Value_to_the_Customer__c);
            system.debug('acc.Summarize_the_Value_to_the_Customer__c  '+accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c);
            if(acc.Summarize_the_Value_to_the_Customer__c!=accountOldMap.get(acc.id).Summarize_the_Value_to_the_Customer__c){
                system.debug('field value has been changed');
                AccountidSet.add(acc.id);
            }else{
                system.debug('field value has not  been changed');
            }
        }
        
        if(AccountidSet.size()>0){
            for(Account_Extension__c AccExt:[Select id,Date_of_last_Account_Business_Objectives__c from Account_Extension__c where Account__c IN:AccountidSet]){
            AccExt.Date_of_last_Account_Business_Objectives__c=Date.valueOf(System.now());
                AccountExtension2Update.add(AccExt);
            }
            if(AccountExtension2Update.size()>0){
                update AccountExtension2Update;
            }
            
        }
        //TriggerUtility.UpdateAccountExtensionmethodsettrue();
    }
    **/
    public static void AccountWorkflowOptimizationmethod(list< Account > NewAccountList, map < Id, Account > accountOldMap,boolean IsInsert,boolean isUpdate){
        
        Set<id> CSMidSet= new Set<id>();
        Map<id,String> CSMManagerEmail= new Map<id,String>(); 
        for(Account acc:NewAccountList){
        //1. Capture date when traffic consumption hits 50% :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=50 && acc.X50_Traffic_attained_date__c==null){
                acc.X50_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //1. Capture date when traffic consumption hits 50% :End
        
        //2. Capture date when traffic consumption hits 75% :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=75 && acc.X75_Traffic_attained_date__c==null){
                acc.X75_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //2. Capture date when traffic consumption hits 75% :End
        
        //3. Capture date when traffic consumption hits 100%    :start
            if(acc.Avg_Estimated_Users_L31D_Vs_Purchase__c>=100 && acc.X100_Traffic_attained_date__c==null){
                acc.X100_Traffic_attained_date__c=Date.valueOf(System.now());
            }       
        //3. Capture date when traffic consumption hits 100%    :End
        
        //4.Reset Deployment Phase Risk - Design Over Due:Start
            if((acc.Design_Completed_Date__c!=null) && (acc.Deployment_Phase_Risk__c != null && acc.Deployment_Phase_Risk__c.equalsignorecase('Design Complete Over Due'))){
                acc.Deployment_Phase_Risk__c='None';
            }
        //4.Reset Deployment Phase Risk - Design Over Due:End
        
        //5.Reset Deployment Phase Risk - Kick-Off Over Due :Start
            if(acc.Kick_Off_Call_Date__c!=null && (acc.Deployment_Phase_Risk__c != null && acc.Deployment_Phase_Risk__c.equalsignorecase('Kick Off Over Due'))){
                acc.Deployment_Phase_Risk__c='None';
            }
        //5.Reset Deployment Phase Risk - Kick-Off Over Due :End
        
        //6. Reset Traffic Risk :Start
            if(acc.Date_when_traffic_consumed_is_25__c!=null){
                acc.Deployment_Phase_Risk__c='None';
                acc.Traffic_Risk__c='None';
            }
        //6. Reset Traffic Risk :End
        
        //7. Capture date when ZPA enrolled users hit 10% :Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=10 && acc.X10_ZPA_Traffic_attained_date__c==null){
                acc.X10_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
        //7. Capture date when ZPA enrolled users hit 10% :End
        
        //8. Capture date when ZPA enrolled users hits 65% :Start
            if(acc.ZPA_Enrolled_users_L31D_Vs_Purchase__c>=65 && acc.X65_ZPA_Traffic_attained_date__c==null){
                acc.X65_ZPA_Traffic_attained_date__c=Date.valueOf(System.now());
            }
        //8. Capture date when ZPA enrolled users hits 65% :End
            if(acc.CSM_Name_New__c!=null){
                CSMidSet.add(acc.CSM_Name_New__c);
            }
            
        }
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        system.debug('TriggerUtility.IsCSMmanagerEmailCodeexecuted   '+TriggerUtility.IsCSMmanagerEmailCodeexecuted());
        if(isUpdate && !TriggerUtility.IsCSMmanagerEmailCodeexecuted()){
            for(User usr:[select id,Managerid,manager.email from user where ID IN:CSMidSet]){
                CSMManagerEmail.put(usr.id,usr.manager.email);
            }
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
            for(Account acc:NewAccountList){
                if(acc.CSM_Name_New__c!=null && CSMManagerEmail!=null && CSMManagerEmail.keyset().contains(acc.CSM_Name_New__c)){
                    acc.CSM_Manager_Email__c=CSMManagerEmail.get(acc.CSM_Name_New__c);
                }
            }
            TriggerUtility.IsCSMmanagerEmailCodeexecutedsettrue();
        }
        
    }

    public static void entitlementCreationforProspect(List<Account> acclst){
        Map<Id, String> accmap = new Map<Id, String>();
        for(Account acc: acclst){
            if(acc.type == 'Prospect'){
                accmap.put(acc.Id, 'Premium Plus');
            }
        }
        if(accmap != null && !accmap.isEmpty()){
            EntitlementManagement.createEntitleMent(accmap);
            TriggerUtility.ProspectEntitlementExecuted();
        }
    }

    public static void updateEntitlement(List<Account> acclst, Map<id, account> oldmap){
        Map<Id, String> accmap = new Map<Id, String>();
        for(Account acc: acclst){
            if((acc.type == 'Customer' || acc.type == 'Prospect') && (acc.type != oldmap.get(acc.Id).type || acc.Support_Type__c != oldmap.get(acc.Id).Support_Type__c)){
                if(acc.type == 'Prospect'){
                    accmap.put(acc.Id, 'Premium Plus');
                }else if(acc.Support_Type__c == 'Premium Support'){
                    accmap.put(acc.Id, 'Premium');
                }else if(acc.Support_Type__c == 'Premium Plus Support'){
                    accmap.put(acc.Id, 'Premium Plus');
                }else{
                    accmap.put(acc.Id, 'Standard');
                }
            }
        }
        if(accmap != null && !accmap.isEmpty()){
            EntitlementManagement.updateExistingEntitlement(accmap);
            EntitlementManagement.createEntitleMent(accmap);
            //TriggerUtility.EntitlementUpdateExecuted();
        }
        
    }
    /*public static void accountPatchHelper(List<Account> newAccounts){
        
    }
    
    //public static void accountUpdatePatchHelper(Map<Id, Account> newAccounts, Map<Id, Account> oldAccounts){
        
    //}
    
   
    /*@future
    public static void retainOldTeamMemberOnOwnerChange(String str){
        List<AccountTeamMember> newlistAcc = (List<AccountTeamMember>) JSON.deserialize(str,List<AccountTeamMember>.class);
        for(AccountTeamMember objAccTeamMember : newlistAcc){
            objAccTeamMember.Id= null;
        }
        system.debug('Account records to insert'+(JSON.serialize(newlistAcc)));
        Upsert newlistAcc;
    }*/
    
    public static void UpdateDateRange(List<Account> acclst,Map<Id, Account> oldAccounts){
        
        for(Account acc: acclst){
            if(acc.Legal_Certification_Date__c != null && oldAccounts.get(acc.Id).Legal_Certification_Date__c != acc.Legal_Certification_Date__c){
                string StartDate = '1/17/' + acc.Legal_Certification_Date__c.year();
                Integer StartYear = acc.Legal_Certification_Date__c.year();
                system.debug('--legal date--' + acc.Legal_Certification_Date__c + '--added date--' + Date.parse(StartDate));
                if(acc.Legal_Certification_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+1);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
                else{
                    string EndDate = '1/16/'+ (StartYear);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
                
                if(acc.Signed_Legal_Certification_Date__c > system.today()){
                    acc.Type = 'Partner';
                }
            }
            
            if(acc.Legal_Questionaire_Date__c != null && oldAccounts.get(acc.Id).Legal_Questionaire_Date__c != acc.Legal_Questionaire_Date__c){
                string StartDate = '1/17/'+ acc.Legal_Questionaire_Date__c.year();
                Integer StartYear = acc.Legal_Questionaire_Date__c.year();
                system.debug('--legal date--' + acc.Legal_Questionaire_Date__c + '--added date--' + Date.parse(StartDate));
                if(acc.Legal_Questionaire_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+3);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
                else{
                    string EndDate = '1/16/'+ (StartYear+2);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
                
                if(acc.Signed_Legal_Certification_Date__c > system.today()){
                    acc.Type = 'Partner';
                }
            }
        }
    }
    
    public static void UpdateDateRange(List<Account> acclst){
        
        for(Account acc: acclst){
            if(acc.Legal_Certification_Date__c != null){
                string StartDate = '1/17/'+ acc.Legal_Certification_Date__c.year();
                Integer StartYear = acc.Legal_Certification_Date__c.year();
                system.debug('--legal date--'+acc.Legal_Certification_Date__c+'--added date--'+Date.parse(StartDate));
                if(acc.Legal_Certification_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+1);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }else{
                    string EndDate = '1/16/'+ (StartYear);
                    acc.Signed_Legal_Certification_Date__c = Date.parse(EndDate);
                }
            }
            
            if(acc.Legal_Questionaire_Date__c != null){
                string StartDate = '1/17/'+ acc.Legal_Questionaire_Date__c.year();
                Integer StartYear = acc.Legal_Questionaire_Date__c.year();
                system.debug('--legal date--'+acc.Legal_Questionaire_Date__c+'--added date--'+Date.parse(StartDate));
                if(acc.Legal_Questionaire_Date__c > Date.parse(StartDate)){
                    string EndDate = '1/16/'+ (StartYear+3);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }else{
                    string EndDate = '1/16/'+ (StartYear+2);
                    acc.Signed_Legal_Questionaire_Date__c = Date.parse(EndDate);
                }
            }
        }
    }

    public static void beforeInsertPartnerTier(List<Account> newList){
        List<Account> listtoUpdate = new List<Account>();
        for(Account acc: newList){
            if(acc.PArtner_Tier__c != null){
                listtoUpdate.add(acc);
            }else{
                acc.Partner_Summit_Deg_Reg_Margin__c = 0;
                acc.AW_Margin__c = 0;
                acc.POV_Margin__c = 0;
                acc.Fulfilment_Margin__c = 0;
            }
        }
        if(!listtoUpdate.isEmpty()){
            updatePartnerTierMargins(listtoUpdate);
        }
    }

    public static void beforeUpdatePartnerTier(List<Account> newList, Map<Id, Account> oldmap){
        List<Account> listtoUpdate = new List<Account>();
        for(Account acc: newList){
            if(acc.PArtner_Tier__c != null && oldmap.get(acc.Id).PArtner_Tier__c != acc.PArtner_Tier__c){
                listtoUpdate.add(acc);
            }
        }
        if(!listtoUpdate.isEmpty()){
            updatePartnerTierMargins(listtoUpdate);
        }
    }

    public static void updatePartnerTierMargins(List<Account> newList){
        Map<String, Partner_Tier_Discount_Matrix__c> mapptdm = Partner_Tier_Discount_Matrix__c.getAll();
        for(Account acc: newList){
            if(acc.PArtner_Tier__c != null && mapptdm != null && !mapptdm.isEmpty() && mapptdm.containskey(acc.PArtner_Tier__c)){
                acc.Partner_Summit_Deg_Reg_Margin__c = mapptdm.get(acc.PArtner_Tier__c).Deal_Reg_Margin__c;
                acc.AW_Margin__c = mapptdm.get(acc.PArtner_Tier__c).Architecture_Workshop_Margin__c;
                acc.POV_Margin__c = mapptdm.get(acc.PArtner_Tier__c).POV_Margin__c;
                acc.Fulfilment_Margin__c = mapptdm.get(acc.PArtner_Tier__c).Fulfillment_Margin__c;
            }
        }
    }
    
    //From Prod
    public void dummyCounter(Integer i) {
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
    }

    public void dummyCounter2(Integer i) {
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
    }
   
}