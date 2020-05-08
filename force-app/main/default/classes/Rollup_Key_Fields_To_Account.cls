/*****************************************************************************************
Name: CTM, SCI, Opportunity Rollup info onto Account
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. CTM, SCI, Opportunity Rollup info onto Account

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           29-Apr-2019      Initial Development
******************************************************************************************/

public class Rollup_Key_Fields_To_Account implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    
    public Database.QueryLocator start(Database.BatchableContext context){
        //String AccountId = '0017000000YXqAt';
        //Testing
        //String query = 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account where Type = \'Customer\' and Id =: AccountId';
        //String query = 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account where Type = \'Customer\' FOR UPDATE';
        String query = 'Select Id, Number_of_Ramped_Users__c, Link_to_Value_Output__c, Last_SCI_Date__c, Service_Owner_Present__c, Head_of_IT__c, Head_of_Networking__c, Head_of_Security__c from Account where Type = \'Customer\' ';
        return Database.getQueryLocator(query);
        
    }
    
    public void execute (Database.BatchableContext context, List<Account> acclst){
        Account acc = acclst[0];
        Set<String> setSKUCodes = new Set<String> {
                                        APTS_CONSTANTS.PROD_SKU_SIP,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_PROBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_BUSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_TRANSBUNDLE,
                                        APTS_CONSTANTS.PROD_SKU_ZIA_ELABUNDLE
                                    };
        Decimal oldrampedusers = acc.Number_of_Ramped_Users__c;
        Boolean oldhs = acc.Head_of_Security__c;
        Boolean oldhn = acc.Head_of_Networking__c;
        Boolean oldit = acc.Head_of_IT__c;
        Boolean oldserviceowner = acc.Service_Owner_Present__c;
        DateTime oldlastsci = acc.Last_SCI_Date__c;
        
        String oldlinktovalueoutput = acc.Link_to_Value_Output__c;
        
        try{
        
            Date today = date.today();
            List<AggregateResult> totalusers = [SELECT SUM(Quantity__c) a FROM Contract_Detail__c WHERE (Contract_Detail_Status__c = 'Active' OR Contract_Detail_Status__c = 'Renewed') and Start_Date__c <= :today and End_Date__c >= :today and Product_SKU__c in :setSKUCodes and Account_Name__c = :acc.Id];
            acc.Number_of_Ramped_Users__c = totalusers[0].get('a') == null ? 0 : (Decimal)totalusers[0].get('a');
        
            List<AggregateResult>  hslst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_Security__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hslst.size() > 0)
            {
                acc.Head_of_Security__c = (Decimal)hslst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  hnlst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_Networking__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hnlst.size() > 0)
            {
                acc.Head_of_Networking__c = (Decimal)hnlst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  hilst = [select count(Id) q from Contact where AccountId=:acc.Id and Head_of_IT__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(hilst.size() > 0)
            {
                acc.Head_of_IT__c = (Decimal)hilst[0].get('q') > 0 ? true : false;
            }
            
            List<AggregateResult>  solst = [select count(Id) q from Contact where AccountId=:acc.Id and Service_Owner__c = true and Contacts_that_matter__c = true and (Key_Contact_Status__c = 'Sales Accepted' or Key_Contact_Status__c = 'CSM Accepted')];
            if(solst.size() > 0)
            {
                acc.Service_Owner_Present__c = (Decimal)solst[0].get('q') > 0 ? true : false;
            }
            
            List<Significant_Customer_Interaction__c>  scilst = [select Id, CreatedDate from Significant_Customer_Interaction__c where Account_Name__c=:acc.Id and CreatedDate=LAST_N_DAYS:90 and Recordtype.name not in ('Marketing/CXO Event') order by CreatedDate DESC Limit 1];
            if(scilst.size() > 0)
            {
                acc.Last_SCI_Date__c = scilst[0].CreatedDate;
            }else{
                acc.Last_SCI_Date__c = null;
            }
            
            String Stage1 = label.Stage_7_Closed_Lost;
            //String Stage2 = label.Stage_6_Closed_Won;
            List<String> StageList = new List<String>(); 
            StageList.add(Stage1);
            //StageList.add(Stage2);
            
            List<Opportunity>  opplst = [select Id, Link_to_Value_Output__c from Opportunity where AccountId=:acc.Id order by Lastmodifieddate DESC];
            //List<Opportunity>  opplst = [select Id, Link_to_Value_Output__c from Opportunity where AccountId=:acc.Id and Stagename not in ('11 - Closed Lost', '12 - Closed With No Decision', '14 - Closed: Delete Duplicate') order by Lastmodifieddate DESC Limit 1];
			if(opplst.size() > 0){
				for(Opportunity opp:opplst){
					if(opp.Link_to_Value_Output__c!=null)
					{
						acc.Link_to_Value_Output__c = opplst[0].Link_to_Value_Output__c;
						break;
					}else{
						//acc.Link_to_Value_Output__c = null;
					}
				}
			}
			
            
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();
            if(oldrampedusers != acc.Number_of_Ramped_Users__c 
                || oldhs != acc.Head_of_Security__c 
                || oldhn != acc.Head_of_Networking__c 
                || oldit != acc.Head_of_IT__c 
                || oldserviceowner != acc.Service_Owner_Present__c 
                || oldlastsci != acc.Last_SCI_Date__c 
                || oldlinktovalueoutput != acc.Link_to_Value_Output__c){
                    update acc;
                    successlst.add(acc.Id);
                }
        }catch(Exception e){
            errorlst.add('Exception on acc:' + acc.Id + '. Exception is ' + e);
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
            mail1.setSubject('Account CSM fields Rollup Failure result');
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
            mail.setSubject('Account CSM fields Rollup Success result ');
            mail.setPlainTextBody('Account CSM fields Rollup has been executed Successfully and processed '+ successlst.size() + ' records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(messageList);
        }
    }
    
}