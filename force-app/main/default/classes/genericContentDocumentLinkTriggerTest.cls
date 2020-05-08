@isTest
public class genericContentDocumentLinkTriggerTest {
    public static testMethod void genericContentDocumentLinkTest(){
        insert TestDatafactory_Zscaler.gettriggerswitchrecords(true);
        Case cs = new Case();
        cs.Status = 'New';
        cs.Subject = 'test sub';
        insert cs;
        Contact ct =new Contact();
        ct.LastName = 'test';
        ct.Email = 'test@test.com';
        insert ct;
        EmailMessage outGoingMail= new EmailMessage();
        outGoingMail.fromaddress='test@test.com';
        outGoingMail.toAddress = ct.Email;
        outGoingMail.subject = 'Opt Out Test Message';
        outGoingMail.TextBody= 'This is the message body BR-Interno.';
        outGoingMail.ParentId = cs.Id;
        outGoingMail.Incoming = true;
        insert outGoingMail;
        ContentVersion ContentVer = new ContentVersion();
        ContentVer.Title = 'My Doc';
        ContentVer.ContentUrl= 'test.com';
        Insert ContentVer;
        ContentDocumentLink ContentDL = new ContentDocumentLink();
        ContentDL.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ContentVer.Id].ContentDocumentId;
        ContentDL.LinkedEntityId=outGoingMail.id;
        ContentDL.ShareType='V';
        Insert ContentDL;
        ContentDL = [SELECT Id,ShareType FROM ContentDocumentLink WHERE Id =:ContentDL.Id];
    }
}