@isTest
private class AmberRoadAsyncEmailHandlerTest {

    @isTest static void testEmailHandler() {
        AmberRoadAsyncEmailHandler amberRoadEmailHandler = new AmberRoadAsyncEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result;

        Account testAccount = new Account(Name = 'TestAmberroadAccount', Amber_Road_Status__c = null);
        insert testAccount;

        email.subject = 'Email Alert';
        email.plainTextBody = '<?xml version="1.0" encoding="UTF-8"?>'
                            + '<PartnerRecord version="2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                            + 'xsi:noNamespaceSchemaLocation="PartnerXml.xsd"><PartnerId>' + testAccount.Id + '</PartnerId>'
                            + '<OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode><Name>Test Data</Name>'
                            + '<Address1></Address1><City></City><State></State><PostalCode></PostalCode><Country></Country>'
                            + '<Fax></Fax><Phone>(234) 567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>Y</SkipNewDpl>'
                            + '<ForceRescreen>N</ForceRescreen><Status>No Match</Status><IntegrationStatus><StatusCode>1000</StatusCode>'
                            + '<StatusDescription>Success</StatusDescription></IntegrationStatus></PartnerRecord>';

        envelope.fromAddress = 'admin@amberroad.com';

        Test.startTest();
        try {
            result = amberRoadEmailHandler.handleInboundEmail(email, envelope);
        } catch (Exception ex) {

        }
        Test.stopTest();

        System.assertEquals(true, result.success);
    }

    @isTest static void testEmailHandlerExceptionCase() {
        AmberRoadAsyncEmailHandler amberRoadEmailHandler = new AmberRoadAsyncEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result;

        Account testAccount = new Account(Name = 'TestAmberroadAccount', Amber_Road_Status__c = null);
        insert testAccount;

        email.subject = 'Email Alert';
        email.plainTextBody = '<?xml version="1.0" encoding="UTF-8"?>'
                            + '<PartnerRecord version="2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                            + 'xsi:noNamespaceSchemaLocation="PartnerXml.xsd"><PartnerId>' + 'invalid' + '</PartnerId>'
                            + '<OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode><Name>Test Data</Name>'
                            + '<Address1></Address1><City></City><State></State><PostalCode></PostalCode><Country></Country>'
                            + '<Fax></Fax><Phone>(234) 567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>Y</SkipNewDpl>'
                            + '<ForceRescreen>N</ForceRescreen><Status>No Match</Status><IntegrationStatus><StatusCode>1000</StatusCode>'
                            + '<StatusDescription>Success</StatusDescription></IntegrationStatus></PartnerRecord>';

        envelope.fromAddress = 'admin@amberroad.com';

        Test.startTest();
        try {
            result = amberRoadEmailHandler.handleInboundEmail(email, envelope);
        } catch (Exception ex) {
            System.debug('Verified');
        }
        Test.stopTest();
    }

    @isTest static void testEmailHandlerUnsuccessfulCase() {
        AmberRoadAsyncEmailHandler amberRoadEmailHandler = new AmberRoadAsyncEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result;

        Account testAccount = new Account(Name = 'TestAmberroadAccount', Amber_Road_Status__c = null);
        insert testAccount;

        email.subject = 'Email Alert';
        email.plainTextBody = '';

        envelope.fromAddress = 'admin@amberroad.com';

        Test.startTest();
        try {
            result = amberRoadEmailHandler.handleInboundEmail(email, envelope);
        } catch (Exception ex) {
            System.debug('Verified');
        }
        Test.stopTest();

        System.assertEquals(false, result.success);
    }

    @isTest static void testEmailHandlerIntegrationFailCase() {
        AmberRoadAsyncEmailHandler amberRoadEmailHandler = new AmberRoadAsyncEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmailResult result;

        Account testAccount = new Account(Name = 'TestAmberroadAccount', Amber_Road_Status__c = null);
        insert testAccount;

        email.subject = 'Email Alert';
        email.plainTextBody = '<?xml version="1.0" encoding="UTF-8"?>'
                            + '<PartnerRecord version="2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
                            + 'xsi:noNamespaceSchemaLocation="PartnerXml.xsd"><PartnerId>' + testAccount.Id + '</PartnerId>'
                            + '<OrgCode>ZSCALER_SF</OrgCode><CompanyCode>ZSCALER</CompanyCode><Name>Test Data</Name>'
                            + '<Address1></Address1><City></City><State></State><PostalCode></PostalCode><Country></Country>'
                            + '<Fax></Fax><Phone>(234) 567-8901</Phone><DoNotScreen>N</DoNotScreen><SkipNewDpl>Y</SkipNewDpl>'
                            + '<ForceRescreen>N</ForceRescreen><Status>No Match</Status><IntegrationStatus><StatusCode>2000</StatusCode>'
                            + '<StatusDescription>Failure</StatusDescription></IntegrationStatus></PartnerRecord>';

        envelope.fromAddress = 'admin@amberroad.com';

        Test.startTest();
        try {
            result = amberRoadEmailHandler.handleInboundEmail(email, envelope);
        } catch (Exception ex) {
            System.debug('Verified');
        }
        Test.stopTest();

        System.assertEquals(false, result.success);
    }
}