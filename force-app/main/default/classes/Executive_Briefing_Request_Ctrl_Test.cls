@isTest
public class Executive_Briefing_Request_Ctrl_Test{
    static testmethod void test1(){
        
        //Insert Products
        List<Product2> listProduct = new list<Product2>();
        listProduct.add(createProduct('Zscaler Enterprise Guest Wi-Fi Security', 'ZSC-ENT-GWIFI-3YR-A', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product2', 'ZCES-SUP-PREM', 'Products', 'Standalone'));
        listProduct.add(createProduct('Product3', 'CODE03', 'Products', 'Standalone'));
        insert listProduct;
        
        Account account = new Account(Name = 'Test Account');
        //account.Needs_to_be_Migrated__c = true;
        insert account;
        
        Order o = new Order(name = 'Test Order 1', AccountId = account.Id, Order_Date__c = date.today(), NS_Sales_Order_Number__c = 'S24867', EffectiveDate = date.today(), EndDate=date.today().adddays(200), Status = 'Draft', Location__c = 'Americas');
        insert o;
        
        
         //Create Contractdetails
        List<Contract_Detail__c> contractDetailList = new List<Contract_Detail__c>();
        Contract_Detail__c contractDetail1 = new Contract_Detail__c();
        contractDetail1.Name = 'Migrate as is';
        contractDetail1.Account_Name__c = account.Id;
        contractDetail1.Product_Name__c = listProduct[0].Id;
        contractDetail1.Start_Date__c = Date.Today();
        contractDetail1.End_Date__c = Date.Today() + 365;
        contractDetail1.Quantity__c = 100;
        contractDetail1.Amount_USD__c = 1000;
        contractDetail1.Contract_No__c = '100';
        contractDetail1.MRR_USD__c = 100;
        contractDetail1.List_Price__c = 100;
        contractDetail1.Discount__c = 10;
        contractDetail1.Needs_to_Be_Migrated_to_Asset_Line__c = true;
        contractDetail1.Sales_Order__c = o.Id;
        contractDetail1.Product_SKU__c = 'ZSC-ENT-GWIFI-3YR-A';
        contractDetail1.Contract_Detail_Status__c = 'Pending Renewal';
        contractDetailList.add(contractDetail1);        
        insert contractDetailList;
        
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test1';
        con1.LastName = 'Test1';
        con1.AccountId = account.Id;

        Contact con2 = new Contact();
        con2.FirstName = 'Test2';
        con2.LastName = 'Test2';
        con2.Renewal_Notification_Recipient__c = true;
        con2.AccountId = account.Id;
        
        insert new List<Contact> { con1, con2 };
        Id meRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
        
        opportunity opp = new opportunity(RecordtypeId = meRecordTypeId, Name = 'Test opportunity', AccountId = account.Id, StageName = 'Test Stage',
                                          SE_name__c = UserInfo.getUserId(), NextStep = 'Test 1',CloseDate = system.Today()+30, Primary_Quote_Exception__c = true, 
                                          Validation_Stage__c = '6 - Technical Win', Validation_Plan__c = 'Test', AD_Forecast_Category__c='Pipeline',
                                          AD_Forecast_Category_Lock__c=true, Architecture_Next_Steps__c   = 'fljskjdfjkdsjkfjdsf',
                                          Next_Steps__c  = 'fdsjsdk', Pricebook2ID=Test.getStandardPricebookId(), 
                                          contract_end_date_new__c = date.today().adddays(65)
                                         );
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole(
            ContactId = con1.Id,
            OpportunityId = opp.Id,
            Role = 'Champion (Technical)'
        );
        OpportunityContactRole ocr1 = new OpportunityContactRole(
            ContactId = con2.Id,
            OpportunityId = opp.Id,
            Role = 'Economic Buyer'
        );
        insert new List<OpportunityContactRole> { ocr, ocr1 };
        
        
        Id productid=APTS_TestUtil.createProduct();
        Id productid2=APTS_TestUtil.createProduct();
        PricebookEntry entry=new PricebookEntry(IsActive=TRUE,Pricebook2Id=opp.Pricebook2Id,
                                                Product2Id=productid,UnitPrice=100.0);
        PricebookEntry entry2=new PricebookEntry(IsActive=TRUE,Pricebook2Id=opp.Pricebook2Id, 
                                                 Product2Id=productid2,UnitPrice=100.0);
        List<PricebookEntry> lipri=new List<PricebookEntry>();
        lipri.add(entry);
        lipri.add(entry2);
        
        try{
            insert lipri;
            OpportunityLineItem oppol=new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=entry.Id);
            OpportunityLineItem oppol2=new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=entry2.Id);
            List<OpportunityLineItem> lioppl = new List<OpportunityLineItem>();
            lioppl.add(oppol);
            lioppl.add(oppol2);
            insert lioppl;
        }
        catch(Exception ex){
            system.debug('Exception Cathed for PriceBook'+ex);
        }

        
        
        
        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(date_of_meeting__c = date.today());
        insert eb;
        
        Executive_Briefing_Internal_Attendees__c ebi = new Executive_Briefing_Internal_Attendees__c (Executive_Briefing_Request__c = eb.id);
        insert ebi;
        
        Executive_Briefing_External_Attendees__c ebe = new Executive_Briefing_External_Attendees__c (Executive_Briefing_Request__c = eb.id);
        insert ebe;
        
        List<Executive_Briefing_Request_Controller.InternalAttendee> usrlst = new List<Executive_Briefing_Request_Controller.InternalAttendee>();
        Executive_Briefing_Request_Controller.InternalAttendee rec1 = new Executive_Briefing_Request_Controller.InternalAttendee();
        rec1.id=userinfo.getUserId();
        rec1.name='User';
        usrlst.add(rec1);
        List<Executive_Briefing_Request_Controller.ExternalAttendee> conlst = new List<Executive_Briefing_Request_Controller.ExternalAttendee>();
        Executive_Briefing_Request_Controller.ExternalAttendee rec2 = new Executive_Briefing_Request_Controller.ExternalAttendee();
        rec2.id=con1.Id;
        rec2.name='User';
        conlst.add(rec2);
        
        Executive_Briefing_Request_Controller.getData(opp.Id, eb.Id, account.Id);
        Executive_Briefing_Request_Controller.saveintattendees(json.serialize(usrlst), eb.Id);
        Executive_Briefing_Request_Controller.saveextattendees(json.serialize(conlst), eb.Id);
    }
    
    public static Product2 createProduct(String PRoductName, String pcode, String pfamily, String sConfigType) {
        Product2 productSO = new Product2();
        productSO.Name = ProductName;
        productSO.Family = pfamily;
        productSO.ProductCode = pcode;
        productSO.IsActive = true;
        productSO.Apttus_Config2__ConfigurationType__c = sConfigType;
        productSO.Apttus_Config2__HasAttributes__c = false;
        productSO.Apttus_Config2__HasOptions__c = false;
        return productSO;
    }
}