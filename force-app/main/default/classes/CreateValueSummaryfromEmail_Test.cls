@isTest
private class CreateValueSummaryfromEmail_Test {

    static testMethod void test1() {
       // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
      // setup the data for the email
      email.subject = 'Value Summary Generation';
      email.fromname = 'FirstName LastName';
      email.plainTextBody = 'Create Value Summary--abc--def--pdf--'+UserInfo.getUserId();
    
      // call the email service class and test it with the data in the testMethod
      CreateValueSummaryfromEmail emailProcess = new CreateValueSummaryfromEmail ();
      emailProcess.handleInboundEmail(email, env);
    
    }
    
    static testMethod void test2() {
       // create a new email and envelope object
      Messaging.InboundEmail email = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
      // setup the data for the email
      email.subject = 'Summary Generation';
      email.fromname = 'FirstName LastName';
      email.plainTextBody = 'Create Value Summary--abc--def--pdf--'+UserInfo.getUserId();
    
      // call the email service class and test it with the data in the testMethod
      CreateValueSummaryfromEmail emailProcess = new CreateValueSummaryfromEmail ();
      emailProcess.handleInboundEmail(email, env);
    
    }
}