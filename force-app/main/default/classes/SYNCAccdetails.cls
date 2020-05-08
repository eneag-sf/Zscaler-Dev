@RestResource(urlMapping='/SYNCAccdetails/*')
global with sharing class SYNCAccdetails {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static Map<String, List<String>> doPost(Map<String ,Account> acclst) {
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();
        avoidtriggers = true;
        Map<String, List<String>> mapresult = new Map<String, List<String>>();
        if(acclst != null){
            Set<Id> accids = new set<Id>();
            
            TriggerUtility.accTerritoryPatchExecuted();
            TriggerUtility.accSalesTeamExecuted();
            
            for(Account acc: acclst.values()){
                if(acc.Success_Stage__c == null){
                    acc.Success_Stage__c = '';
                }
                /**if(acc.CSM_Account_Score__c == null){
                    acc.CSM_Account_Score__c = '';
                }**/
            }
            
            Database.SaveResult[] srList = database.update(acclst.values(),false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        String s = '';
                        if(srList.indexOf(sr) != -1 && !acclst.values().isEmpty() && acclst.values().size() > srList.indexOf(sr) && acclst.values()[srList.indexOf(sr)] != null){
                            s = acclst.values()[srList.indexOf(sr)].Id;
                        }
                        errorlst.add(s + ' - ' + err.getMessage());
                    }
                }
            }
            mapresult.put('successlst', successlst);
            if(!errorlst.isEmpty()){
                mapresult.put('errorlst', errorlst);
            }
        }
        avoidtriggers = false;
        return mapresult;
        
    }
}