public class ConfirmationBoxApexController {
    @auraEnabled
    public static void sendMail(String caseId,String emailBody){
        System.debug('--caseId--'+caseId);
        Case caserec = [SELECT ContactId,Contact.Email FROM Case where id =:caseId limit 1];
        //String theTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NonSfTaskAssignment'].Id;
        List<String> lstCntIds = new List<String>();
        List<String> lstEmailIds = new List<String>();
        List<CaseTeamMember> lstCaseTeamMembs = [Select Id,MemberId from CaseTeamMember WHERE ParentId=: CaseId];
        if(!lstCaseTeamMembs.isEmpty()){
            for(CaseTeamMember csMembs : lstCaseTeamMembs){
                if(csMembs.MemberId != null && String.valueOf(csMembs.MemberId).substring(0,3) == '003'){
                    lstCntIds.add(csMembs.MemberId);
                }                
            }
        }
        if(!lstCntIds.isEmpty()){
            List<Contact> lstContcs = [Select Id,Email From Contact WHERE Id in: lstCntIds];
            if(!lstContcs.isEmpty()){
                for(Contact cnt: lstContcs){
                    if(cnt.email != null){
                        lstEmailIds.add(cnt.Email);
                    }
                }
            }
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSaveAsActivity(false);
        mail.setHtmlBody(emailBody);
        mail.setSubject('TAM Account Engagement Weekly Meeting Notes');
        mail.setTreatTargetObjectAsRecipient(true);
        if(caserec.Contact.Email != null){
            mail.setToAddresses(new List<String>{caserec.Contact.Email});
        }else {
            mail.setToAddresses(new List<String>{'tirthpatel.5892@gmail.com'});
        }
        if(!lstEmailIds.isEmpty()){
            mail.setCcAddresses(lstEmailIds);            
        }
        
        //mail.setToAddresses(new List<String>{'tirthpatel.5892@gmail.com'});
        //mail.setReplyTo(tsk.Owner.email);
        emails.add(mail);
        
        if(emails.size()>0 && ! Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails,false);
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }else{
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            } 
        }  
        
    }
    @auraEnabled
    public static String getEmailText(String caseId){
        System.debug('--caseId--'+caseId);
        Case caserec = [SELECT ContactId,Attachment_Id__c,email_Body__c FROM Case where id =:caseId limit 1];
        /*Attachment atchObj;
        if(caserec.Attachment_Id__c != null){
            atchObj = [Select Id,Body from Attachment WHERE Id=: caserec.Attachment_Id__c];
        }*/
        
        String emailBody = '';
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [Select Id, Name from EmailTemplate where DeveloperName = 'TAM_Account_Email'];
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.Id, caserec.ContactId, caseId);
        //System.debug('email.htmlbody:-'+email.htmlbody);
        emailBody = email.htmlbody;
        if(caserec.Email_Body__c != null && caserec.Email_Body__c != ''){
            emailBody = caserec.Email_Body__c;
        }
        return emailBody;
    }
    
    @auraEnabled
    public static String setEmailTextOnCase(String caseId, String emailBody){
        if(emailBody.length() < 131072){
            System.debug('emailBody size:-'+emailBody.length());
            Case caseObj = [Select Id, Attachment_Id__c,email_Body__c from Case WHERE Id=: CaseId];
            System.debug('--caseId--'+caseId);
            Attachment atchObj;
            if(caseObj != null){
                if(caseObj.email_Body__c != null){
                    caseObj.Email_Body__c = emailBody;
                    update caseobj;
                }else if(caseObj.email_Body__c == null){
                    caseObj.Email_Body__c = emailBody;
                    update caseobj;
                }
                /*
if(caseObj.Attachment_Id__c != null){
atchObj = new Attachment(Id=caseObj.Attachment_Id__c);
atchObj.Body = Blob.valueOf(emailBody);
update atchObj;    
}else if(caseObj.Attachment_Id__c == null){
atchObj = new Attachment();
atchObj.Name = caseId;
atchObj.Body = Blob.valueOf(emailBody);
atchObj.ParentId = caseId;
insert atchObj;

Case csObj = new Case(Id=caseId);
csObj.Attachment_Id__c = atchObj.Id;
update csObj;
}  */  
            }
            return 'Success';
        }
        else{
            return 'size limit exceed';
            //throw new AuraHandledException('NSFW name detected.');
        }
    }
}