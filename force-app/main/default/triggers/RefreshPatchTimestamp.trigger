trigger RefreshPatchTimestamp on Patch__c (before insert, before update) 
{
    for(Patch__c p : Trigger.new)
    {
        p.Timestamp__c = DateTime.now();
    }
}