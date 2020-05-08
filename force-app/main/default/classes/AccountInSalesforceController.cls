public without sharing class AccountInSalesforceController {
    
    @AuraEnabled
    public static string redirectSCI( string accountId){
        string retValue = '';
        string patchTeamId = ''; 
        string opportunityId = ''; 
        account accountRecord = [Select Id,Name, Sales_Territory__c, SBQQ__DefaultOpportunity__c,
                                                SBQQ__DefaultOpportunity__r.Patch__c 
                                                From 
                                                Account 
                                                Where 
                                                Id =: accountId];
        if(accountRecord != null && accountRecord.SBQQ__DefaultOpportunity__c != null){
            opportunityId = accountRecord.SBQQ__DefaultOpportunity__c;
            Patch__c patchRecord = [SELECT PatchTeam__c FROM Patch__c WHERE Id =: accountRecord.SBQQ__DefaultOpportunity__r.Patch__c];
            patchTeamId = patchRecord.PatchTeam__c;
        }
        else{
          patchTeamId =  accountRecord.Sales_Territory__c;
        }
        if(patchTeamId == null){
            patchTeamId = '';
        }
        retValue = 'accountId='+accountId+'&opportunityId='+opportunityId+'&patchTeamId='+patchTeamId+'&edit=false&campaignId=&leadId=&dealRegId=';
        return retValue;
    }
    
         
   	 @AuraEnabled
	 public static list<fieldsListWrapper > fetchAccount(String searchKeyWord, string selectedgeo, string selectedRegion, string selectedindustry,string ZIAString,string ZPAString,string nameDrop) {
	    
	    List <string> accidList = new List <string> ();
	    list<Account> lstOfAccount = new list<Account>();
	     String Dynquery='select id,Name,Type,Area_Director__r.Name,BillingCountry,Sales_Territory__c,Industry';
        Dynquery=Dynquery+',Owner.Name, Area_Director__r.Full_Name__c,Area__c,No_of_Employees_Users__c from Account where ';
        
        
        boolean isExit = false;
        if(searchKeyWord != null && searchKeyWord != '' ){
            String searchKey = '%'+ searchKeyWord + '%';
            Dynquery = Dynquery+'Name LIKE:searchKey';
            isExit = true;
        }
        
        if(selectedgeo != null && selectedgeo != '' ){
            string searchgeo = selectedgeo + '%';
            if(isExit == true){
                Dynquery = Dynquery+' AND Geo__c LIKE:searchgeo';
            }
            else{
                Dynquery = Dynquery+'Geo__c LIKE:searchgeo';
            }
            isExit = true;
        }
        
        if(selectedRegion != null && selectedRegion != '' ){
            string searchRegion = selectedRegion + '%';
            if(isExit == true){
                Dynquery = Dynquery+' AND Region__c LIKE:searchRegion';
            }
            else{
                Dynquery = Dynquery+'Region__c LIKE:searchRegion';
            }
            isExit = true;
        }
        
        if(selectedindustry != null && selectedindustry != '' ){
             //string searchindustry = '%'+ selectedindustry + '%';
            if(isExit == true){
            Dynquery = Dynquery+' AND Industry =:selectedindustry';
            }
            else{
                Dynquery = Dynquery+'Industry =:selectedindustry';
            }
            isExit = true;
        }
         if(ZPAString != null && ZPAString != '' ){
             //Dynquery = Dynquery+' And ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
             if(isExit == true){
             Dynquery = Dynquery+' AND ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
             }
             else{
                 Dynquery = Dynquery+'ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
             }
             isExit = true;
         }
         
         if(ZIAString != null && ZIAString != '' ){
            // Dynquery = Dynquery+' And ZIA_Use_Cases__c includes (\''+ZIAString+'\')';
             if(isExit == true){
                 Dynquery = Dynquery+' AND ZIA_Use_Cases__c includes (\''+ZIAString+'\')';
             }
             else{
                 Dynquery = Dynquery+'ZIA_Use_Cases__c includes (\''+ZIAString+'\')';
             }
             isExit = true;
         }
         
         if(nameDrop != null && nameDrop != '' ){
             //Dynquery = Dynquery+' And ZPA_Use_Cases__c includes (\''+ZPAString+'\')';
             if(isExit == true){
             Dynquery = Dynquery+' AND Namedrop__c =:nameDrop';
             }
             else{
                Dynquery = Dynquery+'Namedrop__c =:nameDrop'; 
             }
         }
        
        Dynquery = Dynquery +' Limit 200' ;
         system.debug('-----------'+selectedindustry); 
         system.debug('-----------'+ZIAString); 
		system.debug('-----------'+ZPAString);   
         system.debug('-----------'+Dynquery);
        lstOfAccount=Database.query(Dynquery);
	   /* List <Account> lstOfAccount = [Select Id, Name, Type, Owner.Name,
	                                            Area_Director__r.Name,
	                                            Area_Director__r.Full_Name__c,
	                                            BillingCountry,
	                                            Sales_Territory__c,
	                                            Industry
	                                            from Account
									            where Name LIKE: searchKey AND Name != null AND Name != '' limit 200];*/
	    for(Account acc :lstOfAccount){
	        accidList.add(acc.id);
	    }
        
        list<Access_Request__c> accRequestList = [Select Id, 
                	                                Account__c,
                	                                Requested_From__c
                	                                FROM 
                	                                Access_Request__c 
                	                                WHERE 
                	                                Account__c IN: accidList 
                	                                AND 
                	                                Requested_From__c =: userinfo.getUserId()
                	                                AND
                	                                Request_Status__c = 'Requested'];
	                                
	                                
	    Map<Id,List<Access_Request__c>> accAccessMap = new Map<Id,List<Access_Request__c>>();
	    
        for(Access_Request__c accReq : accRequestList){
           
            if(!accAccessMap.containsKey(accReq.Account__c)){
                accAccessMap.put(accReq.Account__c, new list<Access_Request__c>());
            }
            accAccessMap.get(accReq.Account__c).add(accReq);
        }
	      
	    //List < UserRecordAccess> lstOfUserRecordAccess =[ SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId IN : accidList Limit 200];
	    List <UserRecordAccess> lstOfUserRecordAccess = AccountInSalesforceHelper.getAccessRecords(accidList);
	    Map<Id,UserRecordAccess> userrecmap = new Map<Id,UserRecordAccess>();
	 
	    for(UserRecordAccess userrec : lstOfUserRecordAccess){
	        if(userrec.HasReadAccess != false){
	            userrecmap.put(userrec.RecordId,userrec );
	        }
        }
        
        list<fieldsListWrapper > wrapList = new list<fieldsListWrapper>();
        for(account acc : lstOfAccount){
            fieldsListWrapper rec = new fieldsListWrapper();
            if(userrecmap.get(acc.Id) != null ){  
                rec.isChecked = true; 
            }
            else{ 
                rec.isChecked = false;
                if(accAccessMap.containsKey(acc.id)){
                    if(accAccessMap.get(acc.Id).size() > 0 ){ 
                        rec.Issubmitted = true; 
                    }
                    else{ 
                        rec.Issubmitted = false; 
                    }
                }
            }
            rec.Accrec = acc;
            wrapList.add(rec);
        }
        return wrapList;
    }
	 
    @AuraEnabled
	public static string createAccountAccessRequest(String recid, string JustificationRequestvalue) {
	    string requestReponse;
        Id AccountAccessRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();
	    List <UserRecordAccess> lstOfUserRecordAccess = [SELECT RecordId,HasReadAccess, 
	                                                            HasEditAccess 
	                                                            FROM 
	                                                            UserRecordAccess 
	                                                            WHERE 
	                                                            UserId =: userinfo.getUserId() 
	                                                            AND 
	                                                            RecordId =: recid];
        
        Account acct = [Select Id, Name from Account where Id = :recid limit 1];
        
        //String subject = 'Request ' +acct.Name+' account access for '+ userinfo.getName();
	    List<Access_Request__c> AccessRequestList = [Select Id, 
	                                Account__c
	                                FROM 
	                                Access_Request__c 
	                                WHERE 
	                                Account__c =: recid 
	                                AND 
	                                Requested_From__c =: userinfo.getUserId()
	                                AND 
	                                Request_Type__c = 'Account Access'
	                                AND
	                                Request_Status__c != 'Revoked'];
	    if(AccessRequestList.size() > 0){ 
	        requestReponse = 'Request Access Case Already Submitted'; 
	    }
	    else{
	        string custlabel = label.Case_Owner_Id;
	        if(AccessRequestList.size() == 0){
	            List<User> currentUser = [SELECT Id, ManagerId FROM User WHERE Id =: userinfo.getUserId()];
	            if(!currentUser.isEmpty()){
    	            
    	            boolean inSameTerritory = false;
    	            List<Account> accounts = [SELECT Id, 
    	                                                Sales_Territory__c 
    	                                                FROM 
    	                                                Account 
    	                                                WHERE 
    	                                                Id =: recid];
    	            if(!accounts.isEmpty()){
    	                List<PatchTeamMember__c> patchTeamMember = [SELECT Id, 
    	                                                        User__c
    	                                                        FROM 
    	                                                        PatchTeamMember__c
    	                                                        WHERE
    	                                                        User__c =: currentUser[0].ManagerId
    	                                                        AND
    	                                                        PatchTeam__c =: accounts[0].Sales_Territory__c];
    	               if(!patchTeamMember.isEmpty()){
    	                   inSameTerritory = true;
    	               }
    	            }
    	            
    	            Id accountAccess = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Account Access').getRecordTypeId();
                    Access_Request__c accRecord = new Access_Request__c();
                    accRecord.Account__c = recid; 
                    accRecord.Justification__c = JustificationRequestvalue;
                    accRecord.Object_Type__c = 'Account';
                    accRecord.Requested_From__c = currentUser[0].Id;
                    accRecord.Request_Type__c = 'Account Access';
                    accRecord.Request_Status__c = 'Requested';
                    accRecord.RecordTypeId = accountAccess;
                    accRecord.Approver__c = currentUser[0].ManagerId;
                    accRecord.Requested_Date__c = system.today();
                    if(inSameTerritory){
                        accRecord.Same_Territory__c = true;
                    }
                    else{
                        accRecord.Same_Territory__c = false;
                    }
                    insert accRecord;
                    
                    Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitting request for approval.');
                    req.setObjectId(accRecord.id);
                    requestList.add(req);
                    if(!requestList.isEmpty()){
                        Approval.ProcessResult[] result = Approval.process(requestList);
                    }
                }
                requestReponse = 'Request Access Submitted Successfully';
    	        /*Case caseRec = new Case();
    	        caseRec.AccountId = recid;
                caseRec.OwnerId = custlabel;
    	        caseRec.Submitted_By_Name__c = userinfo.getUserId();
    	        caseRec.status = 'New';
    	        caseRec.Subject = 'Salesforce Account Access Request : Request ' +acct.Name+' account access for '+ userinfo.getName();
    	        caseRec.Type = 'Feature Request';
    	        caseRec.Description = 'Request ' +acct.Name+' account access for '+ userinfo.getName();
    	        caseRec.JustificationforRequest__c = JustificationRequestvalue ;
    	        insert caseRec;
    	        requestReponse = 'Request Access Submitted Successfully';*/
	        }
	    }
	    return requestReponse;
    }
    
    @AuraEnabled
	public static moreInfoResponse moreInfoData(String accrecid) {
	    
	    moreInfoResponse respRec = new moreInfoResponse();
	    Decimal TotalZIAACV = 0;
    	Decimal TotalZPAACV = 0;
    	Date PartnerCloseDate;
	    Account AccountRecs = [select id, 
	                                                Name,
	                                                Type,
	                                                Owner.Name,
	                                                Sales_Territory__c, 
	                                                Area_Director__r.Name,
	                                                Area_Director__r.Full_Name__c,
	                                                Channel_Manager__r.Full_Name__c,
	                                                Lead_Development__c,
	                                                CSM_Name_New__r.Full_Name__c,
	                                                //CSM_Name__c,
	                                                Sales_Territory__r.Name,
	                                                Account_Manager__r.Full_Name__c,
	                                                Customer_Advocate__r.Full_Name__c,
	                                                Sales_Engineer__r.Full_Name__c,
	                                                TAM_Name__c,
	                                                ZIA_Use_Cases__c,
	                                                ZPA_Use_Cases__c,
	                                                Industry,
	                                                Market_Segment__c,
	                                                Prospect_Type__c,
	                                                TAM_Name_New__r.Name,
	                                                TAM_Name_New__r.Full_Name__c,
	                                                No_of_Platform_Seats__c,
	                                                Users_ZPA_Platform__c,
	                                                Namedrop__c,
	                                                First_Contract_Date__c,
	                                                First_ZPA_Contract_Date__c,
	                                                Total_ZIA_Premium_Support_ACV__c,
	                                                Total_ZPA_Premium_Support_ACV__c,
	                                                BillingCountry
	                                                from Account
									                where id =:accrecid limit 1];
									                
		if(AccountRecs.Prospect_Type__c == 'Pipeline' || AccountRecs.Prospect_Type__c == 'POC'){
            List<Opportunity> oppList = [Select Id,Total_ZIA_ACV__c,Total_ZPA_ACV__c,CloseDate from Opportunity Where Type = 'New Business'and isClosed  = false and AccountID =: accrecid ORDER BY CloseDate ASC];
		                                         
		                                        
    		
    	    for(Opportunity oppRec : oppList){
    	        if(oppRec.Total_ZIA_ACV__c != null){ TotalZIAACV = TotalZIAACV + oppRec.Total_ZIA_ACV__c; }
    	        if(oppRec.Total_ZPA_ACV__c != null){ TotalZPAACV = TotalZPAACV + oppRec.Total_ZPA_ACV__c; }
    	        if(PartnerCloseDate == null){ PartnerCloseDate = oppRec.CloseDate; }
    		}
		}
		respRec.mAccountRecs = AccountRecs;
		respRec.mTotalZIAACV = TotalZIAACV;
		respRec.mTotalZPAACV = TotalZPAACV;
		respRec.mPartnerCloseDate = PartnerCloseDate;
		return respRec;
	    
	}

    @AuraEnabled
    public static List <String> getAccountIndustryoptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
         system.debug('fld --->' + fld);
         List < String > allOpts = new list < String > ();
         
         Schema.sObjectType objType = objObject.getSObjectType();
         Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
         map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
         
         list < Schema.PicklistEntry > values =
          fieldMap.get(fld).getDescribe().getPickListValues();
         
         for (Schema.PicklistEntry a: values) {
          allOpts.add(a.getValue());
         }
         system.debug('allOpts ---->' + allOpts);
         allOpts.sort();
         return allOpts;
        }
	
    
    public class moreInfoResponse{
        @AuraEnabled public Account mAccountRecs{get;set;}
        @AuraEnabled public Decimal mTotalZIAACV{get;set;}
        @AuraEnabled public Decimal mTotalZPAACV{get;set;}
        @AuraEnabled public Date mPartnerCloseDate{get;set;}
    }
    
    public class fieldsListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Account Accrec{get;set;}
        @AuraEnabled public boolean Issubmitted{get;set;}
    }
    
    @AuraEnabled
    public static pickListWrap getPickListData(){
        pickListWrap pickListWrapRecord = new pickListWrap();
        pickListWrapRecord.geo = getPicklistValues('PatchTeam__c','Theater__c');
        pickListWrapRecord.Region = getPicklistValues('PatchTeam__c','Region__c');
        return pickListWrapRecord;
    }
    
     public class pickListWrap{
        @AuraEnabled public list<pickList> geo{get;set;} 
        @AuraEnabled public list<pickList> Region{get;set;} 
    }
    
    public class pickList{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string value{get;set;} 
        public pickList(string label,string value){
            this.label = label;
            this.value = value;
        }
    }
    
    public static list<pickList> getPicklistValues(String str, String fld){
        sObject obj = Schema.getGlobalDescribe().get(str).newSObject();
        list<pickList> options = new list<pickList>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){ 
            options.add(new pickList(string.valueOf(a.getLabel()), string.valueOf(a.getValue()))); 
        }
        return options;
    }

}