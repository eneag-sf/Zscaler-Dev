trigger FS_CopyAccountOwner on Opportunity (before insert, before update) {
    //PatchRealign Check is added as apart of RBAC
    if(!TriggerUtility.isPatchRealigning()) {
        if (!TriggerUtility.isFsAccountOwnerIdUpdateExecuted()) {
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp: Trigger.new) {
                accountIds.add(opp.AccountID);
            }
        
            Map<Id, Account> accts = new Map<Id, Account>([select OwnerId from Account where id in :accountIds]);
            for (Opportunity opp: Trigger.new) {
                Account acct = accts.get(opp.AccountID);
                if (acct != null) {
                    //opp.FS_Account_Owner__c = acct.OwnerId;
                }
            }
            TriggerUtility.fsAccountOwnerIdUpdateExecuted();
        }
    }
}