public class DeletePartnersClass {
    
    @AuraEnabled
    public static Map<string,string> DeletePartner(string PartnerId){
        Map<string,string> ResultMap = new Map<string,string>();
        List<Opportunity_Partner__c> PartnerList = new List<Opportunity_Partner__c>();
        try{
            if(PartnerId != null){
                PartnerList = [Select Id,Name,Is_Primary__c,Opportunity__c from Opportunity_Partner__c Where Id=:PartnerId limit 1];
                //Delete [select Id,Name from Opportunity_Partner__c Where Id=:PartnerId];
                if(PartnerList.size()>0){
                    if(PartnerList[0].Is_Primary__c == false){
                        Delete [select Id,Name from Opportunity_Partner__c Where Id=:PartnerId];
                        ResultMap.put('State','Success');
                        ResultMap.put('OppId',PartnerList[0].Opportunity__c);
                        ResultMap.put('Message','Partner Removed Successfully');
                    }else{
                        ResultMap.put('State','Error');
                        ResultMap.put('OppId',PartnerList[0].Opportunity__c);
                        ResultMap.put('Message','Primary Partner cannot be deleted');
                    }
                }
            }
        }Catch(Exception ex){
            ResultMap.put('State','Error');
            ResultMap.put('Message',ex.getMessage());
        }
        return ResultMap;
    }
}