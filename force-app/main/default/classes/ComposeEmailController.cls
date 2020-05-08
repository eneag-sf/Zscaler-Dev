public with sharing class ComposeEmailController {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getOrgWideId() {
        List<Map<String,String>> objList = new List<Map<String,String>>();
        for (OrgWideEmailAddress owa : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress]) {
            map<string,string> customOption = new map<string,string>();
            customOption.put('label',owa.DisplayName + ' <' + owa.Address + '>');
            customOption.put('value',owa.Id);
            objList.add(customOption);      
        }
        system.debug('-objList-'+objList);
        return objList;   
    } 

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTemplateBody(Id templateId, Id relatedId) {
        Map<String, Object> returnTemplateBody = new Map<String, Object>();
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId, null, relatedId);
        system.debug('message.getHtmlBody()>>>'+message.getHtmlBody());
        system.debug('message.getPlainTextBody()>>>'+message.getPlainTextBody());
        system.debug('message.getPlainTextBody()>>>'+message.getSubject());
        
        if(message.getHtmlBody() != null){
            returnTemplateBody.put('htmlBody', message.getHtmlBody());
        } else{
            returnTemplateBody.put('htmlBody', message.getPlainTextBody());
        }
        
        returnTemplateBody.put('subject', message.getSubject());
        return returnTemplateBody;
    }

    @AuraEnabled(cacheable=true)
    public static CustomSendMailResult sendEmail(Map<Object,Object> sendEmailRef) {
        CustomSendMailResult csr = new CustomSendMailResult();
        try {
            
            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();
            List<String> bccAddressList = new List<String>();
            
            system.debug('sendEmailRef>>'+sendEmailRef);
            string toAddress = String.valueOf(sendEmailRef.get('toAddress'));
            if( toAddress.contains(';') || toAddress.contains(',') ){
                if(toAddress.contains(';')){
                    if(toAddressList.isEmpty()){
                        toAddressList.addAll(toAddress.split(';'));
                    }
                } else if(toAddress.contains(',')){
                    if(toAddressList.isEmpty()){
                        toAddressList.addAll(toAddress.split(','));
                    }
                } 
            } else{
                toAddressList.add(toAddress);
            }
            system.debug('toAddressList>>>>>>>>>'+toAddressList);
            string ccAddress = String.valueOf(sendEmailRef.get('ccAddress'));
            if(String.isNotBlank(ccAddress)){
                if( ccAddress.contains(';') || ccAddress.contains(',') ){
                    if(ccAddress.contains(';')){
                        if(ccAddressList.isEmpty()){
                            ccAddressList.addAll(ccAddress.split(';'));
                        }
                    } 
                    if(ccAddress.contains(',')){
                        if(ccAddressList.isEmpty()){
                            ccAddressList.addAll(ccAddress.split(','));
                        }
                    }
                } else{
                    ccAddressList.add(ccAddress);
                }
            }
            
            string bccAddress = String.valueOf(sendEmailRef.get('bccAddress'));
            if(String.isNotBlank(bccAddress)){
                if( bccAddress.contains(';') || bccAddress.contains(',') ){
                    if(bccAddress.contains(';')){
                        if(bccAddressList.isEmpty()){
                            bccAddressList.addAll(bccAddress.split(';'));
                        }
                    } else if(bccAddress.contains(',')){
                        if(bccAddressList.isEmpty()){
                            bccAddressList.addAll(bccAddress.split(','));
                        }
                    }
                } else{
                    bccAddressList.add(bccAddress);
                }
            }
            string additionalTo = String.valueOf(sendEmailRef.get('additionalTo'));
            if(String.isNotBlank(additionalTo)){
                if( additionalTo.contains(';') || additionalTo.contains(',') ){
                    if(additionalTo.contains(';')){
                        toAddressList.addAll(additionalTo.split(';'));
                    } else if(additionalTo.contains(',')){
                        toAddressList.addAll(additionalTo.split(','));
                    }
                } else{
                    toAddressList.add(additionalTo);
                }
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddressList);
            mail.setOrgWideEmailAddressId(String.valueOf(sendEmailRef.get('fromAddress')));
            mail.setCcAddresses(ccAddressList);
            mail.setBccAddresses(bccAddressList);
            String templateID = sendEmailRef.get('templateId') != null ? String.valueOf(sendEmailRef.get('templateId')) : null;
            if(templateID != null)
                mail.setTemplateId(String.valueOf(sendEmailRef.get('templateId')));
            mail.setSubject(String.valueOf(sendEmailRef.get('subject')));
            mail.setHtmlBody(String.valueOf(sendEmailRef.get('emailBody')));
            system.debug('email record>>>'+mail);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            csr.isSuccess = true;
            csr.successMsg = 'Success';
            System.debug('--sendEmail--csr--'+csr);
            return csr;
            
        } catch (Exception ex) {
            csr.isSuccess = false;
            csr.isException = true;
            csr.errorMessage = 'Error occurred while sending Email.';
            csr.exceptionMessage = ex.getMessage();
            System.debug('--sendEmail--csr--'+csr);
            return csr;
        }
    }
    
    public class CustomSendMailResult{
        @AuraEnabled
        public boolean isSuccess			{get;set;}
        @AuraEnabled
        public String successMsg			{get;set;}
        @AuraEnabled
        public boolean isException			{get;set;}
        @AuraEnabled
        public String errorMessage			{get;set;}
        @AuraEnabled
        public String exceptionMessage		{get;set;}
    }
    
}