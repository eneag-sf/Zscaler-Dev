public class AssociatedOpportunityDealRegsExt {

      private ApexPages.StandardController controller {get; set;}
    private Opportunity opp;
    public List<Deal_Reg__c> matchingDealRegList {get;set;}
   
    public AssociatedOpportunityDealRegsExt(ApexPages.StandardController controller) {
             //initialize the stanrdard controller
        this.controller = controller;
        this.opp = (Opportunity)controller.getRecord();
        matchingDealRegList = new list<Deal_Reg__c>();
        this.Opp = [Select Id,Associated_Deal_Registrations__c from Opportunity where ID =: opp.Id];
        if(Opp.Associated_Deal_Registrations__c != '' && Opp.Associated_Deal_Registrations__c != null ){
            for(Deal_Reg__c de : [Select Id, Name, Partner_Company_Name__c, Partner_Contact_Name__c, Status__c, Expected_Close_Date__c, End_Customer_Contact_Name__c, End_Customer_Contact_Last_Name__c from Deal_Reg__c Where ID IN: Opp.Associated_Deal_Registrations__c.Split(',') limit 999]){
                matchingDealRegList.add(de);
            }
        }
    }

}