@RestResource(urlMapping='/GOVPRODSYNC/*')
global with sharing class GOVPRODSYNC {
    global static Boolean avoidtriggers = false;
    @HttpGet
    global static Map<String, String> doGet() {
        Integer lim;
        RestRequest req = RestContext.request;
        Map<String, String> result = new map<String, String>();
        Map<String,String> parmap = new Map<String, String>();
        System.debug(req.params);
        System.debug(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8'));
        system.debug(Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')));
        if(req.params!= null && req.params.containskey('type') && EncodingUtil.urlDecode(req.params.get('type'),'UTF-8') == 'get_leads'){
            
            if(req.params.containskey('Start_Date') && EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8') != '' && req.params.containskey('End_Date') && EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8') != '' && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) && Pattern.matches('.*-.*-.* .*:.*:.*',EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8'))){
                List<Lead> leadlst = new List<Lead>();
                lim = [Select count() from lead where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Moved_to_Fedramp_Date__c != today];
                if(req.params.containskey('limit')){
                    if(lim > Integer.valueOf(EncodingUtil.urlDecode(req.params.get('limit'),'UTF-8'))){
                        lim = Integer.valueOf(EncodingUtil.urlDecode(req.params.get('limit'),'UTF-8'));
                    }
                }
                system.debug(lim);
                for(Lead ld: [Select Id, Area__c, Title, Moved_to_Fedramp_Date__c , mkto71_Lead_Score__c, MQL_Date__c, mkto2__Lead_Score__c, Moved_to_FedRamp__c, CreatedDate, Most_Recent_Campaign_Name__c, Most_Recent_Campaign2__c, FirstName, LastName, Company, Status, OwnerId, Owner.Email, Phone, Email, LeadSource, Account_Manager__c, Account_Manager__r.Email, Channel_Manager__c, Channel_Manager__r.Email, Closed_Reason__c, Project_Role__c, Lead_Development__c, Lead_Development__r.Email, Market_Segment__c, No_Employees_Users__c, Patch__c, Customer_Advocate__c, Customer_Advocate__r.Email, Sales_Engineer__c, Sales_Engineer__r.Email, Territory__c, Territory_Name__c, ZPA_Manager__c, ZPA_Manager__r.Email, ZPA_SE__c, ZPA_SE__r.Email, Street, City, State, PostalCode, Country /*, (Select Id, CampaignId, Campaign.Name from CampaignMembers order by createddate ASC limit 1) */ from Lead where Federal_Change__c >= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('Start_Date'),'UTF-8')) and Federal_Change__c <= :Datetime.valueOf(EncodingUtil.urlDecode(req.params.get('End_Date'),'UTF-8')) and Moved_to_Fedramp_Date__c != today limit :lim]){
                    leadlst.add(ld);
                }
                system.debug(leadlst);
                if(!leadlst.isEmpty()){
                    result.put('leadresults', JSON.serialize(leadlst));
                    System.enqueueJob(new ProcessLeadsinPROD(leadlst));
                }
            }
        }
        return result;
    }
  
    @HttpPost
    global static Map<String, String> doPost(Map<String,Account> acclst, List<Opportunity> opptylst, List<Partner> oppartlst, Boolean isparentUPsame) {
        avoidtriggers = true;
        Map<String, String> mapresult = new Map<String, String>();

        if(acclst != null){
            Set<Id> accids = new set<Id>();
            for(Account acc: acclst.values()){
                accids.add(acc.Id);
                accids.add(acc.ParentId);
                accids.add(acc.Ultimate_Parent_Account__c);
            }
            for(Account acc: [Select Id from Account where Id in :accids]){
                accids.remove(acc.Id);
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
                acc.Is_Federal_Account_Sync__c = true;
            }
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();

            upsert acclst.values();
            
            for(string s: acclst.keyset()){
                if(acclst.get(s) != null){
                    mapresult.put(s,acclst.get(s).Id);
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
            update acclst.values();
            
            System.debug(mapresult);
            if(!opptylst.isEmpty()){
                for(Opportunity opp: opptylst){
                    if(opp.recordtypeid != null && Schema.SObjectType.Opportunity.RecordTypeInfosByName.containskey(opp.RecordType.Name)){
                        opp.RecordtypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get(opp.RecordType.Name).RecordTypeId;
                    }
                    opp.AccountId = acclst != null && acclst.containskey('Account') && acclst.get('Account') != null ? acclst.get('Account').Id: null;
                    opp.PatchLocked__c = true;
                    opp.Is_Federal_Opportunity_Sync__c = true;
                }
                insert opptylst;
                mapresult.put('oppid',opptylst[0].Id);
                
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
        avoidtriggers = false;
        return mapresult;
        
    }
    
    public class ProcessLeadsinPROD implements Queueable{
        List<Lead> ldlst = new List<Lead>();
        Set<String> federalterset = new Set<String>();
        public ProcessLeadsinPROD(List<Lead> ll){
            ldlst.addAll(ll);
            for(Federal_territories__c ft: Federal_territories__c.getAll().values()){
                federalterset.add(ft.Territory_Name__c);
            }
        }
        public void execute(QueueableContext context) {
            for(Lead ld: ldlst){
                if(ld.Area__c == 'US Federal'){
                    ld.Status = 'Moved to FedRamp';
                    ld.Moved_to_FedRamp__c = true;
                    ld.Moved_to_Fedramp_Date__c = system.now();
                }else if(ld.Status == 'Moved to FedRamp' || ld.Moved_to_FedRamp__c ){
                    ld.Status = 'Pending Marketing Qualification';
                    ld.Moved_to_FedRamp__c = false;
                    ld.Moved_to_Fedramp_Date__c = system.now();
                }
            }
            leadTriggerHelper.skipTrigger = true;
            update ldlst;
        }
    }
}