trigger updatecontactrolecount on Opportunity (before insert, before update) {
// added check as a part of RBAC:Start
    if(!TriggerUtility.isPatchRealigning()) {
        if (!Triggerutility.isupdateContactRoleCountExecuted()) {
            Boolean isPrimary;
            Integer iCount;
            Map<String, Opportunity> oppty_con = new Map<String, Opportunity>();//check if the contact role is needed and add it to the oppty_con map
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                oppty_con.put(Trigger.new[i].id,
                Trigger.new[i]);      
            }
            isPrimary = False; 
            for (List<OpportunityContactRole> oppcntctrle :[select OpportunityId from OpportunityContactRole where (OpportunityContactRole.IsPrimary = True and OpportunityContactRole.OpportunityId in :oppty_con.keySet())]){
                if (oppcntctrle .Size() >0){
                    isPrimary = True;     
                }
            }
            iCount = 0;
            for (List<OpportunityContactRole> oppcntctrle2 : [select OpportunityId from OpportunityContactRole where (OpportunityContactRole.OpportunityId in :oppty_con.keySet())]){//Query for Contact Roles    
                if (oppcntctrle2 .Size()>0){
                    iCount= oppcntctrle2 .Size();     
                }
            }
            for (Opportunity Oppty : system.trigger.new){ //Check if  roles exist in the map or contact role isn't required 
                Oppty.Number_of_Contacts_Roles_Assigned__c = iCount;
                Oppty.Primary_Contact_Assigned__c =isPrimary; 
            }
            TriggerUtility.updateContactRoleCountExecuted();
        }
    }
}