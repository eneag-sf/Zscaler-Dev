/*****************************************************************************************
Name: CaseTeam_to_CaseCCListBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Populate case cc list based on case team members

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           01-Feb-2019      Initial Development
******************************************************************************************/

public class CaseTeam_to_CaseCCListBatch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    public String que = '';
    public boolean runblankcclist;

    public CaseTeam_to_CaseCCListBatch(string q, boolean runonlyblankcc){
        que = q;
        runblankcclist = runonlyblankcc;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        //String query = 'Select Id, Case_CC_List__c from Case whereId in (Select ParentId from CaseTeamMember where TeamRole.Name = \'Internal Agent\' or TeamRole.Name = \'Customer\') and recordtype.name = \'Support\'';
        return Database.getQueryLocator(que);
    }

    public void execute(Database.BatchableContext context, List<Case> cslst){
        try{
            TriggerUtility.SkipCaseTriggerExecuted();
            List<Case> cslstfinal = new List<Case>();
            if(runblankcclist){
                for(Case cs: cslst){
                    if(cs.Case_CC_List__c == null || cs.Case_CC_List__c == ''){
                        cslstfinal.add(cs);
                    }
                }
            }else{
                cslstfinal.addAll(cslst);
            }
            CaseDetailLWCController.updatecaseCCList(cslstfinal);
        }catch(Exception ex){
            errorlst.add('Error: ' + ex);
        }
    }
    
    public void finish(Database.BatchableContext context){
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
            mail1.setSubject('Entitlement Creation Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){
                msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }
        if(!successlst.isEmpty()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Entitlement Creation Batch Success result ');
            mail.setPlainTextBody('Entitlement Creation Batch has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}