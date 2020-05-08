public class Renewal_Notification_EmailController{
    Public String oppId{get; set;}
    Public Boolean showvalueSummary{get; set;}
    Public Boolean ispastdueoppty{get; set;}
    Public Boolean isopptycontractextended{get; set;}
    Public Boolean isopptyextendedexpired{get; set;}
    Public Boolean isupcomingnotification{get; set;}
    Public Boolean istermination{get; set;}
    Public Boolean dayofexpiry{get; set;}
    Public Boolean isextensiontermination{get; set;}
    
    public String yearVal {
        get{
            return String.valueOf(date.today().year());
        } set;
    }
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    Public Opportunity opp{get {
        if(oppId != null){
            
            opp = [Select Id, Name,Netsuite_Sales_Order_No__c, Type,Opportunity_Customer_Advocate__c, Owner.Phone, Owner.Email, Primary_Partner__c, Account.Zscaler_Customer_Summary__c, Account.Generate_Value_Summary__c, Contract_End_Date_New__c, New_Extended_Contract_Date__c from Opportunity where Id = :oppId];
            
            showvalueSummary = (opp.Account.Generate_Value_Summary__c != 'This account does not have enough data to generate value summary document.');
            
        }
        return opp;
    } set;}
    
    Public String daystocontract {get {
        if(oppId != null){
            
            opp = [Select Id, Name,Type,Opportunity_Customer_Advocate__c, Owner.Phone, Owner.Email, Primary_Partner__c, Account.Zscaler_Customer_Summary__c, Account.Generate_Value_Summary__c, Contract_End_Date_New__c from Opportunity where Id = :oppId];
            
            daystocontract = String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())));
        }
        return daystocontract ;
    } set;}
    
    Public List<Contract_Detail__c> olilst{get {
        if(oppId != null && opp.Netsuite_Sales_Order_No__c != null && opp.Netsuite_Sales_Order_No__c != ''){
            Opportunity opp = opp;
            String sonum = opp.Netsuite_Sales_Order_No__c.deleteWhitespace();
            List<String> sonumlst = sonum != null && sonum != '' ? sonum.split(',') : new List<String>();
            if(!sonumlst.isEmpty()){
                olilst = [Select Id, Product_Name__r.Name, Quantity__c, End_Date__c, Product_SKU__c from Contract_Detail__c where Sales_Order_Name__c in :sonumlst];
            }
        }
        return olilst;
    }  set;}
    
}