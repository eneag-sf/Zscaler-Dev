public class AutocreateZscalerCloudIDContact{
    
    public static void CreateZscalerCloudIDContacts(List<Zscaler_Cloud_ID__c> ZCloudList){
        List<String> errorlst = new List<String>();
        Set<id> AccountidSet= new Set<id>();
        Set<String> SendCIOReportstatus= new Set<String>();
        String ContactSendCIOReportstatus= ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus')!=null && ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c!=null ? ZscalerCustomSetting__c.getInstance('ContactSendCIOReportstatus').Value__c:'Send,Send delayed';
        SendCIOReportstatus.addall(ContactSendCIOReportstatus.split(','));

        List<Contact> ContactList= new List<Contact>();
        List<Zscaler_Cloud_ID_Contact__c> ZCloud_IDContactList= new List<Zscaler_Cloud_ID_Contact__c>();
        for(Zscaler_Cloud_ID__c newZCloud:ZCloudList)
        {
            if(!newZCloud.Name.contains('beta')){
                AccountidSet.add(newZCloud.Account__c);             
            }
        }
        if(AccountidSet!=null && AccountidSet.size()>0){
            ContactList=[Select id,Name,Email,AccountId,Send_CIO_Report__c,Contacts_that_matter__c,ZCloudID_Org_IDs__c from Contact where AccountId IN:AccountidSet and Contacts_that_matter__c=true and Send_CIO_Report__c IN:SendCIOReportstatus];                       
        }
        for(Zscaler_Cloud_ID__c newZCloud:ZCloudList)
        {
            if(!newZCloud.Name.contains('beta')){
                for(Contact Con:ContactList){
                    if(String.valueof(Con.AccountId).equalsignorecase(String.valueof(newZCloud.Account__c))){
                        Zscaler_Cloud_ID_Contact__c ZCC= new Zscaler_Cloud_ID_Contact__c();
                        ZCC.Account__c=newZCloud.Account__c;
                        ZCC.Contact__c=Con.id;
                        ZCC.Zscaler_Cloud_ID__c=newZCloud.id;
                        ZCloud_IDContactList.add(ZCC);
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
                }
            }
        }
        
        for(Contact Con:ContactList){
            String OrGIDs='';
            for(Zscaler_Cloud_ID_Contact__c ZCC:ZCloud_IDContactList){
                if(String.valueof(ZCC.Contact__c).equalsignorecase(String.valueof(Con.id))){
                    OrGIDs=OrGIDs+ZCC.Zscaler_Cloud_ID__c+',';
                }
            }
            Con.ZCloudID_Org_IDs__c=OrGIDs;                
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
    
    public static void DeleteZscalerCloudIDContacts(Map<id,Zscaler_Cloud_ID__c> oldmap){
        
        Set<id> ZCloudtodelete= new Set<id>();      
        Set<id> Contactidset= new Set<id>();        
        ZCloudtodelete.addAll(oldmap.keyset());
        List<Zscaler_Cloud_ID_Contact__c> ZCloudContacttoDelete=[Select id,Name,Contact__c,Account__c,Zscaler_Cloud_ID__c from Zscaler_Cloud_ID_Contact__c where Zscaler_Cloud_ID__c IN:ZCloudtodelete];
        for(Zscaler_Cloud_ID_Contact__c ZCC:ZCloudContacttoDelete){
            Contactidset.add(ZCC.contact__c);
        }
        
        Map<Id, Contact> Contactmap = new Map<Id, Contact>([SELECT id,name,ZCloudID_Org_IDs__c from Contact where id IN:Contactidset]);
        
        for(Zscaler_Cloud_ID_Contact__c ZCC:ZCloudContacttoDelete){
            if(Contactmap.containskey(ZCC.Contact__c) && Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c!='' /* && Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c.containsIgnoreCase(Zcc.Zscaler_Cloud_ID__c) */){
                String OrgStr=Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c;
                if(ZCC.Zscaler_Cloud_ID__c!= null && OrgStr!=null &&OrgStr!=''){
                    OrgStr=Orgstr.remove(String.valueof(ZCC.Zscaler_Cloud_ID__c)+',');
                }
                Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c=OrgStr;
            }
        }
        if(!ZCloudContacttoDelete.isEmpty() && ZCloudContacttoDelete.size()>0){
            try {
                TriggerUtility.ZCloudIDcontactDeletetriggersettrue();            
                delete ZCloudContacttoDelete;
            
                TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
                Update Contactmap.values();
            } catch (DmlException e) {
            }
        }
        
        
    }
    
    //method gets invokes when Zscaler_Cloud_ID_Contact__c gets deleted to update Contact
    public static void UpdateContactonZSCloudContactdelete(Map<id,Zscaler_Cloud_ID_Contact__c> ZCloudCnctmap){
        Set<id> Contactidset= new Set<id>();
        List<Contact> ContactList= new List<Contact>();
        
        for(Zscaler_Cloud_ID_Contact__c ZCIDC:ZCloudCnctmap.values()){
            Contactidset.add(ZCIDC.contact__c);         
        }
        Map<Id, Contact> Contactmap = new Map<Id, Contact>([SELECT id,name,ZCloudID_Org_IDs__c from Contact where id IN:Contactidset]);
        
        for(Zscaler_Cloud_ID_Contact__c ZCC:ZCloudCnctmap.values()){
            if(Contactmap.containskey(ZCC.Contact__c) && Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c!='' /* && Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c.containsIgnoreCase(Zcc.Zscaler_Cloud_ID__c) */){
                String OrgStr=Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c;
                if(ZCC.Zscaler_Cloud_ID__c!=null && OrgStr!=null &&OrgStr!=''){
                OrgStr=Orgstr.remove(String.valueof(ZCC.Zscaler_Cloud_ID__c)+',');
                Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c=OrgStr;
                }
                
            }
        }
        try {
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            Update Contactmap.values();
        } catch (DmlException e) {
                // Process exception here
        }
    }
    
    //method gets invokes when Zscaler_Cloud_ID_Contact__c gets inserted manually to update Contact
    public static void UpdateContactonZSCloudContactInsert(List<Zscaler_Cloud_ID_Contact__c> NewZCloudCnctList){
        Set<id> Contactidset= new Set<id>();
        List<Contact> ContactList= new List<Contact>();
        
        for(Zscaler_Cloud_ID_Contact__c ZCIDC:NewZCloudCnctList){
            Contactidset.add(ZCIDC.contact__c);         
        }
        Map<Id, Contact> Contactmap = new Map<Id, Contact>([SELECT id,name,ZCloudID_Org_IDs__c from Contact where id IN:Contactidset]);
        
        for(Zscaler_Cloud_ID_Contact__c ZCC:NewZCloudCnctList){
            if(Contactmap!=null && Contactmap.containskey(ZCC.Contact__c)){
                String OrgStr=Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c;
                OrgStr=Orgstr+String.valueof(ZCC.Zscaler_Cloud_ID__c)+',';
                Contactmap.get(ZCC.Contact__c).ZCloudID_Org_IDs__c=OrgStr;
            }
        }
        try {
            TriggerUtility.AutocreateZCloudIDcontactUpdatesettrue();
            Update Contactmap.values();
        } catch (DmlException e) {
                // Process exception here
        }
    }
}