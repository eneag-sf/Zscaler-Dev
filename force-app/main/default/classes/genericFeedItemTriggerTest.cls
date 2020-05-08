@isTest
public class genericFeedItemTriggerTest {
    public static testMethod void genericFeedItemTest(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Contact ct = new Contact();
        ct.LastName ='test';
        ct.Email ='test@test.com';
        insert ct;
        feeditem FI1=new feeditem();
        FI1.parentid=ct.id;
        FI1.Body = 'test chatter';
        insert FI1;
    }
}