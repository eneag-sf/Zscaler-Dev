@isTest
public class ApprovalStatusUpdateTriggerHandlerTest {
    public static Account acc;
    public static Apttus_Config2__PriceList__c  pricelist;
    public static Opportunity opp;
    public static Apttus_Proposal__Proposal__c  prop;
    public static  Apttus_Proposal__Proposal__c primaryprop;
    public static string newProposalId;
    public static string cartId;
    public static list<Apttus_Config2__AssetLineItem__c> assetList;
    public static string prdId;
    public static string PricebookID;
    public static Apttus__APTS_Template__c template;

    static
     {
         assetList = new list<Apttus_Config2__AssetLineItem__c>();

         //Admin Entries
         Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
         Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
         insert adminPriceBook;
         insert adminPriceList;

         Apttus__ComplySystemProperties__c customSetting1  = new Apttus__ComplySystemProperties__c(Name = 'System Properties');
         customSetting1.Apttus__MergeWebserviceEndpoint__c = 'https://mergews.apttus.net/cgi-bin/MergeServer/Bin/MMCGI.exe';
         insert customSetting1;

         Apttus_Config2__ConfigSystemProperties__c customSetting2 = new Apttus_Config2__ConfigSystemProperties__c(Name = 'System Properties');
         customSetting2.Apttus_Config2__InstanceUrl__c = System.URL.getSalesforceBaseURL().toExternalForm();
         insert customSetting2;

         Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
         insert Pricelist;

         /*template=new Apttus__APTS_Template__c(Name = 'Zscaler Proposal Template');
         insert template;

         Blob b = Blob.valueOf('Test Data');

         Attachment attachment = new Attachment();
         attachment.ParentId = template.Id;
         attachment.Name = 'Test Attachment for Parent.docx';
         attachment.Body = b;

         insert(attachment);
         */
         acc = APTS_TestUtil.creatAccount ();
         //pricelist = APTS_TestUtil.createpricelist ();
         PricebookID=Test.getStandardPricebookId();
         //PricebookID=[Select Id from PriceBook2 where IsStandard = FALSE LIMIT 1].Id;
         opp = APTS_TestUtil.createOpportunity (acc.Id,pricelist.Id);
         opp.Pricebook2Id=PricebookID;
         update opp;


         Opportunity opp1 = [select Id,Pricebook2Id from  Opportunity where id = :opp.ID];
         PricebookID = opp1.Pricebook2Id;
    }

    @isTest static void testApprovalStatusUpdate() {
        Product2 ZSCProd= new Product2(Name='ZSCProd1',ProductCode='ZIA-ELA-BUNDLE');
        insert ZSCProd;
        Id productId = ZSCProd.Id;
        Id priceListId = pricelist.Id;
        Apttus_Config2__PriceListItem__c PriceListItem1=new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId,Apttus_Config2__ProductId__c = productId,Apttus_Config2__Active__c = true);
        insert PriceListItem1;
        Id priceListItemId = PriceListItem1.Id;

        Account account = new Account(Name = 'Zscaler');
        insert account;

        Id accountId = account.Id;

        Test.startTest();
        Opportunity opportunity = new Opportunity(Pricebook2Id = PricebookID, Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment/*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=accountId, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        String proposalId = proposal.Id;

        //Create Cart
        Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
        request.QuoteId = proposal.Id;
        Apttus_CPQApi.CPQ.CreateCartResponseDO result = Apttus_CPQApi.CPQWebService.createCart(request);
        String cartId2 = result.CartId;
        List<Apttus_Config2__LineItem__c> lineitemlist = new List<Apttus_Config2__LineItem__c> ();
        lineitemlist = [select id, APTS_MRR__c,Apttus_Config2__NetPrice__c,Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c from Apttus_Config2__LineItem__c where Apttus_Config2__ConfigurationId__c=:cartId];

        //Add Product
        Apttus_CPQApi.CPQ.AddMultiProductRequestDO requests = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
        requests.CartId = cartId2;
        requests.SelectedProducts = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
        Apttus_CPQApi.CPQ.SelectedProductDO prodDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
        prodDO.ProductId = productId;
        requests.SelectedProducts.add(prodDO);

        Apttus_CPQApi.CPQ.AddMultiProductResponseDO response = Apttus_CPQApi.CPQWebService.addMultiProducts(requests);

        // Boolean approvalResponse = Apttus_Approval.ApprovalsWebService.submitForApprovals('Apttus_Proposal__Proposal__c', proposalId);
        // Apttus_Approval__Approval_Request__c req = [SELECT Id FROM Apttus_Approval__Approval_Request__c WHERE Apttus_QPApprov__ProposalId__c = :proposalId AND Apttus_Approval__Step_Name__c = 'ZIA Enterprise License Agreement Approval' LIMIT 1];
        //
        // Apttus_Approval.ApprovalsWebService.approveRequest(req.Id, 'Testing');
        Apttus_Approval__Approval_Request__c req = new Apttus_Approval__Approval_Request__c(
                                                    Apttus_Approval__Assigned_To_Id__c = UserInfo.getUserId(),
                                                    Apttus_Approval__Step_Name__c = 'ZIA Enterprise License Agreement Approval',
                                                    Apttus_Approval__StepLabel__c = 'ZIA Enterprise License Agreement Approval',
                                                    Apttus_Approval__Object_Type__c = 'Apttus_Proposal__Proposal__c',
                                                    Apttus_Approval__Object_Name__c = proposal.Name,
                                                    Apttus_QPApprov__ProposalId__c = proposalId,
                                                    Apttus_Approval__Initial_Submitter__c = UserInfo.getUserId(),
                                                    Apttus_Approval__Send_Email__c = false,
                                                    Apttus_Approval__Date__c = Datetime.now(),
                                                    APTS_Account_Name__c = 'Zscaler',
                                                    Apttus_Approval__ApprovalPolicy__c = 'Quorum',
                                                    Apttus_Approval__ApprovalCount__c = 1,
                                                    Apttus_Approval__CriteriaFieldNames__c = 'Has_ELA_SKU__c',
                                                    Apttus_Approval__AutoReapprove__c = true
                                                    );
        insert req;

        req.Apttus_Approval__Approval_Status__c = 'Approved';
        update req;

        Test.stopTest();
    }

}