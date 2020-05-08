/*****************************************************************************************
Name: ContactPatchManager
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Class to get the patch detail on Contact.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            13-Nov-2015    Initial Development
******************************************************************************************/ 


Public class ContactPatchManager{

    /**
    *@purpose : Method to capture patch information on contact
    *@param : New List of contact.
    *@return : None
    **/
    public static void getPatchInformation(list<Contact> newContactList){
        map<Id, id> accIdPatchIdMap = new map<Id, Id>();
        map<Id, id> accIdSalesTerritoryIdMap = new map<Id, Id>();
        map<id, SalesTeam> salesTerIdSalesTeamMap = new map<id, SalesTeam>();
        set<Id> accIdSet = new set<Id>();
        set<Id> salesTerritoryIdSet = new set<Id>();
        try{
        for(Contact con : newContactList){
            if(con.AccountId != null){
               accIdSet.add(con.AccountId);
            }
        }
        
        for(Account acc : [Select Id, Patch__c, Patch__r.PatchTeam__c from Account Where Id IN: accIdSet AND Patch__c != null]){
            accIdPatchIdMap.put(acc.id, acc.Patch__c);
            if( acc.Patch__c != null && acc.Patch__r.PatchTeam__c != null){
                accIdSalesTerritoryIdMap.put(acc.Id, acc.Patch__r.PatchTeam__c);
                salesTerritoryIdSet.add(acc.Patch__r.PatchTeam__c);
            }    
        }
        
        
        if(!salesTerritoryIdSet.isEmpty()){
            for(PatchTeamMember__c salesTeamMember : [ select id, PatchTeam__c, Role__c, User__c from PatchTeamMember__c where PatchTeam__c IN: salesTerritoryIdSet]){
                if(salesTerIdSalesTeamMap.containsKey(salesTeamMember.PatchTeam__c))
                    salesTerIdSalesTeamMap.put(salesTeamMember.PatchTeam__c, new salesTeam(salesTerIdSalesTeamMap.get(salesTeamMember.PatchTeam__c), salesTeamMember));
                else
                    salesTerIdSalesTeamMap.put(salesTeamMember.PatchTeam__c, new SalesTeam(salesTeamMember));        
            }
            set<Id> userIdSet = new set<Id>();
            for(SalesTeam st: salesTerIdSalesTeamMap.Values()){
                if(st.ZPAManager != null)
                    userIdSet.add(st.ZPAManager);
                if(st.ZPASe != null)
                    userIdSet.add(st.ZPASe);
            }
            map<Id, String> userIdEmailMap = new map<Id, String>();
            for(User usr : [Select Id, Email from User where Id IN: userIdSet]){
                userIdEmailMap.put(usr.Id, usr.Email);
            }
            for(Contact con : newContactList){
                if(Con.AccountId != null ){
                    con.Patch__c = accIdPatchIdMap.get(Con.AccountId);
                    if(accIdSalesTerritoryIdMap.containsKey(Con.AccountId))
                        con.Territory__c = accIdSalesTerritoryIdMap.get(Con.AccountId);
                    else
                        con.Territory__c = null;
                    if(salesTerIdSalesTeamMap.containsKey(accIdSalesTerritoryIdMap.get(Con.AccountId))){
                        con.Account_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).accountManager;
                        con.Sales_Engineer__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).salesEngineer;
                        con.Customer_Advocate__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).customerAdvocate;
                        con.Channel_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).channelManager;
                        con.Lead_Development__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).leadDevelopment;
                        con.ZPA_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).ZPAManager;
                        if(con.ZPA_Manager__c != null)
                            con.ZPA_Manager_Email__c = userIdEmailMap.get(con.ZPA_Manager__c);
                        con.ZPA_SE__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).ZPASe;
                        if(con.ZPA_SE__c != null)
                            con.ZPA_SE_Email__c = userIdEmailMap.get(con.ZPA_SE__c);
                    }else{
                        con.Account_Manager__c = null;
                        con.Sales_Engineer__c = null;
                        con.Customer_Advocate__c = null;
                        con.Channel_Manager__c = null;
                        con.Lead_Development__c = null;
                        con.ZPA_Manager__c = null;
                        con.ZPA_SE__c = null;
                        con.ZPA_Manager_Email__c = null;
                        con.ZPA_SE_Email__c = null;
                    }
                }
            }
            TriggerUtility.contactPatchManagerExecuted();
       }
       }catch(Exception e){}

    }
    
    public class SalesTeam{
        public string accountManager {get; set;}
        public string salesEngineer {get; set;}
        public string customerAdvocate {get; set;}
        public string channelManager {get; set;}
        public string leadDevelopment {get; set;}
        public string ZPAManager {get; set;}
        public string ZPASe {get; set;}
        
        public SalesTeam(SalesTeam salsTeam, PatchTeamMember__c salesTeamMember){
            this.accountManager = salsTeam.accountManager;
            this.salesEngineer = salsTeam.salesEngineer;
            this.leadDevelopment = salsTeam.leadDevelopment;
            this.customerAdvocate = salsTeam.customerAdvocate;
            this.channelManager = salsTeam.channelManager;
            this.ZPAManager = salsTeam.ZPAManager;
            this.ZPASe = salsTeam.ZPASe;
            
            if(salesTeamMember.Role__c == 'Account Manager')
                this.accountManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Sales Engineer' )
                this.salesEngineer = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Lead Development' )
                this.leadDevelopment = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Customer Advocate' )
                this.customerAdvocate = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Channel Manager' )
                this.channelManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'ZPA Manager' )
                this.ZPAManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'ZPA SE' )
                this.ZPASe = salesTeamMember.User__c;
        }
        
        public SalesTeam(PatchTeamMember__c salesTeamMember){
            if(salesTeamMember.Role__c == 'Account Manager')
                this.accountManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Sales Engineer')
                this.salesEngineer = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Lead Development')
                this.leadDevelopment = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Customer Advocate')
                this.customerAdvocate = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'Channel Manager')
                this.channelManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'ZPA Manager')
                this.ZPAManager = salesTeamMember.User__c;
            if(salesTeamMember.Role__c == 'ZPA SE')
                this.ZPASe = salesTeamMember.User__c;
        
        }
    }
}