public class BR_Trigger_Handler{
    public static void onbeforeupdate(List<Event_Expenditure_Request__c> newlist, Map<Id, Event_Expenditure_Request__c> oldmap){
        Map<Id, Event_Expenditure_Request__c> brneedssignature = new Map<Id, Event_Expenditure_Request__c>();
        if(!TriggerUtility.isBRAttachmentValidationExecuted()){
            for(Event_Expenditure_Request__c br: newlist){
                if(br.Does_this_contract_require_signature__c == 'Yes'){
                    brneedssignature.put(br.Id, br);
                }
            }
            checkAttachmentforBRrequiringSignature(brneedssignature);
        }
    }
    
    public static void checkAttachmentforBRrequiringSignature(Map<Id, Event_Expenditure_Request__c> brneedssignature){
        for(Attachment att: [Select Id, ParentId from Attachment where ParentId in :brneedssignature.keyset()]){
            brneedssignature.remove(att.ParentId);
        }
        
        for(Event_Expenditure_Request__c br: brneedssignature.values()){
            br.addError('Please attach a document as this contract needs Signature.');
        }
        TriggerUtility.BRAttachmentValidationExecuted();
    
    }

}