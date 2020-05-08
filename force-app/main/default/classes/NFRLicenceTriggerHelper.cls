public class NFRLicenceTriggerHelper {
    
    public static map<id,string> getAccountOwnerEmails(set<id> accountOwnerIds){
        map<id,string>AccountOwnerEmailsMap = new map<id,string>();
        for(user userRecord:[Select id,Email From User Where id In:accountOwnerIds]){
            if(userRecord.Email != null){
                AccountOwnerEmailsMap.put(userRecord.Id,userRecord.Email);
            }
        }
        return AccountOwnerEmailsMap;
    }
    
    public static list<string> getSpecificUserEMails(){
        list<string> userEmails = new list<string>();
        list<string> userNames = new list<string>{'Charan Kumar','Ben Teague'};
         for(user userRecord:[Select id,Email From User Where Name In:userNames]){
            if(userRecord.Email != null){
                userEmails.add(userRecord.Email);
            }
        }
        return userEmails;
    }
    
    public static list<POC_Product__c> preparePOCProductList(list<Provisioning_Request__c> prList){
        list<POC_Product__c> pocProductList = new list<POC_Product__c>();
        list<product2> productList = [Select id,Product_SKU_External_ID__c From product2 Where Product_SKU_External_ID__c='ZSC-SIP'];
        if(productList.size()>0){
            product2 productRecord = productList[0];
            for(Provisioning_Request__c PRrec:prList){
                if(PRrec.SIP_NFR__c == true){
                 POC_Product__c POCRecord = new POC_Product__c();
                    POCRecord.Product__c = productRecord.Id;
                    POCRecord.Provisioning_Request__c = PRrec.Id;
                    pocProductList.add(POCRecord);
                }
            }
        }
        return pocProductList;
    }

}