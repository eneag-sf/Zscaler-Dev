public class CreateZCloudIDContactbatch implements Database.Batchable<sObject>, Database.Stateful{
    List<String> errorlst= new List<String>();
    List<String> successlst = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext context){
        
        String query= ZscalerCustomSetting__c.getInstance('CreateZCloudIDContactbatch')!=null && ZscalerCustomSetting__c.getInstance('CreateZCloudIDContactbatch').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CreateZCloudIDContactbatch').Value__c:'SELECT id,Name,Account__c,Cloud_Type__c,Status__c FROM Zscaler_Cloud_ID__c';    
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext context, List<Zscaler_Cloud_ID__c> ZCloudIDlist){
        Set<id> AccountIdSet= new Set<id>();
        Map<id,List<Zscaler_Cloud_ID__c>> AccZCloudIDmap= new Map<id,List<Zscaler_Cloud_ID__c>>();
        List<Contact> Contactlist= new List<Contact>();
        
        List<Zscaler_Cloud_ID_Contact__c> ZCloud_IDContactList= new List<Zscaler_Cloud_ID_Contact__c>();
        Set<String> SendCIOReportstatus= new Set<String>();
        String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
        SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));
        
        if(!ZCloudIDlist.isempty() && ZCloudIDlist.size()>0){
            for(Zscaler_Cloud_ID__c ZCID:ZCloudIDlist){
                if(!ZCID.name.contains('beta')){
                    
                    AccountIdSet.add(ZCID.Account__c);
                    /* if(!AccZCloudIDmap.containskey(ZCID.Account__c)){
                        List<Zscaler_Cloud_ID__c> ZCIDlist= new List<Zscaler_Cloud_ID__c>();
                        ZCIDlist.add(ZCID);
                        AccZCloudIDmap.put(ZCID.Account__c,ZCIDlist);
                    }else{
                        if(!AccZCloudIDmap.isempty() && AccZCloudIDmap.containskey(ZCID.Account__c) ){
                            AccZCloudIDmap.get(ZCID.Account__c).add(ZCID);
                        }
                        
                    } */
                }else{
                }
            }
        }
        if(AccountidSet!=null && AccountidSet.size()>0){
            ContactList=[Select id,Name,Email,AccountId,Send_CIO_Report__c,Contacts_that_matter__c,ZCloudID_Org_IDs__c from Contact where AccountId IN:AccountidSet and Contacts_that_matter__c=true and Send_CIO_Report__c IN:SendCIOReportstatus];                       
        }
        if(!ZCloudIDlist.isempty() && ZCloudIDlist.size()>0){
            for(Zscaler_Cloud_ID__c ZCID:ZCloudIDlist){
                if(!ZCID.name.contains('beta')){
                    for(Contact Con:ContactList){
                        if(String.valueof(Con.AccountId).equalsignorecase(String.valueof(ZCID.Account__c))){
                            Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                            ZCC.Account__c=ZCID.Account__c;
                            ZCC.Contact__c=Con.id;
                            ZCC.Zscaler_Cloud_ID__c=ZCID.id;
                            ZCloud_IDContactList.add(ZCC);
                        }
                        
                    }
                }
            }
        }
        TriggerUtility.ZCloudIDcontactAfterInserttriggersettrue();
        if(!ZCloud_IDContactList.isempty() && ZCloud_IDContactList.size()>0){
            Database.SaveResult[] srList = database.insert(ZCloud_IDContactList, false);
             for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {                      
                        errorlst.add(sr.getId() + ' - ' + err.getMessage());
                    }
                }else{
                    successlst.add(sr.getId());
                }
            }
        }
        if(!ContactList.isempty() && ContactList.size()>0){
            for(Contact Con:ContactList){
                String OrGIDs='';
                for(Zscaler_Cloud_ID_Contact__c ZCC:ZCloud_IDContactList){
                    if(String.valueof(ZCC.Contact__c).equalsignorecase(String.valueof(Con.id))){
                        OrGIDs=OrGIDs+ZCC.Zscaler_Cloud_ID__c+',';
                    }
                }
                Con.ZCloudID_Org_IDs__c=OrGIDs;                
            }
        }
        if(!ContactList.isempty() && ContactList.size()>0){ 
            try {
                TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
                update ContactList;
            } catch (DmlException e) {
                // Process exception here
            }
        }
        
    }
    
    public void finish(Database.BatchableContext context){
        
    }
    
    
}