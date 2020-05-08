public class contactsPostPatchBatch implements Database.Batchable<SObject>,Database.Stateful {
    
    public List<Id> recordIds;
    
    public contactsPostPatchBatch(List<Id> patchIds){
        this.recordIds = patchIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //String testAccountId = '0017000000bOBdY';
        //return Database.getQueryLocator('Select Id from Contact Where AccountId =: testAccountId');
        if(recordIds != null && recordIds.size() > 0){
            return Database.getQueryLocator('Select Id from Contact Where Account.Patch__c IN: recordIds');
        }
        else{
            return Database.getQueryLocator('Select Id from Contact');
        }
    }
    
    public void execute(Database.BatchableContext context, Contact[] contacts) {
        
        TriggerUtility.isPatchRealigning();
        map<Id, id> accIdSalesTerritoryIdMap = new map<Id, Id>();
        map<id, SalesTeam> salesTerIdSalesTeamMap = new map<id, SalesTeam>();
        set<Id> salesTerritoryIdSet = new set<Id>();
        
        contacts = [Select Id, 
                            OwnerId, 
                            Account.OwnerId,
                            Account.Patch__c,
                            Account.Patch__r.PatchTeam__c,
                            Account_Manager__c,
                            Channel_Manager__c,
                            Customer_Advocate__c,
                            Sales_Engineer__c,
                            Lead_Development__c,
                            ZPA_Manager__c,
                            ZPA_SE__c,
                            ZPA_Manager_Email__c,
                            ZPA_SE_Email__c,
                            Patch__c
                            from 
                            Contact 
                            Where 
                            ID IN: contacts];
        
        Set<Id> accountOwnerIds = new Set<Id>();
        Set<Id> activeUserIdSet = new Set<Id>();
        system.debug('----------'+contacts);
        for(Contact contactRec : contacts){
            if(contactRec.Account.Patch__c != null && contactRec.Account.Patch__r.PatchTeam__c != null){
                accIdSalesTerritoryIdMap.put(contactRec.AccountId, contactRec.Account.Patch__r.PatchTeam__c);
                salesTerritoryIdSet.add(contactRec.Account.Patch__r.PatchTeam__c);
            }
            accountOwnerIds.add(contactRec.Account.OwnerId);
        }
        
        for(User usr: [select id from user where isActive =: true and ID IN: accountOwnerIds]){
            activeUserIdSet.add(usr.Id);
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
            
            for(Contact con : contacts){
                if(Con.AccountId != null ){
                    if(activeUserIdSet.contains(con.Account.OwnerId)){
                        con.OwnerId = con.Account.OwnerId;
                    }
                    if(con.Account.Patch__c != null){
                        con.Patch__c  = con.Account.Patch__c;
                    }
                    else{
                        con.Patch__c = null;
                        con.Account_Manager__c = null;
                        con.Channel_Manager__c = null;
                        con.Customer_Advocate__c = null;
                        con.Sales_Engineer__c = null;
                        con.Lead_Development__c = null;
                        con.ZPA_Manager__c = null;
                        con.ZPA_SE__c = null;
                        con.ZPA_Manager_Email__c = null;
                        con.ZPA_SE_Email__c = null;
                    }
                    
                    if(accIdSalesTerritoryIdMap.containsKey(Con.AccountId)){
                        con.Territory__c = accIdSalesTerritoryIdMap.get(Con.AccountId);
                    }
                    else{
                        con.Territory__c = null;
                    }
                    
                    if(salesTerIdSalesTeamMap.containsKey(accIdSalesTerritoryIdMap.get(Con.AccountId))){
                        con.Account_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).accountManager;
                        con.Sales_Engineer__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).salesEngineer;
                        con.Customer_Advocate__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).customerAdvocate;
                        con.Channel_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).channelManager;
                        con.Lead_Development__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).leadDevelopment;
                        con.ZPA_Manager__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).ZPAManager;
                        if(con.ZPA_Manager__c != null){
                            con.ZPA_Manager_Email__c = userIdEmailMap.get(con.ZPA_Manager__c);
                        }
                        con.ZPA_SE__c = salesTerIdSalesTeamMap.get(accIdSalesTerritoryIdMap.get(Con.AccountId)).ZPASe;
                        if(con.ZPA_SE__c != null){
                            con.ZPA_SE_Email__c = userIdEmailMap.get(con.ZPA_SE__c);
                        }
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
        }
        
        if(contacts.isEmpty()){
            update contacts;
            list<CampaignMember> campMemUpdateList = new list<CampaignMember>();
            for(CampaignMember camp : [Select id, Territory__c, ContactId, Contact.Territory__c from CampaignMember where ContactId IN: contacts]){
                camp.TerriTory__c = camp.Contact.Territory__c;
                campMemUpdateList.add(camp);    
            }
            if(!campMemUpdateList.isEmpty()){
                update campMemUpdateList;
            }
        }
        TriggerUtility.realignPatchReset();
    }
    
    public void finish(Database.BatchableContext context) {
        if(!Test.isRunningTest()){
            Database.executeBatch(new opportunitiesPostPatchBatch(recordIds), 10);
        }
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