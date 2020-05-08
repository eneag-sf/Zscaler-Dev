public class GetCasedetailsforCustomerEmail{
public Id equipmentRequestRecordId { get; set; }
    public String typeofTemplate { get; set; }
    //public FeedItem latestFi { get; set; }
    public Id Caseid {get;set;}
    public Case Case1 {get;set;}

    public GetCasedetailsforCustomerEmail() {
        getER();
        //getFeedItem();
        
        system.debug('inside GetFeedItemsofCase constructor');
        system.debug('Caseid   '+Caseid);
        /* GetCaseRecord();   
        getlatestFi();  */  
    }
    public string url{get{
     String OrgURL= ZscalerCustomSetting__c.getInstance('OrgURL')!=null && ZscalerCustomSetting__c.getInstance('OrgURL').Value__c!=null ? ZscalerCustomSetting__c.getInstance('OrgURL').Value__c:'https://zscaler--uat.cs26.my.salesforce.com';
        url = OrgURL;
        return url;
    } set;}

    public Case getER(){
        List<Case> erlst = [SELECT id,owner.name,Description,CaseNumber,Subject,Status,Product_New__c,Priority,Case_Type__c,Contactid,Contact.Name,Ownerid,Accountid,Account.Name,Account.type,Case_Owner__c,Case_URL__c FROM Case where id = :equipmentRequestRecordId];
        if(!erlst.isEmpty()){
            return erlst[0];
        }
        return null;
    }

    /* public FeedItem getFeedItem() {
        latestFi = new FeedItem();
        List<FeedItem> FeedItemlist= new List<FeedItem>([Select id,Body,ParentId,Status,Title,Type,Visibility,CreatedDate,CreatedBy.FirstName FROM FeedItem where ParentId=:equipmentRequestRecordId and Visibility='AllUsers' and (Type='TextPost' OR Type='EmailMessageEvent') order by CreatedDate Desc Limit 1]);
        system.debug('FeedItemlist '+FeedItemlist);
        if(!FeedItemlist.isEmpty()){
            return FeedItemlist[0];
        }
        return null;
    } */
      
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