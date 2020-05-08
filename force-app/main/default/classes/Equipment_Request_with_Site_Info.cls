public class Equipment_Request_with_Site_Info{
    public Id equipmentRequestRecordId { get; set; }
    public String typeofTemplate { get; set; }
    public List<Datacenter__c> lstSiteRequests { get; set; }

    public Equipment_Request_with_Site_Info() {
        getER();
        getSites();
    }
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}

    public Equipment_Request__c getER(){
        List<Equipment_Request__c> erlst = [Select Id, Name, Opportunity__c, Opportunity__r.Owner.Name, Account_Name__c, Opportunity__r.Name, Opportunity_ACV__c, Equipment_Use__c, Equipment_Type__c, Quantity_requested1__c, Requested_Hardware_Model__c, Deployment_Location__c, Available_Bandwidth_MBPS__c, Number_of_Users_at_location__c, Is_latency_less_than_300_milliseconds__c, Reason_for_Equipment__c, Additional_Information__c from  Equipment_Request__c where Id = :equipmentRequestRecordId];
        if(!erlst.isEmpty()){
            return erlst[0];
        }
        return null;
    }

    public List<Datacenter__c> getSites() {
        lstSiteRequests = new List<Datacenter__c>();

        for (Datacenter__c request : [select id, name, Equipment_Request__c, Quantity_Requested_for_LB__c, Facility_Country__c, Facility_City__c, Requested_Hardware_Model__c, Quantity_Requested__c, Available_Bandwidth_MBPS__c, Reason_for_Pitching_PZEN__c, Number_of_Users_at_location__c, Is_latency_less_than_300_milliseconds__c, Link_to_Architecture_Workshop__c, Shipment_Receiving_Contact_Name__c, Shipment_Receiving_contact_Email__c, Shipment_Receiving_Contact_Ph_No__c, Project_Manager_Name__c, Project_Manager_Phone_No__c, Projet_Manager_Email_Address__c from Datacenter__c where Equipment_Request__c = :equipmentRequestRecordId]){
            lstSiteRequests.add(request);
        }

        return lstSiteRequests;
    }
}