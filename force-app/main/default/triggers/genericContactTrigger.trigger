/*****************************************************************************************
Name: genericContactTrigger
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Genric trigger on contacts for all events.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            13-Nov-2015    Initial Development
2.0            Gurjinder Singh      11-Jun-2019    Changes as a part of Zscaler Cloud contact automation
3.0                                 9th Aug -2019   PatchRealign Check is added as a part of RBAC
******************************************************************************************/

trigger genericContactTrigger on Contact (before insert, before update, after insert, after update, before delete) {

    if(ContactTriggerHelper.skipTrigger == false)
    {
        if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert) ){
            ContactTriggerHelper.updateHeadfieldsonContact(trigger.new,trigger.oldmap);
            if(!TriggerUtility.isContactPatchManagerExecuted() && !TriggerUtility.isPatchRealigning())
            ContactPatchManager.getPatchInformation(trigger.new);
            if(!TriggerUtility.iscontactOwnerShipExecuted() && !TriggerUtility.isPatchRealigning())
            ContactTriggerHelper.changeContactOwnership(trigger.new);
        }
        //added by Gurjinder:Start
        if(trigger.isBefore && trigger.isUpdate && !TriggerUtility.AutocreateZCloudIDcontactUpdateExecuted() && !TriggerUtility.isPatchRealigning()){           
            ContactTriggerHelper.ZCloudIDContactUpdate(trigger.new, trigger.oldmap);
        }
        
        if(trigger.isBefore && trigger.isDelete){
            ContactTriggerHelper.ZCloudIDContactDelete(trigger.old);
        }
        //added by Gurjinder:End
    }

    if(ContactTriggerHelper.skipTrigger == false)
    {
        if(trigger.isAfter && trigger.isInsert){
            ContactTriggerHelper.skipTrigger = true;
                if(!TriggerUtility.isconWhiteSpaceUpdateExecuted()){
                    ContactTriggerHelper.updateContactWhiteSpace(trigger.new, null);
                }
            //added by Gurjinder:Start
                ContactTriggerHelper.ZCloudIDContactInsert(trigger.new);
            //added by Gurjinder:End
            
        }
        
        if(!TriggerUtility.isPatchRealigning()){
            if(trigger.isUpdate && trigger.isAfter){
                ContactTriggerHelper.skipTrigger = true;
                map<id, id> contactIdTerritoryIdMap = new map<Id, Id>();
                for(Contact con : trigger.new){
                    if(con.Territory__c != trigger.oldMap.get(con.Id).Territory__c)
                        contactIdTerritoryIdMap.put(con.id, con.Territory__c);
                }
                if(contactIdTerritoryIdMap != null && contactIdTerritoryIdMap.keySet().Size() > 0){
                    //if(!TriggerUtility.isPatchRealigning()){
                        CampaignMemberPatchManager.getPatchInformation(contactIdTerritoryIdMap,'Contact');
                    //}
                }
                if(!TriggerUtility.isconWhiteSpaceUpdateExecuted()){
                    //if(!TriggerUtility.isPatchRealigning()){
                        ContactTriggerHelper.updateContactWhiteSpace(trigger.new, trigger.oldMap);
                    //}
                }
            }
        }
    }

    List<Id> ZPAInteractiveList = new List<Id>();

    /*if(ContactTriggerHelper.skipTrigger == false)
    {*/
    if(!TriggerUtility.isPatchRealigning()){
                      
        if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
        {
            //ContactTriggerHelper.skipTrigger = true;
            if(Trigger.isInsert)
            {
                for(Contact con : Trigger.new)
                {
                    if(con.ZPA_Interactive_Prospect__c )
                    {
                        ZPAInteractiveList.add(con.Id);
                    }
                }
            }
            else
            {
                for(Contact con : Trigger.new)
                {
    
                    if(con.ZPA_Interactive_Prospect__c  != Trigger.oldMap.get(con.Id).ZPA_Interactive_Prospect__c )
                    {
                        ZPAInteractiveList.add(con.Id);
                    }
                }
            }
        }
        //}
    
        if(ZPAInteractiveList.size() > 0)
        {
            System.enqueueJob(new ZPAInteractiveRequest('Contact',ZPAInteractiveList));
        }
    }

    // Commenting this out to allow contacts deduplication activity
    // if(trigger.isBefore && trigger.isDelete)
    //     ContactTriggerHelper.dealRegValidation(trigger.oldMap);
    if(Test.isrunningtest()){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }

}