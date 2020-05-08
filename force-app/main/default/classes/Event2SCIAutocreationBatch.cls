public class Event2SCIAutocreationBatch implements Database.Batchable<SObject>,Database.Stateful {
    String testEventId='';
    
    
    /* public Event2SCIAutocreationBatch(String EvntId){
        testEventId = EvntId;
    } */
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //String testEventId = '00U0r00000118ZR';   
        //return Database.getQueryLocator('Select Id from Account Where Id =: testAccountId');
        Datetime dt= system.now().addHours(-6);
        //String query = 'Select Id,WhoId, Description,Interaction_With__c,Meeting_Next_Steps__c,Primary_Topic_Covered__c,SCI_Type__c,StartDateTime,This_is_a_SCI__c,DaScoopComposer__Is_Created_By_Groove__c,Significant_Customer_Interaction__c from Event where DaScoopComposer__Is_Created_By_Groove__c=true and LastModifiedDate>:dt and ischild=false';
        String query = 'Select Id,WhoId, Description,Meeting_Next_Steps__c,SCI_Type__c,StartDateTime from Event where LastModifiedDate>:dt and ischild=false';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<Event> newEventlst) {
        
        /**Map<String, id> mapRecordTypesAndDescriptions = new Map<String, id>();
        List<Significant_Customer_Interaction__c> SCIListToInsert= new List<Significant_Customer_Interaction__c>();
        List<Significant_Customer_Interaction__c> SCIlisttodelete= new List<Significant_Customer_Interaction__c>();
        List<Significant_Customer_Interaction__c> SCIListToUpdate= new List<Significant_Customer_Interaction__c>();
        Set<id> EventIDSet = new Set<id>();
        Set<id> EventIDSet2 = new Set<id>();
        Set<id> EventIDSet3 = new Set<id>();
        Set<id> EventIDSet4 = new Set<id>();
        Map<id,id> EventIDandSCIidMap = new Map<id,id>();
        Map<id,id> SCIMAPToUpdate = new Map<id,id>();
            
            
        for (RecordType recordType : [SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE sObjectType = 'Significant_Customer_Interaction__c' AND IsActive = TRUE]) {
            mapRecordTypesAndDescriptions.put(recordType.Name,recordType.id);
        }
        for(Event evnt:newEventlst){
            
            /**if(evnt.This_is_a_SCI__c=='Create SCI'  && evnt.DaScoopComposer__Is_Created_By_Groove__c ){  
                EventIDSet.add(evnt.id);                
                Significant_Customer_Interaction__c sci= new Significant_Customer_Interaction__c();
                sci.Meeting_Notes__c=evnt.Description;
                //sci.Interaction_With__c=evnt.Interaction_With__c;
                sci.Meeting_ID__c=evnt.id;
                sci.Type_of_Interaction__c='Upcoming Meeting';
                sci.Next_Steps__c=evnt.Meeting_Next_Steps__c;
                //sci.Primary_Topic_Covered__c=evnt.Primary_Topic_Covered__c;
                if(mapRecordTypesAndDescriptions.get('Upcoming Meeting')!=null){                    
                    sci.recordtypeid=mapRecordTypesAndDescriptions.get('Upcoming Meeting');
                }                   
                    DateTime dt = evnt.StartDateTime;
                    Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
                sci.Date__c=myDate;
                SCIListToInsert.add(sci);
            }else if(evnt.This_is_a_SCI__c=='No SCI Required' && evnt.DaScoopComposer__Is_Created_By_Groove__c ){
                    EventIDSet2.add(evnt.id);
            }else if(evnt.This_is_a_SCI__c=='SCI needs to be updated' && evnt.DaScoopComposer__Is_Created_By_Groove__c){
                    EventIDSet4.add(evnt.id);
                    /**if(evnt.Significant_Customer_Interaction__c!=null){
                        EventIDandSCIidMap.put(evnt.id,evnt.Significant_Customer_Interaction__c);
                    }**/
            /**}**/
        /**}
                    
        for(Significant_Customer_Interaction__c SCI:[Select id,Meeting_ID__c from Significant_Customer_Interaction__c where (Meeting_ID__c IN:EventIDSet2 OR Meeting_ID__c IN:EventIDSet4 )and  recordtype.developerName='Upcoming_Meeting']){
        
            if(EventIDSet2.contains(SCI.Meeting_ID__c)){
                SCIlisttodelete.add(SCI);
            }else if(EventIDSet4.contains(SCI.Meeting_ID__c)){
                SCIMAPToUpdate.put(SCI.Meeting_ID__c,SCI.id);
            }               
        }
        
        if(SCIListToInsert.size()>0){
            TriggerUtility.bypassSCITrigger=true;
            insert SCIListToInsert;
            for(Significant_Customer_Interaction__c sci:SCIListToInsert){
                EventIDandSCIidMap.put(sci.Meeting_ID__c,sci.id);
            }
        }
        
        Map<id,List<EventRelation>> EvntandEvntRelationMap= new Map<id,List<EventRelation>>();
        for(EventRelation EvntRel:[SELECT Id,/* Account.Name,IsInvitee,,IsParent,IsWhat *//**CreatedById,CreatedDate,EventId,IsDeleted,LastModifiedById,LastModifiedDate,Relationid,Relation.Name,Relation.Email,RespondedDate,Response,Status,SystemModstamp,event.ownerid FROM EventRelation where CreatedById != null and (EventId IN:EventIDSet OR EventId IN:EventIDSet4) /* and IsInvitee= true */ /**]){
            if(EvntandEvntRelationMap.containskey(EvntRel.EventId)){
                List<EventRelation> templist= new List<EventRelation>();
                EvntandEvntRelationMap.get(EvntRel.EventId).add(EvntRel);                   
            }else{
                List<EventRelation> templist= new List<EventRelation>();
                templist.add(EvntRel);
                EvntandEvntRelationMap.put(EvntRel.EventId,templist);
            }
        } 
            
                        
        for(Event evnt:newEventlst){
            if(EventIDSet4.contains(evnt.id)){
                Significant_Customer_Interaction__c sci= new Significant_Customer_Interaction__c();
                    sci.Meeting_Notes__c=evnt.Description;
                    //sci.Interaction_With__c=evnt.Interaction_With__c;
                    sci.Meeting_ID__c=evnt.id;
                    sci.Type_of_Interaction__c='Upcoming Meeting';
                    sci.Next_Steps__c=evnt.Meeting_Next_Steps__c;
                    //sci.Primary_Topic_Covered__c=evnt.Primary_Topic_Covered__c;             
                    //sci.recordtypeid=evnt.SCI_Type__c;                
                        DateTime dt = evnt.StartDateTime;
                        Date myDate = date.newinstance(dt.year(), dt.month(), dt.day());
                    sci.Date__c=myDate;
                    /* if(evnt.SCI_Type__c!=null && mapRecordTypesAndDescriptions.get(evnt.SCI_Type__c)!=null){                    
                        sci.recordtypeid=mapRecordTypesAndDescriptions.get(evnt.SCI_Type__c);
                    } */
					/**if(mapRecordTypesAndDescriptions.get('Upcoming Meeting')!=null){                    
						sci.recordtypeid=mapRecordTypesAndDescriptions.get('Upcoming Meeting');
					} 
                    sci.id=SCIMAPToUpdate.get(evnt.id);
                    SCIListToUpdate.add(sci);
                    
                    //EventIDandSCIidMap.put(evnt.id,evnt.Significant_Customer_Interaction__c);
            }
        }
            
        if(SCIListToUpdate.size()>0){
            TriggerUtility.bypassSCITrigger=true;
            Upsert SCIListToUpdate;
            for(Significant_Customer_Interaction__c SCI:SCIListToUpdate){
                EventIDandSCIidMap.put(SCI.Meeting_ID__c,SCI.id);
            }
        }
        if(SCIlisttodelete.size()>0){
            delete SCIlisttodelete;
        }
            
            //Map<id,id> EventIDandSCIidMap = new Map<id,id>();
            List<SCI_Zscaler_Attendee__c> lstInternalAttendeesToInsert = new List<SCI_Zscaler_Attendee__c>();
            List<SCI_Zscaler_Attendee__c> lstInternalAttendeesToDelete = new List<SCI_Zscaler_Attendee__c>();
            List<SCI_External_Attendee__c > lstExternalAttendeesToInsert = new List<SCI_External_Attendee__c >();
            List<SCI_External_Attendee__c > lstExternalAttendeesToDelete = new List<SCI_External_Attendee__c >();
            
            lstInternalAttendeesToDelete=[SELECT Id,Significant_Customer_Interaction__c,Significant_Customer_Interaction__r.Meeting_ID__c FROM SCI_Zscaler_Attendee__c where Significant_Customer_Interaction__r.Meeting_ID__c IN:EventIDSet4 and Significant_Customer_Interaction__r.recordtype.developername='Upcoming_Meeting'];
            for(SCI_Zscaler_Attendee__c SCIIntAttendee:lstInternalAttendeesToDelete){
                EventIDandSCIidMap.put(SCIIntAttendee.Significant_Customer_Interaction__r.Meeting_ID__c,SCIIntAttendee.Significant_Customer_Interaction__c);
            }
            delete lstInternalAttendeesToDelete;
            
            lstExternalAttendeesToDelete=[SELECT Id,Significant_Customer_Interaction__c,Significant_Customer_Interaction__r.Meeting_ID__c FROM SCI_External_Attendee__c where Significant_Customer_Interaction__r.Meeting_ID__c IN:EventIDSet4 and Significant_Customer_Interaction__r.recordtype.developername='Upcoming_Meeting'];
            for(SCI_External_Attendee__c SCIExtAttendee:lstExternalAttendeesToDelete){
                EventIDandSCIidMap.put(SCIExtAttendee.Significant_Customer_Interaction__r.Meeting_ID__c,SCIExtAttendee.Significant_Customer_Interaction__c);
            }
            delete lstExternalAttendeesToDelete;
            
            for(id Evntid:EvntandEvntRelationMap.keyset()){
                
                integer createOwnerAttendee=0;
                for(EventRelation EvntRltn:EvntandEvntRelationMap.get(Evntid)){
                    if(createOwnerAttendee==0){
                        createOwnerAttendee=createOwnerAttendee+1;
                        lstInternalAttendeesToInsert.add(new SCI_Zscaler_Attendee__c(Significant_Customer_Interaction__c = EventIDandSCIidMap.get(Evntid),Attendee_Name__c = EvntRltn.event.ownerid,Participation__c = 'Remote',Organizer__c=true));
                    }
                    
                    
                    if(EvntRltn.Relation.Email!=null && EvntRltn.Relation.Email!='' && EvntRltn.Relation.Email.contains('zscaler.com')){
                        lstInternalAttendeesToInsert.add(new SCI_Zscaler_Attendee__c(Significant_Customer_Interaction__c = EventIDandSCIidMap.get(Evntid),Attendee_Name__c = EvntRltn.Relationid,Participation__c = 'Remote',Organizer__c=false));
                    }else{
                        if(EvntRltn.Relationid.getSobjecttype() == Schema.Contact.SObjectType){
                            lstExternalAttendeesToInsert.add(new SCI_External_Attendee__c(Significant_Customer_Interaction__c = EventIDandSCIidMap.get(Evntid),Attendee_Name__c = EvntRltn.Relationid,Type__c = 'Customer'));
                        }
                        else if(EvntRltn.Relationid.getSobjecttype() == Schema.Lead.SObjectType){
                            lstExternalAttendeesToInsert.add(new SCI_External_Attendee__c(Significant_Customer_Interaction__c = EventIDandSCIidMap.get(Evntid),Attendee_Name_Lead__c = EvntRltn.Relationid,Type__c = 'Customer'));
                        }
                    }
                }
            } 
            
            
            //For querying External Attendees
            if(lstInternalAttendeesToInsert.size()>0){
                insert lstInternalAttendeesToInsert;    
            }
            if(lstExternalAttendeesToInsert.size()>0){
                insert lstExternalAttendeesToInsert;    
            }
            
            List<Event> EventlisttoUpdate = new List<Event>();
            for(Event evnt:newEventlst){
                /**if(evnt.This_is_a_SCI__c=='Create SCI' && /**evnt.Significant_Customer_Interaction__c==null &&**/ /**EventIDandSCIidMap.get(evnt.id)!=null){
                    evnt.Significant_Customer_Interaction__c=EventIDandSCIidMap.get(evnt.id);
                    evnt.This_is_a_SCI__c='SCI Associated';
					EventlisttoUpdate.add(evnt);
                }
                if(evnt.This_is_a_SCI__c=='SCI needs to be updated' /**&& evnt.Significant_Customer_Interaction__c!=null**/  /**){
                    evnt.This_is_a_SCI__c='SCI Associated';
					EventlisttoUpdate.add(evnt);
                }
                if(evnt.This_is_a_SCI__c=='SCI needs to be updated' /**&& evnt.Significant_Customer_Interaction__c==null**/ /**){
                    evnt.This_is_a_SCI__c='SCI Associated';
                    evnt.Significant_Customer_Interaction__c=EventIDandSCIidMap.get(evnt.id);
					EventlisttoUpdate.add(evnt);
                }
                if(evnt.This_is_a_SCI__c=='No SCI Required'){
                    /**evnt.Significant_Customer_Interaction__c=null;**/
					/**EventlisttoUpdate.add(evnt);
                }**/
            /**}
            if(EventlisttoUpdate.size()>0){
                TriggerUtility.isGroove2SCIcodeexecuted=true;
                update EventlisttoUpdate;
            }
            
            /* if(newEventlst.size()>0){
                TriggerUtility.isGroove2SCIcodeexecuted=true;
                update newEventlst;
            } */
    }
    
    public void finish(Database.BatchableContext context) {
        
    }
}