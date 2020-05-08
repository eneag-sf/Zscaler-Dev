@RestResource(urlMapping='/SCISYNC/*')
global with sharing class SCISYNC {

    @HttpPost
    global static Map<String, String> doPost(Map<String,Account> acclst,
        List<Opportunity> opptylst, List<Partner> oppartlst, Boolean isparentUPsame, List<Significant_Customer_Interaction__c> scilst, List<SCI_Zscaler_Attendee__c> scizscaleratt, List<SCI_External_Attendee__c> sciextatt) {
        Map<String, String> mapresult = new Map<String, String>();
        List<Account> acclsttoupsert = new List<Account>();
        List<Account> acclsttoupdate = new List<Account>();
        if(acclst != null){
            Set<Id> accids = new set<Id>();
            Map<Id, Account> mapprodAccdetails = new Map<Id, Account>();
            for(Account acc: acclst.values()){
                accids.add(acc.Id);
                accids.add(acc.ParentId);
                accids.add(acc.Ultimate_Parent_Account__c);
            }
            for(Account acc: [Select Id, Name from Account where Id in :accids]){
                accids.remove(acc.Id);
                mapprodAccdetails.put(acc.Id, acc);
            }
            for(Account acc: acclst.values()){
                if(acc.recordtypeId != null && Schema.SObjectType.Account.RecordTypeInfosByName.containskey(acc.RecordType.Name)){
                    acc.RecordtypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get(acc.RecordType.Name).RecordTypeId;
                }
                acc.PatchLocked__c  = true;
                if(accids.contains(acc.Id)){
                    acc.Id = null;
                }
                if(accids.contains(acc.ParentId)){
                    acc.ParentId = null;
                }
                if(accids.contains(acc.Ultimate_Parent_Account__c)){
                    acc.Ultimate_Parent_Account__c = null;
                }
                //if not a partner account, enable federal acct sync and add it to be upserted
                //otherwise disable federal acct sync, and update name/type
                if(acc.RecordType.Name != 'Partner'){
                    acc.Is_Federal_Account_Sync__c = true;
                    acclsttoupsert.add(acc);
                }else{
                    acc.Is_Federal_Account_Sync__c = false;
                    acc.Name = mapprodAccdetails != null && mapprodAccdetails.containskey(acc.Id) ? mapprodAccdetails.get(acc.Id).Name : acc.name;
                    acc.Type = 'Partner';
                }
            }
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();
            
            upsert acclsttoupsert;
            
            for(string s: acclst.keyset()){
                if(acclst.get(s) != null){
                    mapresult.put(s,acclst.get(s).Id);
                    if(acclst.get(s).type != 'Partner'){
                        acclsttoupdate.add(acclst.get(s));
                    }
                }
                
                if((s == 'Parent' || s == 'Account') && acclst.get(s) != null){
                        
                    if(acclst.get(s).ParentId == null){
                        String s1 = s == 'Parent'? 'Ultimate Parent':'Parent';
                        if(acclst.containskey(s1) && acclst.get(s1) != null){
                            acclst.get(s).ParentId = acclst.get(s1).Id;
                        }
                    }
                    if(acclst.containskey('Ultimate Parent') && acclst.get('Ultimate Parent') != null && acclst.get(s).Ultimate_Parent_Account__c == null){
                        acclst.get(s).Ultimate_Parent_Account__c = acclst.get('Ultimate Parent').Id;
                    }else if(isparentUPsame && s != 'Parent' && acclst.get(s).Ultimate_Parent_Account__c == null && acclst.containskey('Parent') && acclst.get('Parent') != null){
                        acclst.get(s).Ultimate_Parent_Account__c = acclst.get('Parent').Id;
                    }
                }
            }
            update acclsttoupdate;
            
            if(!opptylst.isEmpty()){
                for(Opportunity opp: opptylst){
                    if(opp.recordtypeid != null && Schema.SObjectType.Opportunity.RecordTypeInfosByName.containskey(opp.RecordType.Name)){
                        opp.RecordtypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get(opp.RecordType.Name).RecordTypeId;
                    }
                    //validate the received account list
                    if(acclst != null && acclst.containskey('Account') && acclst.get('Account') != null){
                        //update the Opportunities related Account
                        Account relatedAccount = acclst.get('Account');
                        opp.AccountId = relatedAccount.Id;

                        //We don't sync Opps with Fed for Partner accounts
                        opp.Is_Federal_Opportunity_Sync__c = (relatedAccount.RecordType.Name != 'Partner');
                    }else{
                        opp.AccountId = null;
                    }
                    opp.PatchLocked__c = true;
                    
                }
                insert opptylst;
                mapresult.put('oppid',opptylst[0].Id);
                
                for(Partner part: oppartlst){
                    part.OpportunityId = opptylst[0].Id;
                }
                insert oppartlst;

                //create OpportunityPartners for the new opp using imported partner data
                List<Opportunity_Partner__c> newOppPartners = new List<Opportunity_Partner__c>();
                for(Partner part: oppartlst){
                    Opportunity_Partner__c newOppPartner = new Opportunity_Partner__c();
                    newOppPartner.Account__c = part.AccountToId;
                    newOppPartner.Opportunity__c = opptylst[0].Id;
                    newOppPartner.Is_Primary__c = part.IsPrimary;
                    newOppPartner.Partner_Type__c = part.Role;
                    newOppPartners.add(newOppPartner);
                }
                insert newOppPartners;
            }
        }

        if(!scilst.isEmpty()){
            for(Significant_Customer_Interaction__c sci: scilst){
                if(sci.recordtypeid != null && Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.containskey(sci.RecordType.Name)){
                    sci.RecordtypeId = Schema.SObjectType.Significant_Customer_Interaction__c.RecordTypeInfosByName.get(sci.RecordType.Name).RecordTypeId;
                }
                sci.Account_Name__c = acclst != null && acclst.containskey('Account') && acclst.get('Account') != null ? acclst.get('Account').Id: null;
                if(sci.Opportunity_Name__c == null && mapresult.containskey('oppid')){
                    sci.Opportunity_Name__c = mapresult != null && mapresult.containskey('oppid') && mapresult.get('oppid') != null ? mapresult.get('oppid'): null;
                }
            }
            insert scilst;
            mapresult.put('sciid',scilst[0].Id);
            
            if(!scizscaleratt.isEmpty()){
                for(SCI_Zscaler_Attendee__c sci: scizscaleratt){
                    sci.Significant_Customer_Interaction__c  = scilst[0].Id;
                }
                insert scizscaleratt;
            }
            
            if(!sciextatt.isEmpty()){
                List<contact> contoinsert = new List<Contact>();
                for(SCI_External_Attendee__c sci: sciextatt){
                    Contact con = new Contact();
                    con.lastname = acclst != null && acclst.containskey('Account') && acclst.get('Account') != null ? acclst.get('Account').name.trim()+ '-' + (Integer.valueOf(sciextatt.indexOf(sci)) + 1) +  '@' + acclst.get('Account').name.trim() + '.dummy.com': null;
                    con.Budget_Authority__c = sci.Budget_Authority__c;
                    con.Head_of_IT__c = sci.Head_of_IT__c;
                    con.Head_of_Networking__c = sci.Head_of_Networking__c;
                    con.Head_of_Security__c = sci.Head_of_Security__c;
                    con.Procurement_Contact__c = sci.Procurement_Contact__c;
                    con.Service_Owner__c = sci.Service_Owner__c;
                    contoinsert.add(con);
                    sci.Significant_Customer_Interaction__c  = scilst[0].Id;
                }
                insert contoinsert;
                for(Contact con: contoinsert){
                    sciextatt[contoinsert.indexOf(con)].Attendee_Name__c = con.Id;
                }
                insert sciextatt;
            }
        }
        return mapresult;
        
    }
}