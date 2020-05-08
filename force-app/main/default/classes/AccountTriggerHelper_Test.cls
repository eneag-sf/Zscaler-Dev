@isTest
public class AccountTriggerHelper_Test{

    @isTest private static void updateCustomerSupportStage_test(){
        
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and isActive=true LIMIT 1];
        System.runas(usr){
            Test.StartTest();
               
            Test.StopTest();
        }
    }
}