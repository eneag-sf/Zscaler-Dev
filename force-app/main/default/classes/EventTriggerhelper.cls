public class EventTriggerhelper{
    
    Public static void AutocreateSCI(List<Event> newEventlst, Map<Id, Event> oldEventmap, Boolean isInsert, Boolean isUpdate){
        
    }
    
    public static void DeleteSCI(List<Event> newEventlst,Map<Id, Event> oldEventmap){
        Set<id> EventidSet= new Set<id>();
        for(Event evnt:newEventlst){
            EventidSet.add(evnt.id);
        }
        
        List<Significant_Customer_Interaction__c> SCIlisttodelete= new List<Significant_Customer_Interaction__c>();
        SCIlisttodelete=[Select id from Significant_Customer_Interaction__c where Meeting_ID__c IN:EventidSet];
        delete SCIlisttodelete;
    }
    
    public static void BeforeUpdateEventMethod(List<Event> newEventlst,Map<Id, Event> oldEventmap){
        Set<id> EventidSet= new Set<id>();
        for(Event evnt:newEventlst){
            /**if(evnt.DaScoopComposer__Is_Created_By_Groove__c && evnt.This_is_a_SCI__c!='No SCI Required' && evnt.This_is_a_SCI__c!='Create SCI' && evnt.This_is_a_SCI__c!=oldEventmap.get(evnt.id).This_is_a_SCI__c){
                evnt.This_is_a_SCI__c='SCI needs to be updated';
            }
            if(evnt.DaScoopComposer__Is_Created_By_Groove__c && evnt.This_is_a_SCI__c=='SCI Associated'){
                evnt.This_is_a_SCI__c='SCI needs to be updated';
            }
            if(evnt.Description!=oldEventmap.get(evnt.id).Description || /**evnt.Interaction_With__c!=oldEventmap.get(evnt.id).Interaction_With__c ||**/ /**evnt.Meeting_Next_Steps__c!=oldEventmap.get(evnt.id).Meeting_Next_Steps__c || /**evnt.Primary_Topic_Covered__c!=oldEventmap.get(evnt.id).Primary_Topic_Covered__c ||**/ /**evnt.StartDateTime!=oldEventmap.get(evnt.id).StartDateTime){
                /**evnt.This_is_a_SCI__c='SCI needs to be updated';                        
            }
            if(evnt.DaScoopComposer__Is_Created_By_Groove__c && evnt.This_is_a_SCI__c=='Create SCI'/** && evnt.Significant_Customer_Interaction__c==null**//**){
                /**evnt.This_is_a_SCI__c='Create SCI';
            }**/
        }
        
    }
}