public class MatchingAccountDealRegControllerExt {
    public List<Deal_Reg__c> matchingDealRegList {get;set;}
    private Account acc;
    public MatchingAccountDealRegControllerExt(ApexPages.StandardController controller) {
        this.acc= (Account)controller.getRecord();
        matchingDealRegList = new list<Deal_Reg__c>();
        this.acc= [Select Id,Domain__c from Account where ID =: acc.Id];
        if(acc.Domain__c  != '' && acc.Domain__c != null ){
            for(Deal_Reg__c deal : [Select id, Name,Partner_Company_Name__c, Status__c, Partner_Contact_Name__c, Partner_Contact_Last_Name__c, End_Customer_Name__c, Expiration_Date__c from Deal_Reg__c where End_Customer_Domain__c =: acc.Domain__c])
                matchingDealRegList.add(deal);        
        }
        
    }
    }