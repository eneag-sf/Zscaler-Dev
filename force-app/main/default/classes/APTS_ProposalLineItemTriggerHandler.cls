/* APTS_ProposalLineItemTriggerHandler
 * Trigger handler for Proposal Line Item(Apttus_Proposal__Proposal_Line_Item__c ) trigger.
 *
 * Developer: Harish Emmadi, APTTUS - 11/08/2016
 * Business Owner:
 *
 * Scenario:
 *
 *
 *
 * History:
 */
public without sharing class APTS_ProposalLineItemTriggerHandler
{
    private boolean m_isExecuting = false;

    public APTS_ProposalLineItemTriggerHandler(boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Object[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        APTS_ProposalLineItemUtils.doBeforeDerivations((List<Apttus_Proposal__Proposal_Line_Item__c>)newObjects);
    }

    public void afterInsert(Object[] newObjects){
        // AFTER INSERT LOGIC
        // APTS_ProposalLineItemUtils.doAfterDerivations((List<Apttus_Proposal__Proposal_Line_Item__c>)newObjects);
        // APTS_ProposalLineItemUtils.updatepropasal((List<Apttus_Proposal__Proposal_Line_Item__c>)newObjects);
    }

    public void OnBeforeUpdate(Object[] oldObjects, Object[] updatedObjects, Map<Id, Object> MapObjectMap){
        // BEFORE UPDATE LOGIC
        APTS_ProposalLineItemUtils.doBeforeDerivations((List<Apttus_Proposal__Proposal_Line_Item__c>)updatedObjects);
    }

    public void afterUpdate(Object[] updatedObjects){
        // AFTER UPDATE LOGIC
        // APTS_ProposalLineItemUtils.doAfterDerivations((List<Apttus_Proposal__Proposal_Line_Item__c>)updatedObjects);
        // APTS_ProposalLineItemUtils.updatepropasal((List<Apttus_Proposal__Proposal_Line_Item__c>)updatedObjects);
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id, Object> MapObjectMap){
        // AFTER DELETE LOGIC
        // APTS_ProposalLineItemUtils.updatepropasal((List<Apttus_Proposal__Proposal_Line_Item__c>)deletedObjects);
    }
    //Below part commented by Anay Bhande
    //Unused code
    /*
    public void OnAfterInsert(Object[] newObjects){
        // EXECUTE AFTER INSERT LOGIC
    }

    public void OnAfterUpdate(Object[] oldObjects, Object[] updatedObjects, Map<Id, Object> MapObjectMap){
        // AFTER UPDATE LOGIC
    }

    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id, Object> MapObjectMap){
        // BEFORE DELETE LOGIC

    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id, Object> MapObjectMap){
        // AFTER DELETE LOGIC
        APTS_ProposalLineItemUtils.updatepropasal((List<Apttus_Proposal__Proposal_Line_Item__c>)deletedObjects);
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
*/
}