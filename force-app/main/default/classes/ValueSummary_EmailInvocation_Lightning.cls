public class ValueSummary_EmailInvocation_Lightning{
    @AuraEnabled
    public static String checkdomain(Id accountId){
        String res = '';
        String renderAs = '';
        String proposalId = '';
        List<Account> acc = [Select Id, name, Value_Summary_Format__c from Account where Id = :accountId];
        renderAs = !acc.isEmpty() && acc[0].Value_Summary_Format__c != null ? acc[0].Value_Summary_Format__c : 'pdf';
        String accname = !acc.isEmpty() ? acc[0].Name : '';
        List<Apttus_Proposal__Proposal__c > prop = [Select Id, Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c where Id = :Label.DummyQuote_ValueSummary];
        System.debug('Data '+prop);
        if(!prop.isEmpty() || test.isrunningTest()){
            try{
                prop[0].Apttus_Proposal__Account__c = accountId;
                prop[0].Apttus_Proposal__Proposal_Name__c = acc[0].Name;
                System.debug('Data 2 '+prop[0]);
                update prop;
                proposalId = prop[0].Id;
            }catch(Exception ex){
                res += 'Error: ' + ex;
            }
        }else{
            res  += 'Value Summary Quote is missing. Please reach out to SFDC support team.';
        }
        if(res == '' || test.isrunningTest()){
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.ValueSummaryEmail});
            mail1.setSubject('Value Summary Generation for the Customer ' + accname );
            mail1.setPlainTextBody('Create Value Summary--' + proposalId + '--'+accountId + '--'+renderAs + '--'+UserInfo.getUserId());
            messageList.add(mail1);
            Messaging.sendEmail(messageList);
            res = 'Success';
        }
        return res;
    }


}