@isTest
private class PlannerEmailServiceTest {
    
    @testSetup static void setup() {
        inspire1__Project__c Project = new inspire1__Project__c();
        Project.Name = 'Test';
        insert Project;
    }
    
	private static testMethod void test() {
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope(); 
        
        inspire1__Project__c ProjectRec = [select Id,Name from inspire1__Project__c where Name = 'Test' ];
        
        email.subject = ProjectRec.Name+'[Ref:'+ProjectRec.Id+']';
        //email.plainTextBody = 'Test Body';
        email.HtmlBody = '<div class="gmail_quote"> Test Body';
        
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
		binaryAttachment.Filename = 'test.pdf';
        binaryAttachment.body = blob.valueOf('my attachment text');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
        
        PlannerEmailService PlannerService = new PlannerEmailService ();
        PlannerService.handleInboundEmail(email, env);
	}

}