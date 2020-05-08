/**
 * @File Name          : Universal_Test_Utils.cls
 * @Description        : Universal methods for test class should be kept here for single reference point.
 * @Author             : pranjalsingh@zscaler.com
 * @Group              : 
 * @Last Modified By   : pranjalsingh@zscaler.com
 * @Last Modified On   : 21/6/2019, 5:23:04 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    21/6/2019, 4:35:01 PM   pranjalsingh@zscaler.com     Initial Version
**/
@isTest
public with sharing class Universal_TestData {

    public static List<Account> getAccounts(String name,String type, Integer num) {
       List<Account> accList = new List<Account>();
       for(Integer i=0;i<num;i++){
        Account accObj = new Account(Type = type, Name = name);
        accList.add(accObj);
       }
       return accList;
    }
    public static List<Opportunity> getOpp(List<Account> accList,String accName,String stage){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Account acc : accList){
              Opportunity opp = new Opportunity(Name = accName,AccountId = acc.Id,
                                                StageName = stage, 
                                                CloseDate = Date.Today().addDays(20));
              oppList.add(opp);
        }
       return oppList;
    }
}