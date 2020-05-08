@istest
public class ContactThatMattersControllerExt_Test{
    static testmethod void test1(){
        Account acc = new Account(name = 'test');
        insert acc;
        List<Contact> conlst = new List<Contact>();
        contact c1 = new contact(accountid = acc.Id,lastname = 'abc', email='abc@abc.com',Contacts_that_matter__c = true, Active__c = false, Champion__c = true);
        conlst.add(c1);
        contact c2 = new contact(accountid = acc.Id,lastname = 'abc', email='abc@abc.com',Contacts_that_matter__c = true,Level_From_CIO__c = '1', Active__c = false, Influencer__c = true);
        conlst.add(c2);
        insert conlst;
        
        ContactThatMattersControllerExt ctrl = new ContactThatMattersControllerExt(new ApexPages.StandardController(acc));
    }
}