@isTest
public class getOppChurnReasonController_Test {
    @TestSetup static void setuprecs(){
        TriggerUtility.prospectTypeUpdExecuted();
        Account acc = APTS_TestUtil.creatAccount();
        Id RecordTypeIdContact = [SELECT Id FROM RecorDtype WHERE DeveloperName = 'Renewal_Opportunity'].Id;
        Opportunity opp = new Opportunity(RecordTypeId=RecordTypeIdContact, Name = 'test opp', 
                                          AccountId = acc.Id, StageName = label.Stage_1_Alignment /*'Qualified'*/, CloseDate = Date.Today()
                                         );
        insert opp;
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =opp.Id);
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =opp.Id);
        insert churnLoss;
        //if(!prodList.isEmpty()){
        /**Apttus_Config2__PriceList__c pricelist = APTS_TestUtil.createpricelist();
        Id productid=APTS_TestUtil.createProduct();
        Id productid2=APTS_TestUtil.createProduct();
        Product2 prod = [SELECT Id,isBundle__c,IsActive FROM Product2 WHERE Id=: productid];
        prod.isBundle__c = true;
        prod.IsActive = true;
        prod.Zscaler_Product_Family__c = 'ZIA';
        update prod;
        List<PricebookEntry> lipri1=new List<PricebookEntry>();
        try{
        Id pricebookId = Test.getStandardPricebookId();
        opp.Pricebook2Id = pricebookId;
        opp.Price_List__c = pricelist.Id;
        update opp;system.debug('TEST: '+opp.RecordTypeId);
        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId,
                                                Product2Id=productid,UnitPrice=100.0));
        lipri1.add(new PricebookEntry(IsActive=TRUE,Pricebook2Id=pricebookId, 
                                                Product2Id=productid2,UnitPrice=100.0));
        insert lipri1;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        
        PricebookEntry entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=opp.Pricebook2Id,
                                                Product2Id=productid,UnitPrice=100.0);
        
        List<PricebookEntry> lipri=new List<PricebookEntry>();
        lipri.add(entry);
        
        try{
            insert lipri;
            OpportunityLineItem oppol=new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=entry.Id);
            
            List<OpportunityLineItem> oppLineItems=new List<OpportunityLineItem>();
            oppLineItems.add(oppol);
            
            insert oppLineItems;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }
        //}
        Significant_Customer_Interaction__c sig = new Significant_Customer_Interaction__c(Opportunity_Name__c=opp.Id);
        insert sig;
        Churn__c churn = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Churn', Opportunity__c =opp.Id);
        insert churn;
        Churn__c churnLoss = new Churn__c(SCINumber__c=sig.Id,Type__c = 'Loss', Opportunity__c =opp.Id);
        insert churnLoss;**/
    }
    
    static testmethod void testResonctrl(){
        Test.startTest();
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id from Opportunity];
        Churn__c churn = [Select Id,Type__c from Churn__c Where Type__c='Loss' Limit 1];
        ApexPages.currentPage().getParameters().put('oppId',opp[0].id);
        Apexpages.StandardController sc = new Apexpages.StandardController(opp[0]);
        getOppChurnReasonController ctrl = new getOppChurnReasonController(sc);
        list<SelectOption> piclList = getOppChurnReasonController.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        Test.stopTest();
    }
    
    static testmethod void testResonEditctrl(){
        Test.startTest();
        List<Account> acc = [Select Id from Account];
        List<Opportunity> opp = [Select Id,recordType.Name from Opportunity];
        String oppIdForMethod = opp[0].Id;
        
        Churn__c churn = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Loss' Limit 1];
        List<Churn__c> churnList = [Select Id,Type__c,SCINumber__c from Churn__c Where Type__c='Loss' LIMIT 5];
        Significant_Customer_Interaction__c sciObj = [SELECT Id FROM Significant_Customer_Interaction__c 
                                                      WHERE Opportunity_Name__c =: opp[0].id];
        
        ApexPages.currentPage().getParameters().put('id',opp[0].id);
        ApexPages.currentPage().getParameters().put('cId',churn.id);
        Apexpages.StandardController sc = new Apexpages.StandardController(opp[0]);
        getOppChurnReasonController ctrl = new getOppChurnReasonController(sc);
        list<SelectOption> piclList = getOppChurnReasonController.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        
        //if(opp[0].id != null && churn.id != null)
        system.debug('the id is' + opp[0].id);
        ctrl.init();
        getOppChurnReasonController.saveForm(oppIdForMethod,churn.id,'Not planning on local breakouts','Not moving apps to the cloud','Quality - Support','Quality - Lingering Issues','Quality - Support',
                                             'Quality - Lingering Issues',
                                             'No internal champion',
                                             'Low Executive Meetings',
                                             'M&A - company acquired/merged',
                                             'Zscaler Product EOL','Price','Lost Budget','Test','Akamai (ETP)','Bitglass','additionalNotes',churn.SCINumber__c,
                                              'ZIA Business Bundle','Private Access Business',null,null,null,true,true,true,true,
                                                                                                 'some text',true,false);
                                                                                                 
        getOppChurnReasonController.saveForm(oppIdForMethod,churn.id,'Not planning on local breakouts','Please Select','Quality - Support','Please Select','Quality - Support',
                                             'Please Select',
                                             'No internal champion',
                                             'Please Select',
                                             'M&A - company acquired/merged',
                                             'Please Select','Price','Please Select','Test','Akamai (ETP)','Please Select','additionalNotes','',
                                              'ZIA Business Bundle','Private Access Business',null,null,null,true,true,true,true,
                                                                                                 'some text',true,false);
        getOppChurnReasonController.getChurn(churn.Id);
        getOppChurnReasonController.churnObj = churn;
        getOppChurnReasonController.oppObj = opp[0];
        
        
        //getOppChurnReasonController.saveResponse churnRes1 = getOppChurnReasonController.saveForm(opp[0].id,churn.id,'Not planning on local breakouts','Please select','Quality - Support','Please select','Quality - Support','Please select','No internal champion','Please select','M&A - company acquired/merged','Please select','Price','Please select','Test','Please select','Akamai (ETP)','Please select','additionalNotes', null ,'11- Closed Lost', false);
        ////Opportunity.Util_ChurnReasonMethods instance = new Opportunity.Util_ChurnReasonMethods();
        //Util_ChurnReasonMethods ctrlUtil = new Util_ChurnReasonMethods(sc);
        //Util_ChurnReasonMethods.oppObj = opp[0];
        //Util_ChurnReasonMethods.gd = Schema.getGlobalDescribe().values();
        //Util_ChurnReasonMethods.isActivePRpresentOnOpp(opp[0].Id);
        //Util_ChurnReasonMethods.getSCIrecords(opp[0].Id);
        //Util_ChurnReasonMethods.getDowngradeRecords();
        //Util_ChurnReasonMethods.getSCIname(sciObj.Id);
        //Util_ChurnReasonMethods.getSCI(opp[0].Id);
        //Util_ChurnReasonMethods.getPicklistValues('Churn__c','Engagement_Primary_Reason__c');
        //Util_ChurnReasonMethods.getSCIRecordTypes();
        //Util_ChurnReasonMethods.getSearchSCIValues(opp[0].Id);
        //Util_ChurnReasonMethods.getProductRecords('Premium Support');
        //Util_ChurnReasonMethods.isZPApresent(opp[0].Id);
        //Util_ChurnReasonMethods.isZIApresent(opp[0].Id);
        Test.stopTest();
    }

}