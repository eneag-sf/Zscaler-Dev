global class NewLegacyBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT id,Zendesk_Reference_Id__c FROM Case WHERE Zendesk_Reference_Id__c != null and New_Legacy_2__c = true');
    }
    global void execute(Database.BatchableContext bc, List<Case> lstCasesNew){
        
        List<String> setZenIds = new List<String>();
        List<String> caseIds = new List<String>();
        Map<Id,String> mapOldId = new Map<Id,String>();
        for(Case c : lstCasesNew)  {
			 setZenIds.add(c.Zendesk_Reference_Id__c);
        }
        List<Case> records = [select id,Zendesk_Reference_Id__c from Case where Zendesk_Reference_Id__c in :setZenIds and New_Legacy_2__c = false ];
        for(Case c : records)  {
			caseIds.add(c.Id);
            mapOldId.put(c.Id,c.Zendesk_Reference_Id__c);
        }
        
        Map<string,Id> mapNewId = new Map<string,Id>();
        for(Case c : lstCasesNew)  {
            mapNewId.put(c.Zendesk_Reference_Id__c , c.id);
        }
        List<Legacy_Case_Comment__c > lstC = [select id,Cases__c from Legacy_Case_Comment__c where Cases__c in :records];
        for(Legacy_Case_Comment__c c1 : lstC)  {
            if(mapOldId.containsKey(c1.cases__c))  {
                String s = mapOldId.get(c1.cases__c);
                if(mapNewId.containsKey(s))  {
                    c1.cases__c = mapNewId.get(s);
                }
            }
        }
        update lstC;
        
        List<CaseTeamMember > lstC2 = [select id, parentId, MemberId, TeamRoleId from CaseTeamMember where parentId  in :records];
        List<CaseTeamMember> cmList = new List<CaseTeamMember>();
        for(CaseTeamMember c1 : lstC2)  {
            if(mapOldId.containsKey(c1.parentId ))  {
                String s = mapOldId.get(c1.parentId );
                if(mapNewId.containsKey(s))  {
                    CaseTeamMember c2 = new CaseTeamMember();
                    c2.MemberId = c1.MemberId;
                    c2.TeamRoleId = c1.TeamRoleId;
                    c2.parentId  = mapNewId.get(s);
                    cmList.add(c2);
                }
            }
        }
        insert cmList;
        List<ContentDocumentLink> lstC3 = [select id, ContentDocumentId, LinkedEntityId, ShareType, Visibility from ContentDocumentLink where LinkedEntityId  in :caseIds];
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
        for(ContentDocumentLink c1 : lstC3)  {
            if(mapOldId.containsKey(c1.LinkedEntityId  )){
                String s = mapOldId.get(c1.LinkedEntityId );
                if(mapNewId.containsKey(s))  {
                    ContentDocumentLink c2 = new ContentDocumentLink();
                    c2.ContentDocumentId = c1.ContentDocumentId;
                    c2.ShareType = c1.ShareType;
                    c2.Visibility = c1.Visibility;
                    c2.LinkedEntityId = mapNewId.get(s);
                    cdList.add(c2);
                }
            }
        }
        insert cdList;
        delete records;
    }    
    global void finish(Database.BatchableContext bc){}    
}