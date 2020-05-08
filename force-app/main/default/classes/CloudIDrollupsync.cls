global class CloudIDrollupsync implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String qry = '';
    
    global CloudIDrollupsync(String q)
    {
        qry = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        String query = qry;
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext context, List<Zscaler_Cloud_ID__c> zclst){
        List<Zscaler_Cloud_ID__c> zclsttoupdate = new List<Zscaler_Cloud_ID__c>();

        for(Zscaler_Cloud_ID__c zc: zclst){
            if(!zc.Monthly_Policy_Configurations__r.isEmpty()){
                for(Monthly_Policy_Configurations__c mpc: zc.Monthly_Policy_Configurations__r){
                    zc.Number_of_GRE_tunnels__c = mpc.Number_of_GRE_Tunnels__c;
                    zc.Total_number_of_IPSec_tunnels__c = mpc.Number_of_IP__c;
                    zc.Total_Unique_Z_app_Users__c = mpc.unique_Z_app_Users__c;
                    zc.Total_SSL_Inspected_Transactions__c = mpc.Total_SSL_Inspected_Transactions__c;
                    zclsttoupdate.add(zc);
                }
            }  
        }
        Database.SaveResult[] srList = database.update(zclsttoupdate, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(sr.getId() + ' - ' + err.getMessage());
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext context){
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            
            
            if(!errorlst.isEmpty()){
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
                if ( owea.size() > 0 ) {
                    mail1.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail1.setsenderDisplayName('Sales Ops System Admin');
                }
                mail1.setSubject('CloudId update failure');
                mail1.setPlainTextBody('Below are the details of records that have failed:' + errorlst);
                messageList.add(mail1);
            }else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {Label.BSYS_INFO});
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setSubject('CloudId update success');
                mail.setPlainTextBody('CloudId batch has been executed Successfully');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}