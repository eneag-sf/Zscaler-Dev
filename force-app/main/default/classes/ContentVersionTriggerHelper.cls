public class ContentVersionTriggerHelper{
    public static void UpdateEventNotes(List<ContentVersion> CVList){       
    Set<Id> contentDocumentIdSet = new Set<Id>();
    Set<Id> EventIdSet = new Set<Id>();
    Map<id,id> ContentDocidandEventID= new Map<id,id>();
    for(ContentVersion cv:CVList)
    {
        system.debug('cv '+cv);
        if(cv.ContentDocumentId != null)
        {
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
    }
    system.debug('contentDocumentIdSet    '+contentDocumentIdSet);
    for (ContentDocumentLink cdl :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet]){
            system.debug('cdl    '+cdl);
            EventIdSet.add(cdl.LinkedEntityId);
            if(String.valueof(cdl.LinkedEntityId.getsobjecttype())=='Event'){
                ContentDocidandEventID.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
    }
    system.debug('ContentDocidandEventID  '+ContentDocidandEventID);
    system.debug('EventIdSet  '+EventIdSet);
    Set<id> EventidSet2= new Set<id>();
    //Map< Id, Event > ev = new Map< Id, Event > ( [SELECT Id,/**This_is_a_SCI__c,Significant_Customer_Interaction__c,DaScoopComposer__Is_Created_By_Groove__c**/ FROM Event WHERE id IN:EventIdSet /**and Significant_Customer_Interaction__c!=null and  DaScoopComposer__Is_Created_By_Groove__c=true**/] );
    //system.debug('ev   '+ev);
    //EventidSet2.addall(ev.keyset());
    
    /**if(EventidSet2.size()>0){
        List<ContentDocumentLink> ContentDocumentLinkList=[SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:EventidSet2];
        List<ContentDocumentLink> ContentDocumentLinkList2delete= new List<ContentDocumentLink>();
        Set<id> tempset= new Set<id>();
        for(ContentDocumentLink cdl :ContentDocumentLinkList){
                if(contentDocumentIdSet.contains(cdl.ContentDocumentId)){
                    system.debug('contentDocumentIdSet contains');
                    
                } 
                else{
                    system.debug('contentDocumentIdSet does nt contains');
                    ContentDocumentLinkList2delete.add(cdl);
                    tempset.add(cdl.id);
                }
        }
        
        if(ContentDocumentLinkList2delete.size()>0){
            delete ContentDocumentLinkList2delete;
        }
        system.debug('tempset  '+tempset);
        
        
        //to remove this code at the time of deployment
        /* for (ContentVersion notes : [SELECT Title,ReasonForChange,ExternalDocumentInfo1,ExternalDocumentInfo2,FileType,ContentDocumentId,Description FROM ContentVersion WHERE ContentDocumentId IN :tempset AND IsLatest = true AND IsDeleted = false AND FileType = 'SNOTE']){     
            system.debug('notes  '+notes);
        } */
        
        /**Map< Id, Significant_Customer_Interaction__c > EventIdandSCImap = new Map< Id, Significant_Customer_Interaction__c >();
        for(Significant_Customer_Interaction__c SCI:[Select id,Meeting_ID__c,Meeting_Notes__c from Significant_Customer_Interaction__c where Meeting_ID__c IN:EventidSet2 and recordtype.developerName='Upcoming_Meeting']){
            EventIdandSCImap.put(SCI.Meeting_ID__c,SCI);
        }
        system.debug('EventIdandSCImap   '+EventIdandSCImap);       
                
        
        if(EventIdandSCImap!=null){
            for(ContentVersion cv:CVList){ 
                system.debug('cv '+cv);
                if(cv.ContentDocumentId != null && ContentDocidandEventID.containskey(cv.ContentDocumentId)&& EventidSet2.contains(ContentDocidandEventID.get(cv.ContentDocumentId)) && EventIdandSCImap.containskey(ContentDocidandEventID.get(cv.ContentDocumentId)))  {
                    EventIdandSCImap.get(ContentDocidandEventID.get(cv.ContentDocumentId)).Meeting_Notes__c=cv.TextPreview;
                    
                }
            }
            
            system.debug('EventIdandSCImap   '+EventIdandSCImap);
            TriggerUtility.bypassSCITrigger=true;
            update EventIdandSCImap.values();
        }
        
    }**/
    }
}