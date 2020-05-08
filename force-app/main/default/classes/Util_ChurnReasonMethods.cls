/**
 * @purpose: Class consists of all methods used in opp Loss and Churn forms which are common
 *           and some only for one form. Please refer this method for any methods or function-
 *           lity related to both of those forms and related logic. 
 * @TODO:    More explicit documentation can be done with the methods in this class.
 * 
 * @purpose: Pranjal Singh
 */
global class Util_ChurnReasonMethods {
    
    public static Opportunity oppObj { get; set; }
    
    public Util_ChurnReasonMethods(ApexPages.StandardController controller){
        
    }
    //Method to get Opp Record type by using OppId as reference.
    public static string getOpportunityRecordType(string oppId){
        opportunity oppObj = [Select Id,Name,recordType.Name From opportunity Where Id=:oppId];
        string recordTypeName = '';
        recordTypeName = oppObj.recordType.Name;
        return recordTypeName;
    }
    
   /**  
    *   Method to check the opportunity related products : OpportunityLineitems
    *   with PriceList on opportunity and compare those Products -> Zscaler Product
    *   family to consider if ZIA is present or not.
    */
    global static Boolean isZIApresent(String oppId){
        Boolean isZIAproduct = false;
        Pattern p = Pattern.compile(String.join(new List<String>{'ZIA'},'|'));
        for(OpportunityLineItem opp: [SELECT Id,Product2.Zscaler_Product_Family__c 
                              FROM OpportunityLineItem 
                              WHERE OpportunityId = : oppId]){
                if(opp.Product2.Zscaler_Product_Family__c != null){
                     Matcher match = p.matcher(opp.Product2.Zscaler_Product_Family__c);
                    if(match.find()) { 
                        isZIAproduct = true;
                        break;
                    }
                    else{
                        isZIAproduct = false;
                    }
                 }
                 
        }
        
        return isZIAproduct;
        //return true;
    }
    /** 
    *   Method to check the opportunity related products : OpportunityLineitems
    *   with PriceList on opportunity and compare those Products -> Zscaler Product
    *   family to consider if ZPA is present or not.
    */
    global static Boolean isZPApresent(String oppId){
        Boolean isZPAproduct = false;
        Pattern p = Pattern.compile(String.join(new List<String>{'ZPA'},'|'));
        for(OpportunityLineItem opp: [SELECT Id,Product2.Zscaler_Product_Family__c 
                              FROM OpportunityLineItem 
                              WHERE OpportunityId =: oppId]){
                if(opp.Product2.Zscaler_Product_Family__c != null){
                     Matcher match = p.matcher(opp.Product2.Zscaler_Product_Family__c);
                    if(match.find()) { 
                        isZPAproduct = true;break;
                    }
                    else{
                        isZPAproduct = false;
                    }
                 }
                 
        }
        return isZPAproduct;
        //return true;
    }
    /*
     *  need to put comments here.
     * */
    @RemoteAction
    global static Map<String,String> getProducts(String oppId){
        Map<String,String> prodList = new Map<String,String>();
        String priceListName = [SELECT Price_List__c FROM Opportunity WHERE Id =: oppId LIMIT 1].Price_List__c;
        for(Apttus_Config2__PriceListItem__c obj : [SELECT Id,
                                                           Apttus_Config2__ProductId__r.ProductCode,
                                                           Apttus_Config2__ProductId__r.Name
                                                    FROM Apttus_Config2__PriceListItem__c 
                                                    WHERE Apttus_Config2__PriceListId__c =: priceListName 
                                                    AND Apttus_Config2__ProductId__r.isBundle__c = true 
                                                    AND Apttus_Config2__ProductId__r.IsActive = true]){
                prodList.put(obj.Apttus_Config2__ProductId__r.ProductCode,obj.Apttus_Config2__ProductId__r.Name);
        }  
        if(!prodList.isEmpty() && prodList != null)
            return prodList;
        else
            return null;
    }
    
    @RemoteAction
    global static Boolean isActivePRpresentOnOpp(String oppId){
        Set<String> prStatusSet = new Set<String>();
        prStatusSet.add('Requested');
        prStatusSet.add('In Progress');
        prStatusSet.add('Provisioned');
        
        List<Provisioning_Request__c> countActivePR = [SELECT Id 
                                 FROM Provisioning_Request__c 
                                 WHERE Opportunity__c =: oppId AND Provisioning_Status__c IN: prStatusSet];
        
        //Integer countActivePR = [SELECT count() 
                                 //FROM Provisioning_Request__c 
                                 //WHERE Opportunity__c =: oppId AND Provisioning_Status__c IN: prStatusSet];
        return (countActivePR.size() != 0 && countActivePR != null) ? true :false;
    }
    
    
    @RemoteAction
    global static List<Significant_Customer_Interaction__c> getSCIrecords(String oppId){
        List<Significant_Customer_Interaction__c> sciList = new List<Significant_Customer_Interaction__c>();
        for(Significant_Customer_Interaction__c sciObj : [SELECT Name,Date__c,Organizer__c,Type_of_Interaction__c,
                                                                Primary_Topic_Covered__c
                                                          FROM Significant_Customer_Interaction__c 
                                                          WHERE Opportunity_Name__c =: oppId])
        {
            sciList.add(sciObj);
        }   
        if(sciList != null && !sciList.isEmpty())
            return sciList;
        else
            return null;
    }
    
    @RemoteAction
    global static List<Product2> getDowngradeRecords(){
        List<Product2> sciList = new List<Product2>();
        for(Product2 sciObj : [SELECT Id,Name,productCode,isBundle__c,IsActive 
                               FROM Product2 
                               WHERE isBundle__c = true AND IsActive = true])
        {
            sciList.add(sciObj);
        }   
        if(sciList != null && !sciList.isEmpty())
            return sciList;
        else
            return null;
    }
    
    @RemoteAction
    global static String getSCIname(String sciID){
        String  sciName =  [SELECT Name 
                           FROM Significant_Customer_Interaction__c 
                           WHERE id =: sciID LIMIT 1].Name;
        return sciName != null ? sciName : null;
    }
    
    @RemoteAction
    global static Map<String,String> getSCI(String oppId){
        Map<String,String> mapIDname = new Map<String,String>();
        if(oppId != null){
            for(Significant_Customer_Interaction__c sciObj : [SELECT Name 
                                                              FROM Significant_Customer_Interaction__c 
                                                              WHERE Opportunity_Name__c =: oppId])
            {
                mapIDname.put(sciObj.Name,sciObj.Id);
            }   
        }
        if(mapIDname != null && !mapIDname.isEmpty())
            return mapIDname;
        else
            return null;
    }
    
    /**
     * Common util function to fetch picklist dynamically by taking Object and field name
     * as reference points and returns to page JS vars.
     */
    @RemoteAction    
    global static list<SelectOption> getPicklistValues(String str, String fld){
       
      sObject obj = Schema.getGlobalDescribe().get(str).newSObject();
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType(); 
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         options.add(new SelectOption(a.getLabel(), a.getValue())); 
      }
      return options;
    }
    
    @RemoteAction    
    global static Map<String,String> getSCIRecordTypes(){
       Map<String,String> mapIDname = new Map<String,String>();

      for (recordType a : [Select Id,Name From recordType Where sobjectType='Significant_Customer_Interaction__c'])
      { 
          mapIDname.put(a.Name,a.Id); 
      }
      if(mapIDname != null && !mapIDname.isEmpty())
            return mapIDname;
        else
            return null;
    }    
    
    @RemoteAction    
    global static list<Significant_Customer_Interaction__c>getSearchSCIValues(String oppId){
        list<Significant_Customer_Interaction__c> sciList = new list<Significant_Customer_Interaction__c>();
        /**date DateofMeeting;
        if(meetingDate != null && meetingDate != ''){
            DateofMeeting = date.parse(meetingDate);
        }**/
        String query = 'SELECT id, Name, Date__c, recordType.Name From Significant_Customer_Interaction__c Where ';
        //boolean b=false;
        /**if(recordType != null && recordType != ''){
           query=query+' recordType.Id=:recordType And';
        }
        if(sciName != null && sciName != ''){
            sciName=sciName+'%';
           query=query+' Name LIKE :sciName And';
        }
        if(meetingDate != null && meetingDate != ''){
           query=query+' Date__c=:sciName And';
        }**/
        query = query + ' Opportunity_Name__c =: oppId Limit 100';
        sciList = database.Query(query);
        return sciList;
    }
    
    @RemoteAction
    global static Opportunity getOpp(String oppId) {
        oppObj = [SELECT Id, Name,Account.Name,Geo_Account__c, Opportunity_Territory_Type__c,
                         (select ProductCode from OpportunityLineItems),Amount,
                         StageName,Validation_Stage__c, Owner.Name, Type,Primary_Partner__c
                   FROM Opportunity WHERE Id =: oppId];
        return oppObj;
    }
    
    //public String searchedPrimaryRecordId { get; set; }
    //public String searchedSecondaryRecordId { get; set; }
    //public String searchedSCIId { get; set; }
    //public static list<ResultSet> searchedRecord {get;set;}  
    
    /**@RemoteAction
    global static ResultSet[] getProductRecords(String searchText) {
        //sObject List
        searchedRecord = new list<ResultSet>();
        //SOSL Text should be more then one charecter
        if(searchText.length() >0){
            //SOSL opretion to retrive records of the Account, Lead, Contact, Opportunity, Lead Objects you can add more.
            List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS RETURNING Product2 (Id, Name,ProductCode) Limit 2000];
            //Adding diffrent object's records in sobject list
            for(List<SObject> o:searchList){
                for(SObject s:o){
                    searchedRecord.add(new Util_ChurnReasonMethods.ResultSet(s));
                } 
            }
        }
        return searchedRecord;
    }**/
    
    /**
     *  @purpose: Method is used in trigger to hide/show Submit Churn button
     *  as per the record available on Opp churn related list.
     *  
     *  @param: List of Churn records 
     */
    public static void checkChurnPresentFlag_onOpp(List<Churn__c> ChurnList){
        List<Opportunity> oppList = new List<Opportunity>();
        if(ChurnList != null && !ChurnList.isEmpty()){
            for(Churn__c churnObj : ChurnList){
                Opportunity opp = [SELECT isChurnpresent__c FROM Opportunity 
                                   WHERE Id =: churnObj.Opportunity__c];
                if(opp != null){
                    if(Trigger.isinsert){
                        opp.isChurnpresent__c = true;
                        oppList.add(opp);
                    }
                    else{
                        opp.isChurnpresent__c = false;
                        oppList.add(opp);
                    }
                }
            }
        }
        if(!oppList.isEmpty() && oppList != null)
            Database.update(oppList);
    }
    /*getGlobalDescribed*/
    private static list<Schema.SObjectType> gd{
        get{
            if(gd == null){
                gd = Schema.getGlobalDescribe().values();
            }
            return gd ;
        }set;
    }
    /*Record Wrapper*/
    /**global class ResultSet{
        public String Id {get;set;} 
        public String Name{get;set;}
        public String Description {get;set;}
        public String sObjectName {get;set;}
        public ResultSet(sObject s){
            this.Id = s.Id;
            this.Name = s.get('Name')+'-'+s.get('ProductCode')+'';
            this.Description = s.get('ProductCode')+'';
            this.sObjectName = getsObjectNameById(Id);            
        }       
        global ResultSet(String Id,String Name,String Description){
            this.Id = Id;
            this.Name = Name;
            this.Description = Description;
            this.sObjectName = getsObjectNameById(Id);            
        }
        /*To get object Name by Id*/
        /**private String getsObjectNameById(String sObjectId){            
            if(sObjectId != null && sObjectId.trim() != ''){
                for(Schema.SObjectType objectInstance : Util_ChurnReasonMethods.gd){
                    if(objectInstance.getDescribe().getKeyPrefix() == sObjectId.subString(0,3)){    
                        return objectInstance.getDescribe().getLabel();
                    }
                }
            }
            return null;
        }
    }**/    
}