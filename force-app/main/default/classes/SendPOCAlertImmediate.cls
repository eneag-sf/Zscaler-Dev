global class SendPOCAlertImmediate{
    webservice static String pocSendEmail(Id prId){
        String status = 'Success';
        List<Provisioning_Request__c> prlst = [Select Id, Days_Left_After_Reminder_Initiation__c, Primary_Eval_Contact__r.Name, Tentative_Deprovision_Date__c, Account__r.Name, Email_Sent__c, Send_Reminder_Emails__c, SE__r.Id, SE__r.Email, Account__r.OwnerId, Account__r.Owner.Email, Opportunity__r.Owner.Email, Opportunity__r.OwnerId, Primary_Eval_Contact__c, POC_Alert_Recipient_1__c, POC_Alert_Recipient_1__r.Email, POC_Alert_Recipient_2__c, POC_Alert_Recipient_2__r.Email, POC_Alert_Recipient_3__c, POC_Alert_Recipient_3__r.Email, Account_Manager__r.Email, SE_Manager_Email__c, OwnerId, SE__c from Provisioning_Request__c where Id=:prId];
        if(!prlst.isEmpty()){
            Provisioning_Request__c pr = prlst[0];
            Set<Id> accIds= new Set<Id>();
            String emailtempname = '';
            Set<Id> activeusers = new Set<Id>();
            if(pr.SE__c != null){
                activeusers.add(pr.SE__c);
            }
            if(pr.POC_Alert_Recipient_1__c != null){
                activeusers.add(pr.POC_Alert_Recipient_1__c );
            }
            if(pr.POC_Alert_Recipient_2__c != null){
                activeusers.add(pr.POC_Alert_Recipient_2__c );
            }
            if(pr.POC_Alert_Recipient_3__c != null){
                activeusers.add(pr.POC_Alert_Recipient_3__c);
            }
            if(!activeusers.isEmpty()){
                for(User u: [Select Id from User where Id in :activeusers and isActive = false]){
                    activeusers.remove(u.Id);
                }    
            }
            emailtempname = 'Email Reminders on POC To Customer';
            EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
            List<string> emailIdList = new List<string>();
            List<string> ccList = new List<string>();
            List<string> bccList = new List<string>();
            Set<string> partneremails = new Set<string>();
            list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
            if(POC_Notification_Batch.runningInASandbox()){
                emailIdList.clear();
                for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                    emailIdList.add(s);
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, pr.Primary_Eval_Contact__c, pr.Id);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pocdecommissionalert@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setToAddresses(emailIdList);
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }else{
                emailIdList.clear();
                
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, pr.Primary_Eval_Contact__c, pr.Id);
                if(pr.Account__r.OwnerId != null){
                    ccList.add(pr.Account__r.Owner.Email);
                }                
                if(pr.Opportunity__r.OwnerId != null){
                    ccList.add(pr.Opportunity__r.Owner.Email);
                }              
                if(pr.SE__c != null && activeusers.contains(pr.SE__c)){
                    ccList.add(pr.SE__r.Email);
                }  
                
                if(pr.POC_Alert_Recipient_1__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_1__c)){
                    bccList.add(pr.POC_Alert_Recipient_1__r.Email);
                }
                if(pr.POC_Alert_Recipient_2__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_2__c)){
                    bccList.add(pr.POC_Alert_Recipient_2__r.Email);
                }
                if(pr.POC_Alert_Recipient_3__r.Email != null && activeusers.contains(pr.POC_Alert_Recipient_3__c)){
                    bccList.add(pr.POC_Alert_Recipient_3__r.Email);
                }
                
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pocdecommissionalert@zscaler.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(!ccList.isEmpty()){
                    mail.setCcAddresses(ccList);
                }
                if(!bccList.isEmpty()){
                    mail.setBccAddresses(bccList);
                }
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
            String sentemailsto = '';
            Integer countofmails = 0;
            try{
                for(String s: ccList){
                    sentemailsto += s + ';';
                }
                for(String s: bccList){
                    sentemailsto += s + ';';
                }
                
                countofmails += ccList.size();
                countofmails += bccList.size();
                
                if(POC_Notification_Batch.canSendEmail(countofmails)){
                    Messaging.sendEmail(emailList);
                    
                    Task actHistory = new Task(Subject='POC Decommision Alerts Email sent on ' + Date.Today(), WhatId=pr.Id, Status='Completed', ActivityDate=Date.today(), Description='POC Decommision Alerts Email sent to below addresses: \n ' + sentemailsto + '\n Template Used: ' + emailtempname, OwnerId = pr.OwnerId ,Priority='Normal', type='Other');
                    actHistory.WhoId = null;
                    insert actHistory;
                }else{
                    status = 'No more Email limits left. Please contact SFDC Admin to send emails';
                }
            }catch(Exception e){
                status = 'Error: ' + e;
            }
        }
        return status;
    }
}