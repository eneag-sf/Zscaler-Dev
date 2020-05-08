public class MatchingDealRegControllerExt{
    private ApexPages.StandardController controller {get; set;}
    private Deal_Reg__c deal;
    public List<Deal_Reg__c> matchingDealRegList {get;set;}
    public MatchingDealRegControllerExt(ApexPages.StandardController controller){
        //initialize the stanrdard controller
        this.controller = controller;
        this.deal = (Deal_Reg__c)controller.getRecord();
        matchingDealRegList = new list<Deal_Reg__c>();
        this.deal = [Select Id,End_Customer_Domain__c from Deal_Reg__c where ID =: deal.Id];
        if(deal.End_Customer_Domain__c  != '' && deal.End_Customer_Domain__c != null ){
            for(Deal_Reg__c de : [Select Id, Name, Partner_Company_Name__c, Partner_Contact_Name__c, Status__c, End_Customer_Contact_Name__c, End_Customer_Contact_Last_Name__c from Deal_Reg__c Where End_Customer_Domain__c =: deal.End_Customer_Domain__c AND ID !=: deal.Id limit 999]){
                matchingDealRegList.add(de);
            }
        }
    }
}