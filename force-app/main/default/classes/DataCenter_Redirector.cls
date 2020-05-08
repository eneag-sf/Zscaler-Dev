public with Sharing class DataCenter_Redirector {
    public Map<String,string> urlparams; 
    String returl = '';
    Id pZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
    Id pZenwithLBRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Private_ZEN_with_LB').getRecordTypeId();
    Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
    public DataCenter_Redirector(ApexPages.StandardController controller) {
        urlparams = ApexPages.currentPage().getParameters();
    }
    public pagereference init(){
        if(urlparams.containsKey('id')){
            list<Datacenter__c> eqlst = [Select Id, Equipment_Request__c, Equipment_Request__r.RecordtypeId from Datacenter__c where Id = :urlparams.get('id')];
            if(!eqlst.isEmpty()){
                if(eqlst[0].Equipment_Request__r.RecordtypeId == pZenRecordTypeId || eqlst[0].Equipment_Request__r.RecordtypeId == pZenwithLBRecordTypeId || eqlst[0].Equipment_Request__r.RecordtypeId == serviceedgePZENRecordTypeId){
                    returl = '/apex/Equipment_Request_Creation?id=' + eqlst[0].Equipment_Request__c;
                    if(urlparams != null){
                        for(String s: urlparams.keyset()){
                            if(s != null && urlparams.get(s) != null && !s.contains('save_new') && !s.contains('id'))
                                returl += '&'+s+'=' + urlparams.get(s);
                        }
                        system.debug('++++'+returl);
                    }
                }else{
                    returl = '/' + urlparams.get('id') + '/e?nooverride=1&retURL=/' + urlparams.get('id');
                }
            }
        }else{
            Schema.DescribeSObjectResult r = Datacenter__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            returl = '/'+ keyPrefix + '/o';
        }
        return new Pagereference(returl);
    }

}