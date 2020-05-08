@isTest
public class BR_Trigger_Handler_Test{
    static testmethod void test1(){
        Event_Expenditure_Request__c er = new Event_Expenditure_Request__c(Name = 'BR1', Does_this_contract_require_signature__c = 'No', Vendor_Technical_Contact_Email__c = 'abc@abc.com', Vendors_access_to_Zscaler_employee_Data__c = 'No', Vendors_access_to_Zscaler_customer_Data__c = 'No');
        insert er;
        er.Does_this_contract_require_signature__c = 'Yes';
        try{
            update er;
        }catch(Exception ex){
        
        }
        
    }

}