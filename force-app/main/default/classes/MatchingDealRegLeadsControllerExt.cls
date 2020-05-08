public class MatchingDealRegLeadsControllerExt {
    public List<Lead> matchingLeadList {get;set;}
    private Deal_Reg__c deal;

    public MatchingDealRegLeadsControllerExt(ApexPages.StandardController controller) {
         this.deal = (Deal_Reg__c)controller.getRecord();
        matchingLeadList = new list<Lead>();
        this.deal = [Select Id,End_Customer_Email__c from Deal_Reg__c where ID =: deal.Id];
        if(deal.End_Customer_Email__c!= '' && deal.End_Customer_Email__c!= null ){
            for(Lead le : [Select id, Name, Status, Email, Company, Phone, mkto2__Lead_Score__c from Lead where Email =: deal.End_Customer_Email__c])
                matchingLeadList.add(le);        
        }
        

    }

}