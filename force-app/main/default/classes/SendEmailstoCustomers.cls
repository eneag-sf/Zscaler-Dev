public class SendEmailstoCustomers implements Queueable {
    
    private ID Caseid;
    private String CaseCmnt;
    
    public SendEmailstoCustomers(ID id,String CaseComments) {
        this.Caseid = id;
        this.CaseCmnt = CaseComments;
    }
    public void execute(QueueableContext context) {
        sendEmail();
                        
    }

    public void sendEmail()  {
        Set<id> CCEmailidlist= new Set<id>();
        List<String> CCEmaillist= new List<String>();
        String MasterCaseEmailSubject= ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject')!=null && ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject').Value__c!=null ? ZscalerCustomSetting__c.getInstance('MasterCaseEmailSubject').Value__c:'Zscaler Support Ticket Update'; 
        
        String MasterCaseEmailSender= ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender')!=null && ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender').Value__c!=null ? ZscalerCustomSetting__c.getInstance('MasterCaseEmailSender').Value__c:'Zscaler Support';
        
        if(Caseid!=null){           
            Map<id,Case> CaseMap= new Map<id,Case>([Select id,Master_Case__c,ContactId,Contact.email,Case_CC_List__c from Case where Master_Case__c=:Caseid]);
            system.debug('CaseMap '+CaseMap);
            
            for(Case cs:CaseMap.values()){
                CCEmaillist.add(cs.Contact.email);                       
                if(cs.Case_CC_List__c!=null && cs.Case_CC_List__c!=''){
                    CCEmaillist.addall(cs.Case_CC_List__c.split(','));
                }
            }
            system.debug('CCEmaillist  '+CCEmaillist);
            //CCEmaillist.add('manngurjinder2@gmail.com');
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@zscaler.com'];
            
            list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] sendingToAdd = new String[]{Userinfo.getUserEmail()};
            mail.setToAddresses(sendingToAdd);      

            if( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{ 
            mail.setsenderDisplayName(MasterCaseEmailSender);
            }
            mail.setbccAddresses(CCEmaillist);
            mail.setSubject(MasterCaseEmailSubject);
            String messageBody = '<html><body>Dear Customer, ' + '<br><br>Please find the Latest Comments Added for your Case:-  <br><br>' +CaseCmnt +'<br><br> Thank You<br><br>Zscaler Support</body></html>';
            mail.setHtmlBody(messageBody);
            messageList.add(mail);
            Messaging.sendEmail(messageList);  
        }           
    }
    
}