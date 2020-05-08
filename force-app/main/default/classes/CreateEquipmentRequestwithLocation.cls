public with Sharing class CreateEquipmentRequestwithLocation {
    public Equipment_Request__c eReq {get; set;}
    public list<Datacenter__c> datacenterlst{get; set;}
    public String indextoRemove{get;set;}
    public List<SelectOption> reqHWmodel{get;set;}
    public List<SelectOption> dcRecTypeOptions{get;set;}
    public String rectypeDC{get; set;}
    public Boolean isedit{get; set;}
    public Boolean isinApproval{get; set;}
    public String erBanner{get; set;}
    public String GEvalue{get; set;}
    Map<String,string> urlparams; 
    String profname = '';
    public CreateEquipmentRequestwithLocation(ApexPages.StandardController controller) {
        GEvalue = '';
        erBanner = 'Equipment Request Form';
        urlparams = ApexPages.currentPage().getParameters();
        eReq = (Equipment_Request__c )controller.getRecord();
        isedit = ereq.Id != null;
        
        if((ereq.Id != null && ereq.Opportunity__c != null) || (urlparams.containsKey('CF00N70000002s1R1_lkid') && urlparams.get('CF00N70000002s1R1_lkid') != null && urlparams.get('CF00N70000002s1R1_lkid') != '')){
            String oppId = ereq.Opportunity__c != null? ereq.Opportunity__c : urlparams.get('CF00N70000002s1R1_lkid');
            List<Opportunity> opplst = [Select Id, name from Opportunity where Id = :oppId];
            if(!opplst.isEmpty()){
                erBanner += ' for ' + opplst[0].name;
            }
        }
        datacenterlst = new list<Datacenter__c>();
        String developerName = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosById().get(eReq.RecordTypeId).getDeveloperName();
        if(developerName == 'PZEN'){
            eReq.Equipment_type__c = 'Private ZEN (Existing PZEN customers only)';
        }else if(developerName == 'Private_ZEN_with_LB'){
            eReq.Equipment_type__c = 'Private ZEN with LB (Existing PZEN customers only)';
        }else if(developerName == 'ZIA_Service_Edge_PZEN'){
            eReq.Equipment_type__c = 'ZIA Service Edge  ';
        }
        reqHWmodel = new List<SelectOption>();
        dcRecTypeOptions = new List<SelectOption>();
        for(String s: Requested_Hardware_Model_Values__c.getValues(developerName).Values__c.split(';')){
            reqHWmodel.add(new SelectOption(s,s));
        }
        Schema.DescribeSObjectResult d = Schema.SObjectType.Datacenter__c;
        List<Schema.RecordTypeInfo> RT = d.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : RT )
        {
            if(recordType != null && recordType.isAvailable()){ 
                String val = recordType.getName();
                if(val != null && val != '' && val != 'Master') {
                    dcRecTypeOptions.add(new SelectOption(val , val ));
                }
            }
        }

    }
    public void pageLoad(){
        if(eReq.Id != null){
            datacenterlst = [select id, Account__c, Facility_Address__c, Shipping_Address__c, Customer_Contact__c, name, Equipment_Request__c, Quantity_Requested_for_LB__c, Facility_Country__c, Facility_City__c, Requested_Hardware_Model__c, Quantity_Requested__c, Available_Bandwidth_MBPS__c, Reason_for_Pitching_PZEN__c, Number_of_Users_at_location__c, Is_latency_less_than_300_milliseconds__c, Link_to_Architecture_Workshop__c, Shipment_Receiving_Contact_Name__c, Shipment_Receiving_contact_Email__c, Shipment_Receiving_Contact_Ph_No__c, Project_Manager_Name__c, Project_Manager_Phone_No__c, Projet_Manager_Email_Address__c from Datacenter__c where Equipment_Request__c = :eReq.Id];
        }
        List<Profile> profilelst = [Select Id, Name from Profile where Id = :userinfo.getProfileId()];
        
        if(!profilelst.isEmpty()){
            profname = profilelst[0].name;
        }
        isinApproval = profname != 'System Administrator' && (eReq.Approval_Status__c == 'Approved' || eReq.Approval_Status__c == 'Pending Approval' || eReq.Approval_Status__c == 'Pending Cloud Ops Approval' || eReq.Approval_Status__c == 'Pending GEO SE Approval' || eReq.Approval_Status__c == 'Pending PM Approval' || eReq.Approval_Status__c == 'Pending CEO Approval' || eReq.Approval_Status__c == 'Pending Cloud Ops/Support Approval');
    }
    public void addLocation(){
        Id rectypeId = Schema.SObjectType.Datacenter__c.getRecordTypeInfosByName().get('Customer Datacenter').getRecordTypeId();
        if(rectypeDC != null && rectypeDC != ''){
            rectypeId = Schema.SObjectType.Datacenter__c.getRecordTypeInfosByName().get(rectypeDC).getRecordTypeId();
        }
        datacenterlst.add(new Datacenter__c(Equipment_Request__c = eReq.Id, RecordtypeId = rectypeId ));
    }
    public void removeLocation(){
        datacenterlst.remove(Integer.valueOf(indextoRemove) - 1);
    }
    
    public pagereference onSave(){
        ApexPages.getMessages().clear();
        Savepoint sp = Database.setSavepoint();
        system.debug(GEvalue);
        eReq.PZen_Access_Requirements_Provided__c  = GEvalue;
        if(datacenterlst.isEmpty() && profname != 'System Administrator' && (eReq.Id == null || ereq.createddate.date() >= date.valueOf('2019-09-10 00:00:00'))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Atleast 1 Datacenter should be added to proceed'));
            return null;
        }
        for(Datacenter__c dc: datacenterlst){
           if(dc.Requested_Hardware_Model__c == 'ZIA – Service Edge 5' || dc.Requested_Hardware_Model__c == 'ZIA Service Edge-5 + LB (>5Gbps only)'){
               if(eReq.PZen_Access_Requirements_Provided__c != 'Yes - acknowledged by customer' && (eReq.Id == null || ereq.createddate.date() >= date.valueOf('2019-09-10 00:00:00'))){
                   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, '\'10GE interfaces requirements been communicated to customer\' field on Equipment Request has to be \'Yes\' if hardware requested is either ZIA – Service Edge 5 or ZIA Service Edge-5 + LB (>5Gbps only)'));
                   return null;
               }
           }
        } 
        try{
            Id accId = null;
            if(eReq.Id == null || !isinApproval){
                upsert eReq;
            }
            if(eReq.Opportunity__c != null){
                Opportunity[] opp = [Select Id, AccountId from Opportunity where Id = :eReq.Opportunity__c];
                if(!opp.isEmpty()){
                    accId = opp[0].AccountId;
                }
            }
            for(Datacenter__c dc: datacenterlst){
                dc.Account__c = accId;
                dc.Equipment_Request__c = eReq.Id;
            }           
            upsert datacenterlst;
        }catch(DmlException ex){
            String err = 'Unable to save record: ' + ex.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, err));
            if(!isedit){
                eReq = eReq.clone(false);
            }
            Database.rollback(sp);
            return null;
        }
        return new PageReference('/'+eReq.Id);
    }
    public pagereference onCancel(){
        if(eReq.Id != null){
            return new PageReference('/'+eReq.Id);
        }else{
            Schema.DescribeSObjectResult r = Equipment_Request__c.sObjectType.getDescribe();
            String keyPrefix = r.getKeyPrefix();
            return new PageReference('/'+ keyPrefix + '/o');
        }
    }

}