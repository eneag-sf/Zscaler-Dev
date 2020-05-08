/*****************************************************************************************
Name: UpdateRollupDetailsonCampaigns
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to update rollup information on Campaigns

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Gurjinder          18Dec-2019      Initial Development
******************************************************************************************/

public class UpdateRollupDetailsonCampaigns implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();

    public Database.QueryLocator start(Database.BatchableContext context){
        //id campgnid='7010g0000016Owy';
        //String query = 'Select Id,Count_of_SCI_s__c,Count_of_MCI_s__c from Campaign where id=:campgnid';
        String query = 'Select Id,Count_of_SCI_s__c,Count_of_MCI_s__c from Campaign';
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Campaign> CmpgnList){
        decimal SCIcount=0;
        decimal OldSCIcount=0;
        decimal MCIcount=0;
        decimal OldMCIcount=0;
        
        Campaign Cmpgn = CmpgnList[0];
        
        if(Cmpgn.Count_of_SCI_s__c!=null){
            OldSCIcount=Cmpgn.Count_of_SCI_s__c;
        }
        if(Cmpgn.Count_of_MCI_s__c!=null){
            OldMCIcount=Cmpgn.Count_of_MCI_s__c;
        }
        cmpgn.Count_of_MCI_s__c=[Select count() from CampaignMember Where Campaignid=:Cmpgn.id];
        cmpgn.Count_of_SCI_s__c=[Select count() from Significant_Customer_Interaction__c Where Campaign__c=:Cmpgn.id];
        try{
          if(cmpgn.Count_of_MCI_s__c!=oldMCIcount || cmpgn.Count_of_SCI_s__c!=oldSCIcount){
                    update cmpgn;
                    successlst.add(cmpgn.Id);
                }
        }catch(Exception e){ errorlst.add('Exception on Cmpgn:' + cmpgn.Id + '. Exception is ' + e);
        }
    }
    
    public void finish(Database.BatchableContext context){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();     
        if(!errorlst.isEmpty()){          
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {  mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{ mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Campaign Rollup Update Batch Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' records that have failed: \n';
            for(String s: errorlst){ msgbody += s + '\n';
            }
            mail1.setPlainTextBody(msgbody);
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{ mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Campaign Rollup Update Batch Success result ');
            mail.setPlainTextBody('Campaign Rollup Update Batch has been executed Successfully and processed '+ successlst.size() + ' records');
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
    }
    
}