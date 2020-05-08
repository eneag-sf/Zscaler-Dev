/*****************************************************************************************
Name: UpdateAssetZPAdetails_Account
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           01-June-2018      Initial Development
******************************************************************************************/

global class UpdateAssetZPAdetails_Account implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    String qry = '';
    
    global UpdateAssetZPAdetails_Account(String q)
    {
        qry = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context){
        String query = qry;
        return Database.getQueryLocator(query);
    }

    global void execute (Database.BatchableContext context, List<Account> scope){
        try{
            Set<String> setSKUCodes = new Set<String> {
                                        APTS_CONSTANTS.PROD_SKU_ZPA_PRO,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_ENT,
                                        APTS_CONSTANTS.PROD_SKU_ZPA_BUS
                                    };

            Set<Id> setProductIdsZPA = new Set<Id>();
            
            for (Product2 product : [select Id, Name,ProductCode from Product2 where ProductCode IN :setSKUCodes]) {
                setProductIdsZPA.add(product.Id);
            }
            APTS_AssetLineItemTriggerHandler ctrl = new APTS_AssetLineItemTriggerHandler();
            ctrl.updateAccountPlatformSeatsZPA(new Set<Id>{scope[0].Id},setProductIdsZPA);
        }catch(Exception ex){
            errorlst.add( scope[0].Id + '' + ex);
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
                mail1.setSubject('ZPA new fields update failure');
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
                mail.setSubject('ZPA new fields update success');
                mail.setPlainTextBody('Zscaler forecast batch has been executed Successfully');
                messageList.add(mail);
            }
            Messaging.sendEmail(messageList);
    }
}