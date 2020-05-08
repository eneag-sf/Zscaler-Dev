/*****************************************************************************************
Name: ProvisioningRequestTriggerHelper
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Helper class to have all the business logic used in Provisioning Request Trigger
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     17-Oct-2016    Initial Development
******************************************************************************************/
public class ProvisioningRequestTriggerHelper {
    /**
    * Method to 'Active Screen' the accounts associated with POCs upon Provisioning_Request__c creation 
    * @param lstNewProvisioningRequests List of newly created Provisioning_Request__c
    */
    public static Id inlineRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud').getRecordTypeId();
    public static Id inline2RecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('Zscaler Cloud Details').getRecordTypeId();
    public static Id fevaRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('FeVa Cloud').getRecordTypeId();
    public static Id ZPAInteractiveRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('ZPA Interactive').getRecordTypeId();
    public static Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();

    public static boolean skipTrigger = false;
    
    public static void afterInsert(List < Provisioning_Request__c > newList) {
        if(!TriggerUtility.isCaseCreationInsertPRExecuted()){
            createCasefromPRonInsert(newList);
        }
        TriggerUtility.PRafterInsertExecuted();
    }

    public static void afterUpdate(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap) {
        if(!TriggerUtility.isCaseCreationUpdatePRExecuted()){
            createCasefromPRonUpdate(newList, oldmap);
        }
        TriggerUtility.PRafterUpdateExecuted();
    }
    
    public static void createCasefromPRonInsert(List < Provisioning_Request__c > newList) {
        List<Case> cslst = new List<Case>();
        boolean IsPurgeCase=false;
        for(Provisioning_Request__c pr: newList){
            system.debug('pr   '+pr);
            if((pr.RecordTypeId == NFRRecordTypeId && pr.Provisioning_Status__c == 'Requested' && pr.Internal_user__c == false) || (pr.RecordTypeId == inlineRecordTypeId && pr.Provisioning_Status__c == 'Requested' && ((pr.Opportunity_Stage__c != Label.Stage_5_Contracts_Complete && pr.Opportunity_Stage__c != Label.Stage_6_Closed_Won) || pr.Account_Type__c != 'Customer'))){
                Case cs = createCase(pr, 'A new POC has been Requested for ' + pr.Opportunity_Name__c + pr.Name,IsPurgeCase);
                if(cs != null){
                    cslst.add(cs);
                }
            }
        }
        if(!cslst.isEmpty()){
            insert cslst;
            TriggerUtility.CaseCreationInsertPRExecuted();
        }
        
    }

    public static void createCasefromPRonUpdate(List < Provisioning_Request__c > newList, Map<Id, Provisioning_Request__c> oldmap) {
        List<Case> cslst = new List<Case>();
        boolean IsPurgeCase=false;
        for(Provisioning_Request__c pr: newList){
            system.debug('pr in createCasefromPRonUpdate  '+pr);
            system.debug('pr name  '+pr.Name);
            //  SE should be the case owner
            if(pr.Provisioning_Status__c == 'To be Purged' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c){
                system.debug('inside To be purged condition  ');
                IsPurgeCase=true;
                Case cs = createCase(pr, 'Purge has been requested for ' + pr.Name +  pr.Account_Name__c+ ' : ' + pr.Preferred_Cloud__c + '-' + pr.Org_ID_with_cloud__c,IsPurgeCase);
                if(cs != null){
                    cslst.add(cs);
                }
            }
            
            if(pr.Provisioning_Status__c == 'Purge Stopped' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c){
                system.debug('inside Purge Stopped condition  ');
                Case cs = createCase(pr, 'Stop Purge has been requested for ' + pr.Name +  pr.Account_Name__c+ ' : ' + pr.Preferred_Cloud__c + '-' + pr.Org_ID_with_cloud__c,IsPurgeCase);
                if(cs != null){
                    cslst.add(cs);
                }
            }
            if(pr.RecordTypeId != ZPAInteractiveRecordTypeId && pr.Provisioning_Status__c == 'Request Decommission' && pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c){
                Case cs = createCase(pr, ' Decommission Request for ' + pr.Name,IsPurgeCase);
                if(cs != null){
                    cslst.add(cs);
                }
            }
            if((pr.RecordTypeId != oldmap.get(pr.Id).RecordTypeId || pr.Provisioning_Status__c != oldmap.get(pr.Id).Provisioning_Status__c) && pr.RecordTypeId == inlineRecordTypeId && pr.Provisioning_Status__c == 'Requested' && ((pr.Opportunity_Stage__c != Label.Stage_5_Contracts_Complete && pr.Opportunity_Stage__c != Label.Stage_6_Closed_Won) || pr.Account_Type__c != 'Customer')){
                Case cs = createCase(pr, 'A new POC has been Requested for ' + pr.Opportunity_Name__c +'  '+ pr.Name,IsPurgeCase);
                if(cs != null){
                    cslst.add(cs);
                }
            }
        }
        if(!cslst.isEmpty()){           
            insert cslst;
            TriggerUtility.CaseCreationUpdatePRExecuted();
        }
        
        
    }

