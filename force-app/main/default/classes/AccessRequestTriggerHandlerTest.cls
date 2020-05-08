@isTest
public class AccessRequestTriggerHandlerTest {
    @testSetup
    static void setup() {
        Id RecordTypeIdAcc = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();
        Access_Request__c rec = new Access_Request__c();
        rec.RecordTypeId = RecordTypeIdAcc;
        rec.Recall_Approval__c = false;
        rec.Request_Status__c = 'In Active';
        rec.Request_Type__c = 'Account Access';
        insert rec;
    }
    
    static testMethod void testmethod1(){
        try{
            list<Access_Request__c> accReqList = [Select id,Recall_Approval__c,Request_Status__c From Access_Request__c];
            for(Access_Request__c rec:accReqList){
                rec.Recall_Approval__c = true;
                rec.Request_Status__c = 'Approved';
            }
            update accReqList;
        }
        catch(exception e){ 
            
        }
    }
}