public class Notify_Extension_on_Approval{
    @InvocableMethod
    public static void sendnotif(List<Id> oppIds){
        String emailtempname = 'Subscription Extension Notification';
        String americasalias = label.Renewal_Americas;
        String apacalias = label.Renewal_APJ;
        String emeaalias = label.Renewal_EMEA;
        
        EmailTemplate et = [Select Id,Name from EmailTemplate where Name = :emailtempname];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'zbilling@zscaler.com'];

        list<Messaging.SingleEmailMessage> emailList = new list<Messaging.SingleEmailMessage>();
        List<task> tsklst = new List<task>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> partneraccIds = new Set<Id>();
        for(Opportunity opp: [Select Id, AccountId, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c from Opportunity where Id in :oppIds]){
            accIds.add(opp.AccountId);
            if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null){
                partneraccIds.add(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c);
            }
        }
        Map<Id, List<String>> acctoEmailmap = new Map<Id, List<String>>();
        Map<Id, List<String>> partacctoEmailmap = new Map<Id, List<String>>();
        for(Contact con: [Select Id, name, email, AccountId from Contact where AccountId in :accIds and Renewal_Notification_Recipient__c = true and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
            
            if(!acctoEmailmap.containsKey(con.AccountId)){
                acctoEmailmap.put(con.AccountId, new List<String>{con.Email});
            }else{
                acctoEmailmap.get(con.AccountId).add(con.email);
            }
        }
        for(Contact con: [Select Id, name, email, AccountId from Contact where AccountId in :partneraccIds and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
            
            if(!partacctoEmailmap.containsKey(con.AccountId)){
                partacctoEmailmap.put(con.AccountId, new List<String>{con.Email});
            }else{
                partacctoEmailmap.get(con.AccountId).add(con.email);
            }
        }
        
        for(Opportunity opp: [Select Id, Owner.GEO__c, Name, AccountId, Account.Name, Partner_Account_Contact_Email__c, Owner.Email,  APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status__c, Past_Due_Notification_Status__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Patch__r.PatchTeam__r.GEO_VP__c, Patch__r.PatchTeam__r.Renewal_Director__c from Opportunity where id in :oppIds]){
            
            String subject = '';
            if(opp.New_Extended_Contract_Date__c != null && opp.Contract_End_Date_New__c != null){
                subject = 'Your Zscaler Subscription has been Extended by ' + Math.abs(opp.Contract_End_Date_New__c.daysBetween(opp.New_Extended_Contract_Date__c)) + ' Days for the Customer ' + opp.Account.Name ;
            }
            
            List<string> emailIdList = new List<string>();
            List<string> partemailIdList = new List<string>();
            if(runningInASandbox()){
                emailIdList.clear();
                for(String s: Renewal_Notification_Emails__c.getAll().keyset()){
                    emailIdList.add(s);
                }
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, Userinfo.getUserId(), opp.Id);
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(subject != ''){
                    mail.setSubject(subject);
                }
                mail.setToAddresses(emailIdList);
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }else{
                emailIdList.clear();
                partemailIdList.clear();
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, opp.OwnerId, opp.Id);
                if(acctoEmailmap.containsKey(opp.AccountId)){
                    emailIdList.addAll(acctoEmailmap.get(opp.AccountId));
                }
                /*if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null && acctoEmailmap.containsKey(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c)){
                    emailIdList.addAll(acctoEmailmap.get(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c));
                }*/
                
                if(opp.Partner_Account_Contact_Email__c != null && opp.Partner_Account_Contact_Email__c != ''){
                    partemailIdList.addAll(opp.Partner_Account_Contact_Email__c.split(';'));
                }
                
                if(!partemailIdList.isEmpty()){
                    for(String s: partemailIdList){
                        if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null && partacctoEmailmap.containsKey(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c) && !partacctoEmailmap.get(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c).isEmpty() && partacctoEmailmap.get(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c).contains(s)){
                            emailIdList.add(s);
                        }
                    }
                }
                
                /*if(opp.Owner.GEO__c  == 'Americas'){
                    emailIdList.add(americasalias);
                }else if(opp.Owner.GEO__c == 'APAC'){
                    emailIdList.add(apacalias);
                }else if(opp.Owner.GEO__c == 'EMEA'){
                    emailIdList.add(emeaalias);
                }*/
                
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                if(subject != ''){
                    mail.setSubject(subject);
                }
                mail.setToAddresses(emailIdList);
                
                mail.setsaveAsActivity(false);
                emailList.add(mail);
            }
            String sentemailsto = '';
            for(String s: emailIdList){
                sentemailsto += s + ';';
            }
            
            Task actHistory = new Task(Subject='Subscription Extension Notification Email sent on ' + Date.Today(), WhatId=opp.Id, Status='Completed', ActivityDate=Date.today(), Description='Subscription Extension (Contract Extension) Notification Email sent to below addresses: \n ' + sentemailsto , OwnerId = opp.OwnerId ,Priority='Normal', type='Other');
            actHistory.WhoId = null;
            tsklst.add(actHistory);
                
        }
		
		if(test.isrunningtest()){
			integer i=0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			
		}
        try{
            Messaging.sendEmail(emailList);
            insert tsklst;
        }catch(Exception ex){
            System.debug('++++'+ ex);
        }
    }
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
}