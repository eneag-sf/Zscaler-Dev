/*****************************************************************************************
Name: AmberRoadService
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Class to process asynchronous email notifications from Amber Road
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     14-Oct-2016    Initial Development
******************************************************************************************/
global class AmberRoadAsyncEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String messageBody;

        //Validate the email body contents and return if the body is invalid
        System.debug(email.plainTextBody);
        if (null == email.plainTextBody
            || '' == email.plainTextBody.trim()) {
            result.success = false;
            return result;
        }

        //Parse the email body (plain text)
        messageBody = email.plainTextBody;
        AmberRoadAccountModel accountModel = new AmberRoadAccountModel();
        AmberRoadService.deserializeXML(messageBody, accountModel);
        System.debug(accountModel);
        //Update the response in SF by identifying the account with PartnerId
        try {
            Account accountToBeUpdated = [SELECT Id, Name, Amber_Road_Status__c FROM Account WHERE Id = :accountModel.PartnerId LIMIT 1];

            if ('1000' == accountModel.integrationStatus.statusCode
            	&& null != accountToBeUpdated) {
                accountToBeUpdated.Amber_Road_Status__c = accountModel.status;
                update accountToBeUpdated;
                result.success = true;
            } else if (null != accountToBeUpdated) {
            	accountToBeUpdated.Amber_Road_Status__c = 'Failed To Screen';
            	accountToBeUpdated.Amber_Road_Integration_Status__c = accountModel.integrationStatus.statusCode + ' - ' + accountModel.integrationStatus.statusDescription;

                Database.DMLOptions options = new Database.DMLOptions();
                options.AllowFieldTruncation = true;
            	Database.update(accountToBeUpdated, options);
            	result.success = false;
            }
        } catch (Exception ex) {
        	throw new AmberRoadService.AmberRoadServiceException('Error occurred while processing Amber Road email notification. \nReason: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }

        return result;
    }
}