@isTest
public class ValueSummaryDocController_Test{
    public static Apttus_Config2__PriceList__c  pricelist;
  @isTest static void testgenerateValsum() {
        //Admin Entries
        Apttus__APTS_Admin__c adminPriceBook = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceBook', Apttus__Value__c = 'Apttus Default Price Book');
        Apttus__APTS_Admin__c adminPriceList = new Apttus__APTS_Admin__c(Name = 'APTS_DefaultPriceList', Apttus__Value__c = 'ZScaler Price List');
        insert adminPriceBook;
        insert adminPriceList;
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name = 'Value Summary';
        template.Apttus__IsActive__c = true;
        insert template;
        Pricelist=new Apttus_Config2__PriceList__c(Name = 'ZScaler Price List');
        insert Pricelist;
        Id priceListId = pricelist.Id;
          
        Apttus_Config2__ConfigSystemProperties__c config=new Apttus_Config2__ConfigSystemProperties__c(Name='System Properties',Apttus_Config2__InstanceUrl__c=URL.getSalesforceBaseUrl().toExternalForm() + '/');
        insert config;
        Account account = new Account(Name = 'Zscaler');
        insert account;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', CloseDate = Date.today() + 30, StageName = Label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/, Type = 'New Business');
        insert opportunity;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_QPConfig__BillToAccountId__c=account.Id, Apttus_Proposal__Proposal_Name__c = 'Test Proposal', Apttus_Proposal__Account__c = account.Id, Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_Proposal__ExpectedStartDate__c = Date.today(), Apttus_Proposal__ExpectedEndDate__c = Date.today() + 365, Apttus_QPConfig__PriceListId__c = priceListId);
        insert proposal;

        apexpages.currentpage().getparameters().put('id', account.Id);
        ValueSummaryDocController ctrl = new ValueSummaryDocController();
        ctrl.initquote();
        ValueSummaryDocController.generateDoc(proposal.Id + '---'+ctrl.accountId+'---'+'pdf' + '---'+UserInfo.getUserId());
        ctrl.redirectToURL();
        try{
            ctrl.attachId = proposal.Id;
            ctrl.redirectToURL();
        }catch(Exception ex){
        
        }
    }
        
}