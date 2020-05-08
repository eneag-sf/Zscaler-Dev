/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class CreateValueSummaryfromEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        String subToCompare = 'Value Summary Generation';
        List<String> reqmsgs = email.plainTextBody != null && email.plainTextBody != '' ? email.plainTextBody.split('--') : new List<String>();
        String subject = '';
        String quoteId = '';
        String accountId = '';
        String format = '';
        String userId = '';
        
        if(!reqmsgs.isEmpty()){
            subject = email.subject;
            quoteId = reqmsgs[1];
            accountId = reqmsgs[2];
            format = reqmsgs[3];
            userId = reqmsgs[4];
        }
        try{
            if(subject != '' && subject.containsIgnoreCase(subToCompare))
            {
                String docId = ValueSummaryDocController.generateDoc(quoteId + '---'+ accountId + '---' + format + '---'+ userId);
                if(docId != '' && docId != null && docId.substring(0,3) == '00P'){
                    result.message = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Value_Summary_Email_Redirection?id=' + accountId + '&docId=' + docId; 
                }else{
                    result.message = docId;
                }
            }else{
                result.message = 'Invalid Request. Please contact SFDC Support.';
            }
        }catch(Exception ex){
            result.message += '\n' + ex;
        }
        result.success = true;
        return result;
    }
}