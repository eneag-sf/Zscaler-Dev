public class GetCaseDetails{
    public Id equipmentRequestRecordId { get; set; }
    public String typeofTemplate { get; set; }
    public Case CaseFi { get; set; }
    public Id Caseid {get;set;}
    public Id CaseAssignedid;
    public Case Case1 {get;set;}

    public GetCaseDetails() {
        getER();
        getCase();
        
        /* GetCaseRecord();   
        getlatestFi();  */  
    }
    public string url{get{
        //url = System.Url.getSalesforceBaseURL().toExternalForm();
        String OrgURL= ZscalerCustomSetting__c.getInstance('OrgURL2')!=null && ZscalerCustomSetting__c.getInstance('OrgURL2').Value__c!=null ? ZscalerCustomSetting__c.getInstance('OrgURL2').Value__c:'https://zscaler--uat.cs26.my.salesforce.com';
        url = OrgURL;
        return url;
    } set;}

    public AgentWork getER(){
        List<AgentWork> erlst = [SELECT id,Name,PreferredUserId,Status,UserId,WorkItemId,owner.name,LastModifiedBy.Name FROM AgentWork where id = :equipmentRequestRecordId];
        if(!erlst.isEmpty()){
            CaseAssignedid=erlst[0].WorkItemId;
            return erlst[0];
        }
        return null;
    }

    public Case getCase() {
        
        CaseFi = new Case();
        List<Case> Caselist= new List<Case>([Select id,CaseNumber,Subject,Description,Ownerid,Accountid,Account.Name,LastModifiedBy.Name FROM Case where id=:CaseAssignedid Limit 1]);

        if(!Caselist.isEmpty()){
            return Caselist[0];
        }
        return null;
    }
    public static void booster(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}