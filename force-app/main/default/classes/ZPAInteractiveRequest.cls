public class ZPAInteractiveRequest implements Queueable {
 String objectName;
 List <String> recordIds;
 public ZPAInteractiveRequest(String objectName, List <String> recordIds) {
  this.objectName = objectName;
  this.recordIds = recordIds;
 }
 public void execute(QueueableContext context) {
  List <Provisioning_Request__c> prList = new List <Provisioning_Request__c> ();
  if (objectName != null && recordIds != null) {
   Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
   if (objectName == 'Lead') {
    List <Lead> leds = [Select Id, name, Account_Manager__c, Sales_Engineer__c, Email from Lead where Id in : recordIds];

    for (Lead led: leds) {
     Provisioning_Request__c pr = new Provisioning_Request__c();
     pr.recordTypeId = ZPAInteractiveRecordTypeId;
     pr.Lead__c = led.Id;
     pr.ZPA_Interactive_User_Email__c = led.Email;
     pr.Provisioning_Status__c = 'Requested';
     pr.ZPA_Manager__c = led.Account_Manager__c; //ZPA_Manager__c;
     pr.ZPA_SE__c = led.Sales_Engineer__c; // ZPA_SE__c;
     pr.Full_Name__c = led.name;
     pr.Provisioning_Date__c = System.today();
     pr.Provisioning_End_Date__c = System.today() + 7;

     prList.add(pr);
    }

    if (prList.size() > 0)
     Insert prList;
   } else if (objectName == 'Contact') {
    List <Contact> cnts = [Select Id, name, AccountId, Account_Manager__c, Sales_Engineer__c, Email from Contact where Id in : recordIds];

    for (Contact con: cnts) {
     Provisioning_Request__c pr = new Provisioning_Request__c();
     pr.recordTypeId = ZPAInteractiveRecordTypeId;
     pr.Primary_Eval_Contact__c = con.Id;
     pr.Account__c = con.AccountId;
     pr.ZPA_Interactive_User_Email__c = con.Email;
     pr.Provisioning_Status__c = 'Requested';
     pr.ZPA_Manager__c = con.Account_Manager__c; //ZPA_Manager__c;
     pr.ZPA_SE__c = con.Sales_Engineer__c; //ZPA_SE__c;
     pr.Full_Name__c = con.name;
     pr.Provisioning_Date__c = System.today();
     pr.Provisioning_End_Date__c = System.today() + 7;

     prList.add(pr);
    }

    if (prList.size() > 0)
     Insert prList;
   }
  }
 }
}