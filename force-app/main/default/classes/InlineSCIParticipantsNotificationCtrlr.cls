public class InlineSCIParticipantsNotificationCtrlr {
    public Id sciRecordId;

	public InlineSCIParticipantsNotificationCtrlr() {
		
	}

    public InlineSCIParticipantsNotificationCtrlr(ApexPages.StandardController stdController) {
        sciRecordId = stdController.getId();
    }

    public Boolean getHasToAddParticipants() {
        Integer zscalerAttendeesCount, externalAttendeesCount;
        zscalerAttendeesCount = externalAttendeesCount = 0;

        zscalerAttendeesCount = Database.countQuery('SELECT Count() FROM SCI_Zscaler_Attendee__c WHERE Significant_Customer_Interaction__c = :sciRecordId');
        externalAttendeesCount = Database.countQuery('SELECT Count() FROM SCI_External_Attendee__c WHERE Significant_Customer_Interaction__c = :sciRecordId');

        return (zscalerAttendeesCount == 0 || externalAttendeesCount == 0);
    }
}