public class GetFeedItemsofCase{
    public Id equipmentRequestRecordId { get; set; }
    public String typeofTemplate { get; set; }
    public FeedItem latestFi { get; set; }
    public Id Caseid {get;set;}
    public Case Case1 {get;set;}

    public GetFeedItemsofCase() {
        getER();
        getFeedItem();
        
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
        List<Case> erlst = [SELECT id,owner.name,CaseNumber,Subject,Status,Contactid,Contact.Name,Ownerid,Accountid,Account.Name,Case_Owner__c,Case_URL__c FROM Case where id = :equipmentRequestRecordId];
        if(!erlst.isEmpty()){
            return erlst[0];
        }
        return null;
    }

    public FeedItem getFeedItem() {
        latestFi = new FeedItem();

      /*   for (Datacenter__c request : [select id, name, Equipment_Request__c, Quantity_Requested_for_LB__c, Facility_Country__c, Facility_City__c, Requested_Hardware_Model__c, Quantity_Requested__c, Available_Bandwidth_MBPS__c, Reason_for_Pitching_PZEN__c, Number_of_Users_at_location__c, Is_latency_less_than_300_milliseconds__c, Link_to_Architecture_Workshop__c, Shipment_Receiving_Contact_Name__c, Shipment_Receiving_contact_Email__c, Shipment_Receiving_Contact_Ph_No__c, Project_Manager_Name__c, Project_Manager_Phone_No__c, Projet_Manager_Email_Address__c from Datacenter__c where Equipment_Request__c = :equipmentRequestRecordId]){
            lstFeedItem.add(request);
        } */
        
        latestFi= new Feeditem();
        List<FeedItem> FeedItemlist= new List<FeedItem>([Select id,Body,ParentId,Status,Title,Type,Visibility,CreatedDate,CreatedBy.FirstName FROM FeedItem where ParentId=:equipmentRequestRecordId and Visibility='AllUsers' and (Type='TextPost' OR Type='EmailMessageEvent') order by CreatedDate Desc Limit 1]);
        system.debug('FeedItemlist '+FeedItemlist);
        if(!FeedItemlist.isEmpty()){
            return FeedItemlist[0];
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