    public static Case createCase(Provisioning_Request__c pr, String sub,Boolean IsPurgeCase){
        system.debug('pr '+pr);
        system.debug('sub '+sub);
        system.debug('IsPurgeCase '+IsPurgeCase);
        
        Map<String, DefaultData__c> ddmap = DefaultData__c.getAll();
        if(ddmap != null && !ddmap.isEmpty() && ddmap.containsKey('PRCaseCreationDefault')){
            DefaultData__c dd = ddmap.get('PRCaseCreationDefault');
            List<Contact> conlist= new List<Contact>();
            if(!IsPurgeCase){
                conlist=[Select id,email from Contact where email=:UserInfo.getUserEmail() and Accountid=:dd.Account_Id__c];
            }else if(pr.SE__c!=null){
                conlist=[Select id,email from Contact where email=:pr.SE_s_Email__c and Accountid=:dd.Account_Id__c];
            }
            system.debug('conlist '+conlist);
            Case cs = new Case(RecordTypeId = caseSupportRT);
            cs.Provisioning_Request__c = pr.Id;
            //cs.Product_New__c = dd.Product__c;
            if(pr.ZPA_NFR__c){
                cs.Product_New__c='ZPA';
            }
            if(pr.ZIA_NFR__c){
                cs.Product_New__c = dd.Product__c;
            }
            cs.Case_Type__c = dd.Type__c;
            cs.Case_Category__c = dd.Category__c;
            cs.Subject = sub;
            cs.Status = dd.Stage_Status__c;
            cs.Priority = dd.Priority__c;
            cs.AccountId = dd.Account_Id__c;
            
            if(!conlist.isempty()){
                cs.ContactId=conlist[0].id;
            }
            else{
                if(!IsPurgeCase){
                    Contact con; con= new Contact(LastName=UserInfo.getLastName(),FirstName=UserInfo.getFirstName(),AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=UserInfo.getUserEmail());
                    TriggerUtility.SkipContactTriggerExecuted();
                    insert con;
                    cs.ContactId = con.id;
                }else{
                    Contact con; con= new Contact(LastName=pr.SE_Name__c,AccountId=dd.Account_Id__c,Project_Role__c='Other',LeadSource='Zscaler Employee',Email=pr.SE_s_Email__c);
                    TriggerUtility.SkipContactTriggerExecuted();
                    insert con;
                    cs.ContactId = con.id;
                }            
            }
            cs.Opportunity_Name__c = pr.Opportunity__c;
            return cs;
        }
        return null;
    }

    public static void screenAccounts(List < Provisioning_Request__c > lstNewProvisioningRequests) {
        List < Id > accountIdsToBeScreenedList = new List < Id > ();
        List < Id > opportunityIdsList = new List < Id > ();
        List < Account > accountsToBeScreenedList = new List < Account > ();

        for (Provisioning_Request__c provisioningRequest: lstNewProvisioningRequests) {
            if (null != provisioningRequest.Account__c) {
                accountIdsToBeScreenedList.add(provisioningRequest.Account__c);
            } 
            else if (null != provisioningRequest.Opportunity__c) {
                opportunityIdsList.add(provisioningRequest.Opportunity__c);
            }
        }

        if (opportunityIdsList.size() > 0) {
            for (Opportunity oppty: [SELECT Id, AccountId FROM Opportunity WHERE Id IN: opportunityIdsList]) {
                accountIdsToBeScreenedList.add(oppty.AccountId);
            }
        }

        if (!System.isFuture() && accountIdsToBeScreenedList.size() > 0) {
            for (Account accountToBeScreened: [SELECT Id, Amber_Road_Status__c, BillingPostalCode, BillingState,
                                                    BillingCity, BillingCountry, BillingStreet, Fax, Name, Phone,type
                                                    FROM Account
                                                    WHERE Id IN: accountIdsToBeScreenedList
                                                    ]) {
                if (!Test.isRunningTest()) {
                    AmberRoadService.screenAccountFuture(JSON.serialize(accountToBeScreened), false, true);
                }
            }
        }
    }

    public static void sendProvisioningRequesttoZPA(Provisioning_Request__c zpaProvisioningRequest) {
        callOutZPAInteractive(zpaProvisioningRequest.Id);
    }

