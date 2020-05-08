/*
 * This class is called from Process Builder for updating Lead or Contact with ZPA Provisioned Date. 
 */ 
public class UpdateLeadContact {

    @InvocableMethod
    public static void updateData(List<Id> provisioningRequests)
    {
        List<Contact> contacts = new List<Contact>();
        List<Lead> leads = new List<Lead>();
        List<Provisioning_Request__c> prList = [Select Id,Name,Provisioning_Date__c,Lead__c, Primary_Eval_Contact__c from 
                                                Provisioning_Request__c where id in :provisioningRequests];
        
        for(Provisioning_Request__c pr : prList)
        {
            if(pr.Lead__c != null)
            {
                Lead zpaLead = new Lead();
                zpaLead.Id = pr.Lead__c;
                zpaLead.ZPA_FeVa_Provisioned_Date__c = pr.Provisioning_Date__c;
                leads.add(zpaLead);
            }
            else if (pr.Primary_Eval_Contact__c != null)
            {
                Contact zpaContact = new Contact();
                zpaContact.Id = pr.Primary_Eval_Contact__c;
                zpaContact.ZPA_FeVa_Provisioned_Date__c = pr.Provisioning_Date__c;
                contacts.add(zpaContact);
                
            }
        }
        
        if (leads.size() > 0)
            update leads;
        if (contacts.size() > 0)
            update contacts;
        
        
   }
}