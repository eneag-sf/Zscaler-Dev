public class ContractDetailTriggerHelper{
    public static void UpdateIncumbentPartneronAccount(List<Contract_Detail__c> CntrctDetList){
        Set<String> IncumbentPartnerCntrctDetStatus= new Set<String>();
        String CntrctDetStatusString= ZscalerCustomSetting__c.getInstance('CntrctDetStatusString')!=null && ZscalerCustomSetting__c.getInstance('CntrctDetStatusString').Value__c!=null ? ZscalerCustomSetting__c.getInstance('CntrctDetStatusString').Value__c:'Pending Renewal,Active';
        IncumbentPartnerCntrctDetStatus.addall(CntrctDetStatusString.split(','));
        
        Set<id> AccidSet= new Set<id>();
        Map<id,id> CntrctDetAccidmap= new Map<id,id>();
        Map<id,Account> Accmap= new Map<id,Account>();
        List<Account> ListtoUpdateAccount= new List<Account>();
        for(Contract_Detail__c cd:CntrctDetList){
            if(cd.Partner_Account_Name__c!=null && cd.Contract_Detail_Status__c!=null && cd.Contract_Detail_Status__c!='' &&IncumbentPartnerCntrctDetStatus.contains(cd.Contract_Detail_Status__c)){
                AccidSet.add(cd.Partner_Account_Name__c);
                CntrctDetAccidmap.put(cd.id,cd.Account_Name__c);
            }
        }
        
        if(!AccidSet.isempty() && AccidSet.size()>0){
            Accmap = new Map<id,Account>([Select id,Name from Account where id IN:AccidSet]);           
        }
        if(Accmap!=null){
            for(Contract_Detail__c cd:CntrctDetList){
                if(cd.Partner_Account_Name__c!=null && Accmap.containskey(cd.Partner_Account_Name__c)){
                    Account acc= new Account(id=CntrctDetAccidmap.get(cd.id),Incumbent_Partner_Name__c=Accmap.get(cd.Partner_Account_Name__c).Name);
                    ListtoUpdateAccount.add(acc);
                }
            }
            
        }
        if(!ListtoUpdateAccount.isempty() && ListtoUpdateAccount.size()>0){ database.update(ListtoUpdateAccount,false);
        }
        
    }
}