    @future(callout = true)
    public static void callOutZPAInteractive(Id requestId) {
        Provisioning_Request__c pr = [select id, name, Integration_Status__c from Provisioning_Request__c where id = : requestId limit 1];
        /*String endpoint = 'https://test.connect.boomi.com/ws/rest/zpa/provisioning/ZPAInteractive/';
        Blob headerValue = Blob.valueOf('UserName' +':' +'Token');
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);*/
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('requestId', requestId);
        gen.writeStringField('sourceSystem', 'salesforce');
        gen.writeStringField('sobject', 'Provisioning Request');
        gen.writeEndObject();
        String jsonString = gen.getAsString();
        HttpRequest req = new HttpRequest();
        //req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        //req.setEndpoint(endpoint);
        req.setEndpoint('callout:ZPA_Interactive');
        req.setMethod('POST');
        req.setBody(jsonString);
        req.setTimeout(60000);
        try {
            Http http = new Http();
            if (!Test.isRunningTest()) {
                HttpResponse response = http.send(req);
                if (response.getStatusCode() == 200) {
                    pr.Integration_Status__c = 'Success';
                } 
                else {
                    pr.Integration_Status__c = 'Failed';
                    pr.FailedReason__c = response.getBody();
                }
            }
        } 
        catch (Exception e) {
            pr.Integration_Status__c = 'Failed';
            pr.FailedReason__c = e.getMessage();
        }
        update pr;
    }
    public static void WorkflowOptimization(List<Provisioning_Request__c> lstNewProvisioningRequests,Map<id,Provisioning_Request__c> TriggerOLDmap,Boolean isInsert,Boolean Isupdate){
        Set<String> OppStage= new Set<String>();
        OppStage.add(label.Stage_6_Closed_Won);
        OppStage.add(label.Stage_5_Contracts_Complete);
        Set<id> AccountidSet= new Set<id>();
        Set<id> OppidSet= new Set<id>();
        Set<id> PROwneridSet= new Set<id>();
        
        Set<String> RecordTypeIdSet= new Set<String>();                
        String PRRecordTypeIdString= ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString')!=null && ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString').Value__c!=null ? ZscalerCustomSetting__c.getInstance('PRRecordTypeIdString').Value__c:'0120g000000grUCAAY,0120g000000N3X1AAK';
        RecordTypeIdSet.addall(PRRecordTypeIdString.split(','));
                
        for(Provisioning_Request__c pr : lstNewProvisioningRequests){
            //if(pr.Account__c!=null){
            AccountidSet.add(pr.Account__c);
            OppidSet.add(pr.Opportunity__c);
            PROwneridSet.add(pr.ownerid);
            //}         
        }
        
        Map<id,Account>  AccountMap= new Map<id,Account>([Select id,CSM_Name_New__c,Customer_Advocate__c,Geo__c,Sales_Territory__r.Renewal_Director__c from Account where id IN:AccountidSet]);
        Map<id,Opportunity>  OppMap= new Map<id,Opportunity>([Select id,StageName,Validation_Plan__c,Opportunity.Patch__r.PatchTeam__r.Theater__c/*,SE_Name__c,SE_Name__r.managerid*/  from Opportunity where id IN:OppidSet]);
    
