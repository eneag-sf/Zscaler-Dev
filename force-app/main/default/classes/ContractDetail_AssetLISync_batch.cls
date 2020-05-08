/*****************************************************************************************
Name: ContractDetail_AssetLISync_batch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to map contract detail to Asset line item

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Abhishek V           22-December-2018     Initial Development
******************************************************************************************/

public class ContractDetail_AssetLISync_batch implements Database.Batchable<sObject>, Database.Stateful{
    public List<String> errorlst = new List<String>();
    public List<String> successlst = new List<String>();
    DateTime startDate;
    DateTime endDate;
    
    
    public ContractDetail_AssetLISync_batch(String stdt, String eddt){
        startDate = Datetime.valueOf(stdt);
        endDate = Datetime.valueOf(eddt);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = 'Select Id from Account where Id in (Select Account_Name__c from Contract_Detail__c where LastmodifiedDate >= :startDate and LastmodifiedDate <= :endDate  AND Contract_Detail_Status__c IN (\'Active\',\'Pending Renewal\',\'Pending Activation\'))';
        return Database.getQueryLocator(query);
        
    }

    public void execute (Database.BatchableContext context, List<Account> acclst){
        Boolean error = false;
        Account acc = acclst[0];
        Set<Id> aliset = new Set<Id>();
        Map<String, List<Contract_Detail__c>> mapSOnumtocd = new Map<String, List<Contract_Detail__c>>();
        Map<String, Map<String, String>> mapSOnumtoassetrampCD = new Map<String, Map<String, String>>();
        Map<Id, String> mapQuoteIdtoSO = new Map<Id, String>();
        Map<Id, List<Contract_Detail__c>> mapSOtoquote = new Map<Id, List<Contract_Detail__c>>();
        Map<String, String> mapSonamtoId = new Map<String, String>();
        Map<Id, Apttus_Config2__AssetLineItem__c> alilst = new Map<Id, Apttus_Config2__AssetLineItem__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c > plilst = new List<Apttus_Proposal__Proposal_Line_Item__c  >();
        List<Apttus_Config2__LineItem__c> lilst = new List<Apttus_Config2__LineItem__c>();
        Set<Id> SoIdset = new Set<Id>();
        for(Contract_Detail__c cd: [Select Id, Name, Account_Name__c, Sales_Order_Name__c, Product_SKU__c, Start_Date__c, End_Date__c, Quantity__c, Sales_Order__c, Contract_No__c, Amount_USD__c from Contract_Detail__c where Contract_Detail_Status__c IN ('Active','Pending Renewal','Pending Activation') and Account_Name__c = :acc.Id]){
            if(!mapSOnumtocd.containskey(cd.Sales_Order_Name__c)){
                mapSOnumtocd.put(cd.Sales_Order_Name__c, new List<Contract_Detail__c>{cd});
            }else{
                List<Contract_Detail__c> templst = mapSOnumtocd.get(cd.Sales_Order_Name__c);
                templst.add(cd);
                mapSOnumtocd.put(cd.Sales_Order_Name__c, templst);
            }
            SoIdset.add(cd.Sales_Order__c);
        }
        
        system.debug('++++'+mapSOnumtocd);
        
        for(Apttus_Proposal__Proposal__c quote: [Select Id, Sales_Order__c from Apttus_Proposal__Proposal__c where Sales_Order__c in :mapSOnumtocd.keySet()]){
            mapQuoteIdtoSO.put(quote.Id, quote.Sales_Order__c);
        }
        system.debug('++++'+mapQuoteIdtoSO);
        
        
        for(Apttus_Config2__AssetLineItem__c ali: [Select Id, Apttus_QPConfig__ProposalId__c, Product_Code__c, Apttus_Config2__StartDate__c, Apttus_Config2__EndDate__c, Apttus_Config2__Quantity__c, Apttus_Config2__PriceGroup__c from Apttus_Config2__AssetLineItem__c where Apttus_QPConfig__ProposalId__c in :mapQuoteIdtoSO.keyset() and Apttus_Config2__AccountId__c = :acc.Id]){
            String SOName = mapQuoteIdtoSO.get(ali.Apttus_QPConfig__ProposalId__c);
            for(Contract_Detail__c cd: mapSOnumtocd.get(SOName)){
                if(cd.Product_SKU__c == ali.Product_Code__c 
                && cd.Start_Date__c == ali.Apttus_Config2__StartDate__c 
                && cd.End_Date__c == ali.Apttus_Config2__EndDate__c 
                && cd.Quantity__c == ali.Apttus_Config2__Quantity__c 
                && cd.Amount_USD__c > 0 
                && aliset.add(ali.Id)){
                    ali.APTS_Contract_Detail_Name__c = cd.Id;
                    ali.APTS_Contract_No__c = cd.Contract_No__c;
                    ali.APTS_Sales_Order__c = cd.Sales_Order__c;
                    alilst.put(ali.Id, ali);
                    if(ali.Apttus_Config2__PriceGroup__c == 'Price Ramp'){
                        if(!mapSOnumtoassetrampCD.containskey(ali.APTS_Sales_Order__c)){
                            mapSOnumtoassetrampCD.put(ali.APTS_Sales_Order__c, new Map<String,String>{ali.Product_Code__c => cd.Name});
                        }else{
                            Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(ali.APTS_Sales_Order__c);
                            if(!mapprodtocd.containskey(ali.Product_Code__c)){
                                mapprodtocd.put(ali.Product_Code__c, cd.Name);
                            }else{
                                String cdname = mapprodtocd.get(ali.Product_Code__c);
                                cdname += cd.Name;
                                mapprodtocd.put(ali.Product_Code__c, cdname);
                            }
                            mapSOnumtoassetrampCD.put(ali.APTS_Sales_Order__c, mapprodtocd);
                        }
                    }
                }
            }
        }
        
        for(Apttus_Config2__AssetLineItem__c ali: alilst.values()){
            String addcd = '';
            if(mapSOnumtoassetrampCD != null && mapSOnumtoassetrampCD.containskey(ali.APTS_Sales_Order__c)){
                Map<String, String> mapprodtocd = mapSOnumtoassetrampCD.get(ali.APTS_Sales_Order__c);
                if(mapprodtocd != null && mapprodtocd.containskey(ali.Product_Code__c)){
                    addcd = mapprodtocd.get(ali.Product_Code__c);
                }
            }
            ali.Additional_Contract_Details__c = addcd;
        }
        system.debug('++++'+alilst);
        
        
        for(Apttus_Proposal__Proposal_Line_Item__c pli: [Select Id, Apttus_QPConfig__AssetLineItemId__c, APTS_Contract_Detail_Name__c, APTS_Contract_No__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_QPConfig__AssetLineItemId__c in :alilst.keyset()]){
            pli.APTS_Contract_Detail_Name__c = alilst.get(pli.Apttus_QPConfig__AssetLineItemId__c).APTS_Contract_Detail_Name__c;
            pli.APTS_Contract_No__c = alilst.get(pli.Apttus_QPConfig__AssetLineItemId__c).APTS_Contract_No__c;
            pli.Additional_Contract_Details__c = alilst.get(pli.Apttus_QPConfig__AssetLineItemId__c).Additional_Contract_Details__c;
            plilst.add(pli);
        }
        
        for(Apttus_Config2__LineItem__c li: [Select Id, Apttus_Config2__AssetLineItemId__c, APTS_Contract_Detail_Name__c, APTS_Contract_No__c from Apttus_Config2__LineItem__c where Apttus_Config2__AssetLineItemId__c in :alilst.keyset()]){
            li.APTS_Contract_Detail_Name__c = alilst.get(li.Apttus_Config2__AssetLineItemId__c).APTS_Contract_Detail_Name__c;
            li.APTS_Contract_No__c = alilst.get(li.Apttus_Config2__AssetLineItemId__c).APTS_Contract_No__c;
            li.Additional_Contract_Details__c = alilst.get(li.Apttus_Config2__AssetLineItemId__c).Additional_Contract_Details__c;
            lilst.add(li);
        }
        TriggerUtility.generateYearWiseSplitExecuted();
        
        List<Database.SaveResult> srList1 = database.update(alilst.values(), false);
        for (Database.SaveResult sr : srList1) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
            }
            else { error = true;
            }
        }
        
        List<Database.SaveResult> srList2 = database.update(plilst, false);
        for (Database.SaveResult sr : srList2) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
            }
            else { error = true;
            }
        }
        
        List<Database.SaveResult> srList3 = database.update(lilst, false);
        for (Database.SaveResult sr : srList3) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //successlst.add(sr.getId());
            }
            else { error = true;
            }
        }
        if(error){ errorlst.add(acc.Id);
        }else{
            successlst.add(acc.Id);
        }
    }
    
    public void finish(Database.BatchableContext context){
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ERROR});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{ mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Contract Detail Asset Line Item Sync Failure result');
            String msgbody = 'Below are the Ids of ' + errorlst.size() + ' account records that have failed: \n';
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
            }else{ mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setSubject('Contract Detail Asset Line Item Sync Update Success result ');
            mail.setPlainTextBody('Contract Detail Asset Line Item Sync Update has been executed Successfully and processed '+ successlst.size() + ' account records.');
            messageList.add(mail);
        }
        if(!Test.isRunningTest()){ Messaging.sendEmail(messageList);
        }
    }
    
}