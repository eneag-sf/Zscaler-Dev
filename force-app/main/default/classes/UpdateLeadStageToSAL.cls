public class UpdateLeadStageToSAL {

    @InvocableMethod
    public static void updateLeadStageToSAL(List<Id> taskIds) {
		
		if(OnOffSwitch__c.getInstance('updateLeadStageToSAL').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateLeadStageToSAL').Deactivate_Component__c==False){
			system.debug('run the code ');
			List<Contact> lstContactsToUpdate = new List<Contact>();
			List<Lead> lstLeadsToUpdate = new List<Lead>();
			Set<Id> contactIds = new Set<Id>();
			Set<Id> leadIds = new Set<Id>();

			for (Task task : [SELECT Id, WhoId, WhatId, Type, Subject, Status, Call_Disposition__c, Created_By_Department__c
								FROM Task WHERE Id IN :taskIds]) {
				if (task.Call_Disposition__c.equalsIgnoreCase('meeting scheduled')
					&& (task.Created_By_Department__c.equalsIgnoreCase('field sales')
						|| task.Created_By_Department__c.equalsIgnoreCase('inside sales')
						|| task.Created_By_Department__c.equalsIgnoreCase('demand generation'))) {
					if (Schema.Contact.SObjectType == task.WhoId.getSObjectType()) {
						contactIds.add(task.WhoId);
					} else if (Schema.Lead.SObjectType == task.WhoId.getSObjectType()) {
						leadIds.add(task.WhoId);
					}
				}
			}

			if (!contactIds.isEmpty()) {
				for (Contact contact : [SELECT Id, First_SAL_Date__c, SAL_Date__c, Lead_Stage__c, Contact_Lead_Status__c, Number_Of_Meetings_Scheduled__c
										  FROM Contact WHERE Id IN :contactIds AND Lead_Stage__c NOT IN ('SQL')]) {
					lstContactsToUpdate.add(new Contact(Id = contact.Id, Lead_Stage__c = 'SAL', Contact_Lead_Status__c = 'Marketing Qualified: Sales Accepted',
						Number_Of_Meetings_Scheduled__c = (contact.Number_Of_Meetings_Scheduled__c != null ? contact.Number_Of_Meetings_Scheduled__c + 1 : 1)));
				}
			}

			if (!leadIds.isEmpty()) {
				for (Lead lead : [SELECT Id, First_SAL_Date__c, SAL_Date__c, Lead_Stage__c, Status, Number_Of_Meetings_Scheduled__c
										  FROM Lead WHERE Id IN :leadIds AND Lead_Stage__c NOT IN ('SQL')]) {
					lstLeadsToUpdate.add(new Lead(Id = lead.Id, Lead_Stage__c = 'SAL', Status = 'Marketing Qualified: Sales Accepted',
						Number_Of_Meetings_Scheduled__c = (lead.Number_Of_Meetings_Scheduled__c != null ? lead.Number_Of_Meetings_Scheduled__c + 1 : 1)));
				}
			}

			try {
				if (!lstContactsToUpdate.isEmpty()) {
					Database.update(lstContactsToUpdate, false);
				}
				if (!lstLeadsToUpdate.isEmpty()) {
					Database.update(lstLeadsToUpdate, false);
				}
			} catch (Exception ex) {
				System.debug('>>>> Error occurred while updating Lead Stage to SAL. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
			}
	
		}else{
			system.debug('do not run the code as updateLeadStageToSAL is deactivated');
		}
        
    }
}