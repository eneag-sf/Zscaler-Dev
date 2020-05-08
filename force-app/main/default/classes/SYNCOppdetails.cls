@RestResource(urlMapping='/SYNCOppdetails/*')
global with sharing class SYNCOppdetails {
    global static Boolean avoidtriggers = false;
    
    @HttpPost
    global static Map<String, List<String>> doPost(Map<String, Opportunity> opplst) {
        List<String> errorlst = new List<String>();
        List<String> successlst = new List<String>();
        avoidtriggers = true;
        Map<String, List<String>> mapresult = new Map<String, List<String>>();
        if(opplst != null){
        
            for(Opportunity opp: [Select Id, Approved_Pzen_ME__c, Approved_Equipment_Request__c, Approved_DLP_PZen_ER__c, Approved_Equipment_Request_VZEN__c from Opportunity where Id in :opplst.keyset()]){
                if(opp.Approved_Pzen_ME__c){
                    opplst.get(opp.Id).Approved_Pzen_ME__c = opp.Approved_Pzen_ME__c;
                }
                if(opp.Approved_Equipment_Request__c){
                    opplst.get(opp.Id).Approved_Equipment_Request__c = opp.Approved_Equipment_Request__c;
                }
                if(opp.Approved_DLP_PZen_ER__c){
                    opplst.get(opp.Id).Approved_DLP_PZen_ER__c = opp.Approved_DLP_PZen_ER__c;
                }
                if(opp.Approved_Equipment_Request_VZEN__c){
                    opplst.get(opp.Id).Approved_Equipment_Request_VZEN__c = opp.Approved_Equipment_Request_VZEN__c;
                }
            }
            
            Database.SaveResult[] srList = database.update(opplst.values(),false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    successlst.add(sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        String s = '';
                        if(srList.indexOf(sr) != -1 && !opplst.values().isEmpty() && opplst.values().size() > srList.indexOf(sr) && opplst.values()[srList.indexOf(sr)] != null){
                            s = opplst.values()[srList.indexOf(sr)].Id;
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