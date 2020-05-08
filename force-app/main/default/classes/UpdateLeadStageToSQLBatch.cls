global class UpdateLeadStageToSQLBatch implements Database.Batchable<SObject>, Database.Stateful {

    global String startDate { get; set; }
    global String endDate { get; set; }
    global List<Contact> lstContactsToUpdate { get; set; }

    global UpdateLeadStageToSQLBatch(String startDate, String enddate) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.lstContactsToUpdate = new List<Contact>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
		
		if(OnOffSwitch__c.getInstance('UpdateLeadStageToSQLBatch').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('UpdateLeadStageToSQLBatch').Deactivate_Component__c==False){
			system.debug('run the code ');
			String query = 'SELECT Id, OpportunityId, ContactId, Contact.Lead_Stage__c FROM OpportunityContactRole WHERE Contact.Lead_Stage__c <> \'SQL\' AND CreatedDate >= ' + startDate + ' AND CreatedDate <= ' + endDate;
			System.debug('>>>> query: ' + query);
			return Database.getQueryLocator(query);
	
		}else{
			system.debug('do not run the code as UpdateLeadStageToSQLBatch is deactivated');
			String query='';
			return Database.getQueryLocator(query);
		}
        
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
		if(!scope.isempty() && scope.size()>0){
			for (OpportunityContactRole ocr : (List<OpportunityContactRole>)scope) {
            lstContactsToUpdate.add(new Contact(Id = ocr.ContactId, Lead_Stage__c = 'SQL'));
			}
		}
        
    }

    global void finish(Database.BatchableContext bc) {
        try {
			if(OnOffSwitch__c.getInstance('UpdateLeadStageToSQLBatch').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('UpdateLeadStageToSQLBatch').Deactivate_Component__c==False){
				Database.update(lstContactsToUpdate, false);
			}else{
				system.debug('do not run the code as UpdateLeadStageToSQLBatch is deactivated');
			}
        } catch (Exception ex) {
            System.debug('>>>> Error occurred while updating Contact Lead Stage to SQL : ' + ex.getMessage() + ' ' + ex.getStackTraceString());
        }
    }
}