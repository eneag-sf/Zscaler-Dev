/* Class:     CLDY_GenerateDoc
 * Purpose:   This global class will generate document and send callout request to Appttus merge webservice
 * CreatedBy: CLDY DEV
 * Date:      8/24/2016
 */
global class GenerateDocWebServiceDemo_New {

    //@Future(callout=true)
    webservice static String generateDocument(Id agmntId, Id QuoteId, String SessionId){
        if(agmntId != null && QuoteId != null && SessionId != null){
            list<Apttus__APTS_Template__c> templateIds = [select id from Apttus__APTS_Template__c where Name ='New Zscaler Executive Document' AND Apttus__IsActive__c = true limit 1];
            System.debug('SessionId==>'+SessionId);
            //String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();

            string apiServerURL = Apttus_Config2__ConfigSystemProperties__c.getAll().get('System Properties').Apttus_Config2__InstanceUrl__c + '/services/Soap/u/33.0/' + UserInfo.getOrganizationId();
            System.debug('apiServerURL=>'+apiServerURL);
            Id recordId = agmntId;
            String accessLevel = 'Full';
            String docFormat = 'doc';
            boolean isDraft = false;

            String generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(templateIds[0].Id
                    , recordId
                    , accessLevel
                    , docFormat
                    //, isDraft
                    , sessionId
                    , apiServerURL);

            return generatedDocId;
            //String generatedDocId = Apttus.MergeWebService.generateSupportingDoc2(templateIds.get(0).Id, agmntId, 'Full access', 'DOC', false, SessionId, apiServerURL);
            //Attachment att = [SELECT Id, ParentId, Name, ContentType, Body, OwnerId, Description FROM Attachment where id = :generatedDocId];
            //system.debug('AttachmentId: ' + att.id);
            //system.debug('AttachmentParentId: ' + att.id);
            //Attachment attForQuote = att.clone();
            //attForQuote.ParentId = QuoteId;
            //insert attForQuote;
        }
        return null;
    }
}