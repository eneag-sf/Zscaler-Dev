@istest
public class ValueSummary_EmailInvocation_Test{
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
          
        Apttus_Config2__ConfigSystemProperties__c config=new Apttus_Config2__ConfigSystemProperties__c(Name='System Properties',Apttus_Config2__InstanceUrl__c=URL.getSalesforceBaseUrl().toExternalForm() + '/');
        insert config;
        Account account = new Account(Name = 'Zscaler');
        insert account;
        ValueSummary_EmailInvocation.checkdomain(account.Id);
        ValueSummary_EmailInvocation_Lightning.checkdomain(account.Id);
        
    }
}