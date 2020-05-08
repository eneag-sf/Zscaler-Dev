/*****************************************************************************************
Name: CampaignMemberPatchManager
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
1.0            Kunal Raj            08-Dec-2015    Initial Development
******************************************************************************************/ 


Public class CampaignMemberPatchManager{

    /**
    *@purpose : Method to capture Territory information on CampaignMember
    *@param : New List of CampaignMember.
    *@return : None
    **/
    public static void getPatchInformation(map<Id,id> sobjIdMap, string sobjName){
        try{
            list<CampaignMember> campMemUpdateList = new list<CampaignMember>();
            
            for(CampaignMember camp : [Select id, Territory__c, LeadId, ContactId from CampaignMember where LeadId IN: sobjIdMap.keySet() OR ContactId IN: sobjIdMap.keySet()]){
                if(sobjName == 'Contact')
                    camp.TerriTory__c = sobjIdMap.get(camp.ContactId);
                if(sobjName == 'Lead')
                    camp.TerriTory__c = sobjIdMap.get(camp.LeadId);
                
                campMemUpdateList.add(camp);    
            }
            
            if(!campMemUpdateList.isEmpty())    
                database.update(campMemUpdateList, false);
        }catch(exception e){}    
    }
}