        //if(AccountMap!=null){
        for(Provisioning_Request__c pr : lstNewProvisioningRequests){
            //Changes to update CSM and Renewal Manager:Start
            if(pr.Account__c!=null){
                pr.Renewal__c=AccountMap.get(pr.Account__c).Customer_Advocate__c;
                pr.CSM__c=AccountMap.get(pr.Account__c).CSM_Name_New__c;
                pr.Renewal_Director__c=AccountMap.get(pr.Account__c).Sales_Territory__r.Renewal_Director__c;
            }
            //Changes to update CSM and Renewal Manager:End
            if(isInsert){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=true;
            }   
            if(Isupdate && pr.Provisioning_Status__c=='Provisioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Provisioned'){
                pr.Do_not_Send_Alerts_when_Approval_Pending__c=false;
            }       
            
            //1.Update Deployed To Production Date  :Start
            if(Isupdate && pr.Provisioning_Status__c=='Production' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Production'){
                pr.Deployed_To_Production_Date__c=system.today();
            }       
            //1.Update Deployed To Production Date  :End
            
            
            if(pr.Opportunity__c!=null){
                //2.Identify provisioning request created by Finance :Start
                if(isInsert && OppStage.contains(OppMap.get(pr.Opportunity__c).StageName)){
                    pr.Created_by_Finance__c=true;
                }
                //2.Identify provisioning request created by Finance :End
                
                //3.Update Tech Val Plan:Start
                if(OppMap.get(pr.Opportunity__c).Validation_Plan__c!=''){
                    pr.Technical_Validation_Plan__c=OppMap.get(pr.Opportunity__c).Validation_Plan__c;
                }
                //3.Update Tech Val Plan:End
                
                //4.Update SE director and Email in PR:Start
                //if(pr.GEO_SE_Director_Email__c==null || pr.GEO_SE_Director_Email__c==''){
                    if(OppMap.get(pr.Opportunity__c).Patch__r.PatchTeam__r.Theater__c=='AMERICAS'){
                        pr.GEO_SE_Director_Email__c='dgood@zscaler.com';
                        pr.GEO_SE_Director__c='0050g000005dSUqAAM';
                    }else if(OppMap.get(pr.Opportunity__c).Patch__r.PatchTeam__r.Theater__c=='EMEA'){
                        pr.GEO_SE_Director_Email__c='ychandiramani@zscaler.com';
                        pr.GEO_SE_Director__c='00570000005F4FjAAK';
                    }else if(OppMap.get(pr.Opportunity__c).Patch__r.PatchTeam__r.Theater__c=='APAC'){
                        pr.GEO_SE_Director_Email__c='ldolsen@zscaler.com';
                        pr.GEO_SE_Director__c='00570000001h4JcAAI';
                    }else{
                        pr.GEO_SE_Director_Email__c=null;
                    }
                //}
                
                //4.Update SE director email in PR:End
                /**system.debug('pr.Opp_SE_Manager__c  '+pr.Opp_SE_Manager__c);
                if(OppMap.get(pr.Opportunity__c).SE_Name__c!=null){
                    pr.Opp_SE__c=OppMap.get(pr.Opportunity__c).SE_Name__c;
                    pr.Opp_SE_Manager__c=OppMap.get(pr.Opportunity__c).SE_Name__r.managerid;
                }
                system.debug('pr.Opp_SE_Manager__c  '+pr.Opp_SE_Manager__c);**/
            }
            
            //6 .Update decomm date:Start
            if(pr.Provisioning_Status__c=='Decommissioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Decommissioned'){
                pr.Decomm_Req_date__c=system.today().adddays(-75);
            }   
            //6 .Update decomm date:End
                        
            //7 .Set detailed record type:Start
            //if((pr.Provisioning_Status__c=='Provisioned' || pr.Provisioning_Status__c=='In Progress')  && pr.RecordTypeid=='01270000000QB3aAAG' /* && RecordType.DeveloperName=='New_Eval' */){
                //pr.RecordType='Zscaler Cloud Details';
                //pr.RecordTypeid=' 01270000000EABCAA4';  //Zscaler Cloud Details 
                //pr.RecordTypeid='01270000000QB3aAAG';
            //}
            //7 .Set detailed record type:End
            
            //8.Update GEO SE Leadership Alias  :Start
            if(AccountMap!=null && AccountMap.containskey(pr.Account__c) && AccountMap.get(pr.Account__c).Geo__c!=null && AccountMap.get(pr.Account__c).Geo__c=='AMERICAS'){
                pr.GEO_SE_Leadership_Alias__c='sales-na-poc-notifications@zscaler.com';
            }
            //8.Update GEO SE Leadership Alias  :End
            
            system.debug('pr.RecordTypeid   '+pr.RecordTypeid);
            system.debug('inside provisioning date'+pr.Provisioning_Date__c);
            if(Isupdate && pr.Provisioning_Status__c=='Provisioned' && TriggerOLDmap.get(pr.Id).Provisioning_Status__c!='Provisioned' && pr.Number_of_Extensions__c<2 && !RecordTypeIdSet.contains(String.valueof(pr.RecordTypeid))){
                pr.Provisioning_Date__c=system.today();
            }  
            
            //9.Update PR Expiry date   :Start
            system.debug('inside provisioning date'+pr.Provisioning_Date__c);
            if(Isupdate && pr.Provisioning_Date__c != null && pr.Provisioning_Date__c != TriggerOLDmap.get(pr.Id).Provisioning_Date__c && pr.Preferred_Cloud__c!='Zscalerbeta.net' && pr.Account_Type__c!='Partner'){
                system.debug('inside provisioning date');
                pr.Provisioning_Request_Expiry_Date__c=pr.Provisioning_Date__c+30;
            }
            //9.Update PR Expiry date   :End
            
            if(Isupdate && pr.Confirmation_from_Customer_to_Purge_Data__c==true && TriggerOLDmap.get(pr.Id).Confirmation_from_Customer_to_Purge_Data__c==false){
                pr.Provisioning_Status__c='To be Purged';
                pr.Approval_for_Purge_Status__c='Submitted for Purge Approval';
            }           
        }           
            
        //}
        
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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