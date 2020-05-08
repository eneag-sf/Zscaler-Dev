public class OpportunityContactRoleTriggerHelper {
    
    
    public Set<String> contactRolesToLook = new Set<String>{'Service Owner','Economic Buyer','Champion (Business)','Deployment Contact'};
    public boolean isDelete;
    
    public void afterInsert(List<OpportunityContactRole> newContactRoles){ 
        updateOpportunityCheckForContactRole(newContactRoles);
    }
    
    public void afterUpdate(List<OpportunityContactRole> newContactRoles){ 
        updateOpportunityCheckForContactRole(newContactRoles);
    }
    
    public void beforeDelete(List<OpportunityContactRole> newContactRoles){
        isDelete = true;
        updateOpportunityCheckForContactRole(newContactRoles);
    }
    
    public void updateOpportunityCheckForContactRole(List<OpportunityContactRole> newContactRoles){
        
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityContactRole oppContactRole : newContactRoles){
            oppIds.add(oppContactRole.OpportunityId); 
        }
        
        List<OpportunityContactRole> opportunityContactRoles = [SELECT Id,
                                                                        OpportunityId,
                                                                        Role 
                                                                        FROM 
                                                                        OpportunityContactRole 
                                                                        Where 
                                                                        Role != null
                                                                        AND
                                                                        OpportunityId IN: oppIds
                                                                        AND
                                                                        ID NOT IN: newContactRoles];
                                                                        
        Map<Id, Set<String>> oppContactRoleMap = new Map<Id, Set<String>>();                                                               
        
        for(OpportunityContactRole oppContactRoleRec : newContactRoles){
            if(contactRolesToLook.contains(oppContactRoleRec.Role)){
                Set<String> contactRoles = new Set<String>();
                contactRoles.add(oppContactRoleRec.Role);
                oppContactRoleMap.put(oppContactRoleRec.OpportunityId, contactRoles);
            }
        }
        
        List<Opportunity> opportunitiesToUpdate = [Select Id, has_Required_Contact_Roles__c from Opportunity Where Id IN: oppIds];
        for(OpportunityContactRole contactRoleRec : opportunityContactRoles){
            if(oppContactRoleMap.get(contactRoleRec.OpportunityId) == null){
                if(contactRolesToLook.contains(contactRoleRec.Role)){
                    Set<String> contactRoles = new Set<String>();
                    contactRoles.add(contactRoleRec.Role);
                    oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                }
                
            }
            
            else{
                if(contactRolesToLook.contains(contactRoleRec.Role)){
                    Set<String> contactRoles = oppContactRoleMap.get(contactRoleRec.OpportunityId);
                    contactRoles.add(contactRoleRec.Role);
                    oppContactRoleMap.put(contactRoleRec.OpportunityId, contactRoles);
                }
            }
            
        }
        for(Opportunity oppRec : opportunitiesToUpdate){
            if(oppContactRoleMap.get(oppRec.Id) != null){
                if(isDelete == true){
                    if(oppContactRoleMap.get(oppRec.Id).size()-1 >= 4 ){
                        oppRec.has_Required_Contact_Roles__c = true;
                    }
                    else{
                        oppRec.has_Required_Contact_Roles__c = false;
                    }  
                }
                else{
                    if(oppContactRoleMap.get(oppRec.Id).size() >= 4 ){
                        oppRec.has_Required_Contact_Roles__c = true;
                    }
                    else{
                        oppRec.has_Required_Contact_Roles__c = false;
                    }
                }
            }
            else{
                oppRec.has_Required_Contact_Roles__c = false;
            }
        }
        update opportunitiesToUpdate;
    }
    
   
}