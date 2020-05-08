/* APTS_LineItemTriggerHandler
 * Trigger handler for Line Item(Apttus_Config2__LineItem__c ) trigger.
 *
 * Developer: Harish Emmadi, APTTUS - 10/31/2016
 * Business Owner: 
 *
 * Scenario:
 * 
 * 
 *
 * History:
 */
public without sharing class APTS_LineItem_Master_TriggerHandler 
{
    private boolean m_isExecuting = false;

    public APTS_LineItem_Master_TriggerHandler (boolean isExecuting){
        m_isExecuting = isExecuting;
    }

    public void OnBeforeInsert(Object[] newObjects){
        // EXECUTE BEFORE INSERT LOGIC
        APTS_LineItemUtils_Master.doBeforeDerivations((List<Apttus_Config2__LineItem__c>) newObjects, new Map<Id, Apttus_Config2__LineItem__c>(),false);
        
    }

    public void OnAfterInsert(Object[] newObjects){
        APTS_LineItemUtils_Master.doBeforeDerivations((List<Apttus_Config2__LineItem__c>)newObjects, new Map<Id, Apttus_Config2__LineItem__c>(),true);
    }

    public void OnBeforeUpdate(Object[] oldObjects, Object[] updatedObjects, Map<Id, Object> MapObjectMap){
        // BEFORE UPDATE LOGIC
     APTS_LineItemUtils_Master.doBeforeDerivations((List<Apttus_Config2__LineItem__c>)updatedObjects, (Map<Id, Apttus_Config2__LineItem__c>)MapObjectMap,false);
    }

    public void OnAfterUpdate(Object[] updatedObjects, Object[] oldObjects, Map<Id, Object> MapObjectMap){
        // AFTER UPDATE LOGIC
        APTS_LineItemUtils_Master.doBeforeDerivations((List<Apttus_Config2__LineItem__c>)updatedObjects, new Map<Id, Apttus_Config2__LineItem__c>(),true);
    }
/*
    public void OnBeforeDelete(Object[] ObjectsToDelete, Map<Id, Object> MapObjectMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Object[] deletedObjects, Map<Id, Object> MapObjectMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Object[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
*/
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }
}