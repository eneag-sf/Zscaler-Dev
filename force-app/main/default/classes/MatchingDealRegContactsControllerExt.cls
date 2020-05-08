public class MatchingDealRegContactsControllerExt {
    public List<Contact> matchingContactList {get;set;}
    private Deal_Reg__c deal;
    public MatchingDealRegContactsControllerExt(ApexPages.StandardController controller) {
        this.deal = (Deal_Reg__c)controller.getRecord();
        matchingContactList = new list<contact>();
        this.deal = [Select Id,End_Customer_Email__c from Deal_Reg__c where ID =: deal.Id];
        if(deal.End_Customer_Email__c!= '' && deal.End_Customer_Email__c!= null ){
            for(contact con : [Select id, Name, Email, Phone, Company_Name__c, Contact_Lead_Status__c, mkto2__Lead_Score__c from contact where Email =: deal.End_Customer_Email__c])
                matchingContactList .add(con);        
        }
    }

}