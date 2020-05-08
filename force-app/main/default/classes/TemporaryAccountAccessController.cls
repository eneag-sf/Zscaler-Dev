public without sharing class TemporaryAccountAccessController {
    
    @AuraEnabled
    public static user getCurrentUserRecord(){
        Id loggedUser = UserInfo.getUserId();
        user userRecord = [Select id,Name,Level__c from user where Id=:loggedUser];
        return userRecord;
    }
        
    @AuraEnabled
    public static string getCoverageAccessFromProfile() {
        Id loggedUser = UserInfo.getUserId();
        string coverageAccess = '';
        string profileName = 'System Administrator';
        string userLevel = '';
        List<User> userLst = [SELECT Id, Profile.Name,Level__c FROM User WHERE Id =: loggedUser];
        if(userLst.size()>0){
            profileName=userLst[0].Profile.Name;
            userLevel=userLst[0].Level__c;
        }
        
        if((userLevel != '' && userLevel == 'Rep') && ( profileName == 'Core Sales - Sales Ops' || profileName == 'Core Sales')){
           coverageAccess = 'Vacation Coverage';
        }
        else if((userLevel != '' && userLevel != 'Rep') && ( profileName == 'Core Sales - Sales Ops' || profileName == 'Core Sales')){
           coverageAccess = 'Both';
        }
		else if(profileName == 'Core  Sales - Channel' || profileName == 'Core Sales - CSM' || profileName == 'Core Sales - Deal Desk' || profileName == 'Core Sales - LDR' || profileName == 'Core Sales - Renewals' || profileName == 'Core Sales - SE'){
            coverageAccess = 'Vacation Coverage';
        }
        return coverageAccess;
    }
    
    @AuraEnabled
    public static List<picklistWrap> getAreaListWrap(){
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        Id loggedUser = UserInfo.getUserId();
        List<User> userLst = [SELECT Id, Profile.Name FROM User WHERE Id =: loggedUser];
        List<picklistWrap> areaList = new List<picklistWrap>();
        if(userLst[0].Profile.Name == 'System Administrator'){
            groupedResults = [SELECT Area__c, COUNT(Id) FROM PatchTeam__c GROUP BY Area__c ORDER BY Area__c ASC];
        }
        else{
            groupedResults = [SELECT Area__c, COUNT(Id) 
                                        FROM 
                                        PatchTeam__c 
                                        WHERE 
                                        Area_Director__c =: loggedUser 
                                        OR 
                                        Regional_VP__c =: loggedUser 
                                        GROUP BY 
                                        Area__c 
                                        ORDER BY Area__c ASC];
        }
        for(AggregateResult rec:groupedResults){
            if(rec.get('Area__c') != null && rec.get('Area__c') != ''){
                picklistWrap pickWrap = new picklistWrap();
                pickWrap.label = string.valueOf(rec.get('Area__c'));
                pickWrap.value = string.valueOf(rec.get('Area__c'));
                areaList.add(pickWrap);
            }
        }
        return areaList;
    }
    
    @AuraEnabled
    public static List<picklistWrap> getTerritorieWrap(string selectedArea){
        //getting Territories  from patch team
        List<picklistWrap> territoriesList = new List<picklistWrap>();
        List<PatchTeam__c> patchTeamList = [SELECT Id, Name, Account_Manager__c, Account_Manager__r.Name, 
                                                            Account_Manager__r.Level__c 
                                                            FROM 
                                                            PatchTeam__c 
                                                            WHERE 
                                                            Account_Manager__r.Level__c != 'Rep' 
                                                            AND 
                                                            Account_Manager__c != null 
                                                            AND 
                                                            Area__c =: selectedArea 
                                                            AND 
                                                            (NOT Name LIKE '%Catch All%')];
        for(PatchTeam__c rec:patchTeamList){
            picklistWrap pickWrap = new picklistWrap();
            pickWrap.label = string.valueOf(rec.Name);
            pickWrap.value = string.valueOf(rec.Id);
            territoriesList.add(pickWrap);
        }
        return territoriesList;
    }
    
    @AuraEnabled
    public static List<picklistWrap> getManagerWrap(){
        //getting all users reporting to user
        List<picklistWrap> managerList = new List<picklistWrap>();
        List<User> userList = new List<User>();
        Set<Id> managerIds = new Set<Id>();
        List<User> managerReporters = [SELECT Id FROM User WHERE ManagerId =: UserInfo.getUserId()];
        for(User userRec : managerReporters){
            managerIds.add(userRec.Id);
        }
        List<User> managerManagerReporters = [SELECT Id FROM User WHERE ManagerId IN: managerIds];
        for(User userRec : managerManagerReporters){
            managerIds.add(userRec.Id);
        }
        managerIds.add(UserInfo.getUserId());
            
        userList = [SELECT Id, Name, username, email 
                        FROM 
                        User 
                        WHERE
                        isActive = true 
                        AND 
                        Profile.Name NOT IN ('System Administrator','Integration Profile','Sales Ops Admin')
                        AND 
                        Level__c = 'Rep'
                        AND
                        ManagerId IN: managerIds
                        ORDER BY name ASC];
        for(User usr: UserList){
            picklistWrap pickWrap = new picklistWrap();
            pickWrap.label = string.valueOf(usr.name);
            pickWrap.value = string.valueOf(usr.Id);
            managerList.add(pickWrap);
        }
        system.debug(managerList);      
        return managerList;
    }
    
    @AuraEnabled
    public static List<picklistWrap> getVacationManagerWrap(){
        List<picklistWrap> vacationManagerList = new List<picklistWrap>();
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        Set<String> userIds = new Set<String>();
        Map<String, String> userMap = new Map<String, String>();
        groupedResults = [SELECT Requested_For__c, 
                                COUNT(Id) 
                                FROM 
                                Access_Request__c 
                                WHERE 
                                Request_Type__c = 'Vacation Coverage' 
                                AND 
                                Request_Status__c = 'Active' 
                                AND 
                                Requested_For__c != null 
                                GROUP BY Requested_For__c];
        for(AggregateResult rec:groupedResults){
            if(rec.get('Requested_For__c') != null && rec.get('Requested_For__c') != ''){
                userIds.add(string.valueOf(rec.get('Requested_For__c')));
            }
        }
        
        for(user userRec:[SELECT Id, Name FROM User WHERE Id IN: userIds]){
            userMap.put(userRec.Id, userRec.Name);
        }
        
        
        for(AggregateResult rec:groupedResults){
            if(rec.get('Requested_For__c') != null && rec.get('Requested_For__c') != ''){
                picklistWrap pickWrap = new picklistWrap();
                pickWrap.label = userMap.get(string.valueOf(rec.get('Requested_For__c')));
                pickWrap.value = string.valueOf(rec.get('Requested_For__c'));
                vacationManagerList.add(pickWrap);
            }
        }
        return vacationManagerList;
    }
    
    /*
     * Created by Raghu. 
     * This method is used to show list of users that are reporting to user as part of Vacation coverage
     */ 
    @AuraEnabled
    public static List<picklistWrap> getUserManagerWrap(){
        //getting all users reporting to user
        List<picklistWrap> userManagerList = new List<picklistWrap>();
        Map<String, Id> patchTeamMap = new Map<String, Id>();
        
        List<User> userRec1 = [Select id, Level__c from User Where Id =: UserInfo.getUserId()];
        
        List<User> userList = new List<User>();
            
        
        if(userRec1[0].Level__c == 'Rep'){
            userList = [SELECT Id, Name, UserName, Email FROM User 
                                    WHERE 
                                    isActive = true 
                                    AND 
                                    Level__c = 'Rep'
                                    AND
                                    Id != :userInfo.getUserId()
                                    AND
                                    ProfileId =: UserInfo.getProfileId()
                            	    ORDER BY Name ASC];
        }
        
        else{
            if(Label.Vacation_Coverage_Admin.contains(UserInfo.getProfileId())){
                userList = [SELECT Id, Name, UserName, Email FROM User 
                                    WHERE 
                                    isActive = true 
                                    AND 
                                    Profile.Name NOT IN ('System Administrator','Integration Profile','Sales Ops Admin')
                            	    ORDER BY Name ASC];
            }
            else{
                Set<Id> managerIds = new Set<Id>();
                List<User> managerReporters = [SELECT Id FROM User WHERE ManagerId =: UserInfo.getUserId()];
                for(User userRec : managerReporters){
                    managerIds.add(userRec.Id);
                }
                List<User> managerManagerReporters = [SELECT Id FROM User WHERE ManagerId IN: managerIds];
                for(User userRec : managerManagerReporters){
                    managerIds.add(userRec.Id);
                }
                managerIds.add(UserInfo.getUserId());
                userList = [SELECT Id, 
                                    Name, 
                                    UserName, 
                                    Email 
                                    FROM 
                                    User 
                                    WHERE 
                                    isActive = true 
                                    AND 
                                    ManagerId IN: managerIds 
                                    ORDER BY Name ASC];
            }
        }
            
        for(User usr: UserList){
            picklistWrap pickWrap = new picklistWrap();
            pickWrap.label = string.valueOf(usr.name);
            pickWrap.value = string.valueOf(usr.Id);
            userManagerList.add(pickWrap);
        }
        system.debug(userManagerList);      
        return userManagerList;
    }
    
    @AuraEnabled
    public static response TBHCoverageCreate(string selectedArea, string selectedTBHTerritorie, string selectedTBHTerritorieLabel, string selectedTBHManager, string selectedTBHManagerLabel, string howLongDate){
        response responseRecord = new response();
        PatchTeamMember__c newSalesTeamRecord = new PatchTeamMember__c();
        //try{
        if(!String.isBlank(selectedArea) && !String.isBlank(selectedTBHTerritorie) && !String.isBlank(selectedTBHManager) && !String.isBlank(howLongDate)){
            list<PatchTeamMember__c> patchTeamMemberList = [SELECT Id 
                                                            FROM 
                                                            PatchTeamMember__c 
                                                            WHERE 
                                                            PatchTeam__c =: selectedTBHTerritorie 
                                                           	AND 
                                                            Role__c = 'TBH Coverage'
                                                            AND 
                                                            User__c =: selectedTBHManager];
            list<Access_Request__c>	accRequestList = [SELECT Id
                                                      		FROM 
                                                      		Access_Request__c
                                                      		WHERE 
                                                      		Sales_Territory__c =: selectedTBHTerritorie 
                                                       		AND 
                                                       		Requested_To__c =: selectedTBHManager
                                                      		AND 
                                                      		Request_Status__c = 'Active'];
            
            
            if(patchTeamMemberList.size() == 0 && accRequestList.size() == 0){
                List<Id> patchIds = new List<Id>();
                List<schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
                newSalesTeamRecord.PatchTeam__c = selectedTBHTerritorie;
                newSalesTeamRecord.Role__c = 'TBH Coverage';
                newSalesTeamRecord.User__c = selectedTBHManager;
                insert newSalesTeamRecord;
                //case createdCase = CreateCase(selectedTBHManager, howLongDate, selectedTBHTerritorie, selectedTBHTerritorieLabel,'TBH Coverage');
                Access_Request__c accessRequestRecord = createAccessRequest(selectedTBHManager, howLongDate, selectedTBHTerritorie, selectedTBHTerritorieLabel,'TBH Coverage');
                if(accessRequestRecord != null){
                    insert accessRequestRecord;
                }            
                List<Patch__c> patchList = new List<Patch__c>();
                patchList = [SELECT Id FROM Patch__c WHERE PatchTeam__c =: selectedTBHTerritorie];
                for(Patch__c rec:patchList){
                    patchIds.add(rec.id); 
                }
                if(patchIds.size()>0){
                    sObjTypes.add(Schema.Account.SObjectType);
                    sObjTypes.add(Schema.Opportunity.SObjectType);
                    sObjTypes.add(Schema.Lead.SObjectType);
                    PatchRealignJob job = new PatchRealignJob(patchIds, sObjTypes);
                    if(patchIds.size() == 0)
                    {
                        job.reassignEverything = true;
                    }
                    Integer batchSize = 10;
                    Database.executeBatch(job, batchSize);
                }
                responseRecord.status = 'SUCCESS';
                responseRecord.message = 'Created TBH Coverage successfully to ' + selectedTBHManagerLabel + ' for this ' + selectedTBHTerritorieLabel + ' Territorie.';  
            }
            else{
                responseRecord.status = 'ERROR';
                responseRecord.message = selectedTBHManagerLabel + ' have already access for this ' + selectedTBHTerritorieLabel + ' Territorie.';   
            }
        }
        /*}
        catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage());           
        }*/
        return responseRecord;
    }
    
    @AuraEnabled
    public static string TBHCoverageRemove(string selectedRemovaTBHManager,string TBHtype,string JsonString){
        try{
            Set<String> territoryIds = new Set<String>();
            List<Access_Request__c> AccessRequestList = new List<Access_Request__c>();
            List<Id> patchIds = new List<Id>();
            List<schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
            List<TBHCaseWrap> caseWrapList = (List<TBHCaseWrap>)JSON.deserialize(JsonString, List<TBHCaseWrap>.class);
            for(TBHCaseWrap rec:caseWrapList){
                if(TBHtype == 'Selected'){
                    if(rec.isSelected == true){
                        if(rec.accessRequestRecord.Sales_Territory__c != null){
                            territoryIds.add(rec.accessRequestRecord.Sales_Territory__c);
                            rec.accessRequestRecord.Request_Status__c = 'In Active';
                        }
                    }
                }
                if(TBHtype == 'All'){
                    if(rec.accessRequestRecord.Sales_Territory__c != null){
                        territoryIds.add(rec.accessRequestRecord.Sales_Territory__c);
                        rec.accessRequestRecord.Request_Status__c = 'In Active';
                    }
                }
                AccessRequestList.add(rec.accessRequestRecord);
            }
            if(AccessRequestList.size()>0){
                update AccessRequestList;
            }
            List<PatchTeamMember__c> PatchTeamMemberList = [SELECT 
                                                            Id 
                                                            FROM 
                                                            PatchTeamMember__c 
                                                            WHERE 
                                                            PatchTeam__c IN: territoryIds 
                                                            AND 
                                                            User__c =: selectedRemovaTBHManager 
                                                            AND 
                                                            Role__c = 'TBH Coverage'];
            if(PatchTeamMemberList.size()>0){
                delete PatchTeamMemberList;
            }
            
            list<Patch__c> patchList = new list<Patch__c>();
            patchList = [SELECT id FROM Patch__c WHERE PatchTeam__c IN: territoryIds]; 
            for(Patch__c rec:patchList){
                patchIds.add(rec.id); 
            }
            if(patchIds.size()>0){
                sObjTypes.add(Schema.Account.SObjectType);
                sObjTypes.add(Schema.Opportunity.SObjectType);
                sObjTypes.add(Schema.Lead.SObjectType);
                PatchRealignJob job = new PatchRealignJob(patchIds, sObjTypes);
                if(patchIds.size() == 0)
                {
                    job.reassignEverything = true;
                }
                Integer batchSize = 10;
                Database.executeBatch(job, batchSize);
            }
            
        }
        catch(Exception exp){
            throw new AuraHandledException('Error Exception happend' + exp.getMessage());           
        }
        return null;
    }
    
    @AuraEnabled
    public static string VacationCoverageRemove(string selectedRemovaVacationManager, string selectType, string JsonString){
        try{
            Set<String> requestedForIds = new Set<String>();
            //Set<String> accountIds = new Set<String>();
            List<Access_Request__c> AccReqList = new List<Access_Request__c>();
            Set<Id> selectedid = new Set<Id>();
            List<VacationCaseWrap> caseWrapList = (List<VacationCaseWrap>)JSON.deserialize(JsonString, List<VacationCaseWrap>.class);
            for(VacationCaseWrap rec : caseWrapList){
                if(selectType == 'Selected'){
                    if(rec.isSelected == true){
						rec.accessRequestRecord.Request_Status__c  = 'In Active';
                        selectedid.add(rec.requestedToId);
                        requestedForIds.add(rec.accessRequestRecord.Requested_For__c);
                    }
                }
                if(selectType == 'All'){
					rec.accessRequestRecord.Request_Status__c  = 'In Active';
                    selectedid.add(rec.requestedToId);
                    requestedForIds.add(rec.accessRequestRecord.Requested_For__c);
                }
                AccReqList.add(rec.accessRequestRecord);
            }
            system.debug('-----------'+AccReqList);
            if(AccReqList.size()>0){
                update AccReqList;
            }
            system.debug('the requested for is' + requestedForIds);
            List<AccountShare> acctShareList = [SELECT 
                                                    Id,
                                                    AccountId
                                                    FROM 
                                                    AccountShare 
                                                    WHERE
                                                    UserOrGroupId IN :requestedForIds];
                                                    //AND
                                                    //RowCause = 'Manual'];
            Set<Id> accountIds = new Set<Id>();
            for(AccountShare accShareRec : acctShareList){
                accountIds.add(accShareRec.AccountId);
            }
            
            if(!accountIds.isEmpty()){
                vacationCoverageBatch vacationCoverageJob = new vacationCoverageBatch(AccountIds, '', selectedid, 'Delete Vacation Coverage');
                Database.executeBatch(vacationCoverageJob, 1);
            }
            
        }
        catch(Exception exp){
            throw new AuraHandledException('Error Exception happend' + exp.getMessage());           
        }
        return null;
    }    
    
    public static boolean checkAlreadyRequested(String RequestedFor, String RequestedTo){
        List<Access_Request__c> accReqList =new List<Access_Request__c>();
        Boolean isRecordExists = true;
        /*accReqList = [select Id from Access_Request__c where Requested_For__c =:RequestedFor and 
                      Requested_To__c=:RequestedTo and Request_Status__c != 'In Active'];
        */
        accReqList = [SELECT Id FROM Access_Request__c WHERE Requested_For__c =:RequestedFor AND Request_Status__c != 'In Active'];
        if(accReqList.size() == 0){
            isRecordExists = false;
        }
        return isRecordExists;
    }
    
    @AuraEnabled
    public static response VacationCoverageCreate(string selectedVacationManager, string selectedVacationManagerLabel, string selectedCoveringManager, string selectedCoveringManagerLabel, string vacationEndDate){
        response responseRecord = new response();
        try{
            Boolean isRecExists = checkAlreadyRequested(selectedVacationManager, selectedCoveringManager);
            Id VacationCoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Vacation Coverage').getRecordTypeId();
            Access_Request__c accReq = new Access_Request__c();
            if(!isRecExists){
                accReq.RecordTypeId = VacationCoverageRecordTypeId;
                accReq.Request_Type__c = 'Vacation Coverage';
                accReq.Object_Type__c = 'Account';
                //accReq.Requested_From__c = UserInfo.getUserId();
                accReq.Requested_For__c = selectedVacationManager;
                accReq.Requested_To__c = selectedCoveringManager;
                accReq.Request_Status__c = 'Active';
                List<String> dateParts = vacationEndDate.split('-');
                Date vacationDate = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                accReq.Access_End_Date__c = vacationDate;
                //accReq.OwnerId ='00570000004lx1h';
                //insert accReq;
                List<AccountShare> accountShareInsertList = new List<AccountShare>();
                List<AccountShare> accountShareList = new List<AccountShare>();
                List<AccountTeamMember> AccountTeamList = new List<AccountTeamMember>();
                
                Set<Id> AccountIds = new Set<Id>(); 
                accountShareList = [SELECT Id, AccountId, 
                                                UserOrGroupId, 
                                                AccountAccessLevel, 
                                                OpportunityAccessLevel, 
                                                CaseAccessLevel, 
                                                ContactAccessLevel, 
                                                RowCause
                                                FROM 
                                                AccountShare 
                                                WHERE 
                                                UserOrGroupId = :selectedVacationManager];
                                                //AND 
                                                //RowCause = 'Team'];
                
                for(AccountShare acctShare : accountShareList){
                    //AccountShare acctShr = new AccountShare();
                    //acctShr.UserOrGroupId = selectedCoveringManager;
                    //acctShr.AccountId = acctShare.AccountId;
                    //acctShr.AccountAccessLevel = acctShare.AccountAccessLevel;
                    //acctShr.OpportunityAccessLevel = acctShare.OpportunityAccessLevel;
                    //acctShr.CaseAccessLevel = acctShare.CaseAccessLevel;
                    //acctShr.RowCause = 'Vacation Coverage';
                    //accountShareInsertList.add(acctShr);
                    AccountIds.add(acctShare.AccountId);
                }
                
                //Split Opp
                Set<Id> oppIds = new Set<Id>();
                List<OpportunitySplit> oppSplits = [SELECT Id, OpportunityId 
                                                            FROM
                                                            OpportunitySplit
                                                            WHERE
                                                            SplitOwnerId =: selectedVacationManager];
                                                            
                for(OpportunitySplit splitRec : oppSplits){
                    oppIds.add(splitRec.OpportunityId);
                }
                
                //get accountids from opportunity
                List<Opportunity> oppList = [SELECT Id,
                                                        AccountId, 
                                                        SE_Name__c 
                                                        FROM 
                                                        Opportunity 
                                                        WHERE 
                                                        SE_Name__c =: selectedVacationManager
                                                        OR
                                                        Id IN: oppIds];
                system.debug('the Opp List is' + oppList.size());
                for(Opportunity oppRec : oppList){
                    AccountIds.add(oppRec.AccountId);
                }
                
                /**List<AccountShare> opportunityAccountShareList = [SELECT Id, AccountId, 
                                                                                UserOrGroupId, 
                                                                                AccountAccessLevel, 
                                                                                OpportunityAccessLevel, 
                                                                                CaseAccessLevel, 
                                                                                ContactAccessLevel, 
                                                                                RowCause
                                   								                FROM 
                                   								                AccountShare 
                                   								                WHERE 
                                   								                AccountId IN: AccountIds
                                   								                AND
                                   								                UserOrGroupId = :selectedVacationManager]; 
                                   								                //AND 
                                   								                //RowCause = 'Team'];
                
                Map<String, Boolean> accountMap = new Map<String, Boolean>();
                for(AccountShare acctShare : opportunityAccountShareList){
                    if(accountMap.get(acctShare.AccountId) == null){ 
                       //Commented to create AccountTeam
                       /* AccountShare acctShr = new AccountShare();
                        acctShr.UserOrGroupId = selectedCoveringManager;
                        acctShr.AccountId = acctShare.AccountId;
                        //acctShr.AccountAccessLevel = 'acctShare.AccountAccessLevel';
                        acctShr.AccountAccessLevel = 'Edit';
                        acctShr.OpportunityAccessLevel = acctShare.OpportunityAccessLevel;
                        acctShr.CaseAccessLevel = acctShare.CaseAccessLevel;
                        accountShareInsertList.add(acctShr);*/
                        /**AccountTeamMember AccTeam = new AccountTeamMember();
                        AccTeam.AccountId = acctShare.AccountId;
                        AccTeam.UserId = selectedCoveringManager;
                        AccTeam.OpportunityAccessLevel = acctShare.OpportunityAccessLevel;
                        AccTeam.ContactAccessLevel = acctShare.ContactAccessLevel;
                        AccTeam.CaseAccessLevel = acctShare.CaseAccessLevel;
                        AccTeam.TeamMemberRole = 'Vacation Coverage';
                        AccountTeamList.add(AccTeam);
                        accountMap.put(acctShare.AccountId, true);
                    }
                }**/
                if(AccountIds.size() > 0){
                    insert accReq;
                    //insert accountShareInsertList;
                    //AccountAccess_Utility.insertAccountShare(accountShareInsertList);
                    //AccountAccess_Utility.insertAccountTeam(AccountIds, selectedCoveringManager);    
                    //AccountAccess_Utility.InsertOpportunityTeam(AccountIds, selectedCoveringManager); 
                    vacationCoverageBatch vacationCoverageJob = new vacationCoverageBatch(AccountIds, selectedCoveringManager, null, 'Create Vacation Coverage');
                    Database.executeBatch(vacationCoverageJob, 1);
                    responseRecord.status = 'SUCCESS';
                    //string act = '' + accountShareInsertList.size() + '';
                    responseRecord.message = 'Created vacation coverage successfully to ' + selectedCoveringManagerLabel + '.'; 
                }
                else{
                    responseRecord.status = 'ERROR';
                    responseRecord.message = selectedVacationManagerLabel + ' have no accounts to create vaction coverage.';
                }
            }
            else{
                responseRecord.status = 'ERROR';
                responseRecord.message = selectedVacationManagerLabel + ' have already exists vaction coverage.';
            }
        }
        catch(Exception exp){
            throw new AuraHandledException('Error Exception happend' + exp.getMessage());           
        }
        return responseRecord;
    }
    
    public static Access_Request__c createAccessRequest(Id requestedTo, string closedDate, string selectedTBHTerritorie, string selectedTBHTerritorieLabel,String requestType){
        List<String> dateParts = closedDate.split('-');
        Date dateWithNoTime = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        String CloseDateDDMMYY =dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
        Id TBH_CoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('TBH Coverage').getRecordTypeId();
        Access_Request__c accessRequestRecord = new Access_Request__c();
        accessRequestRecord.Object_Type__c = 'Sales Territory';
        //accessRequestRecord.Requested_From__c = UserInfo.getUserId();
        accessRequestRecord.Requested_To__c = requestedTo;
        accessRequestRecord.Access_End_Date__c = dateWithNoTime;
        accessRequestRecord.Request_Status__c = 'Active';
        accessRequestRecord.Request_Type__c = 'TBH Coverage';
        accessRequestRecord.Sales_Territory__c = selectedTBHTerritorie;
        accessRequestRecord.RecordTypeId = TBH_CoverageRecordTypeId;
        return accessRequestRecord;
    }
    
    public class picklistWrap{
        @AuraEnabled public string label {get;set;}
        @AuraEnabled public string value {get;set;}
    }
    
    @AuraEnabled
    public static List<TBHCaseWrap> getTBHCases(string selectedRemovaTBHManager){
        List<TBHCaseWrap> TBHCaseWrapList = new List<TBHCaseWrap>();
        Id TBH_CoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('TBH Coverage').getRecordTypeId();
        for(Access_Request__c accRecord : [SELECT Id, Access_End_Date__c, Requested_For__c, 
                                                    Requested_For__r.Name,
                                                    Requested_To__c,
                                                    Requested_To__r.Name,
                                                    Sales_Territory__c,
                                                    Sales_Territory__r.Name,
                                                    Request_Status__c,
                                                    Request_Type__c 
                                                    FROM 
                                                    Access_Request__c 
                                                    WHERE 
                                                    RecordTypeId =: TBH_CoverageRecordTypeId 
                                                    AND 
                                                    Requested_To__c =: selectedRemovaTBHManager 
                                                    AND 
                                                    Request_Status__c = 'Active']){
            TBHCaseWrap rec = new TBHCaseWrap();
            rec.isSelected = false;
            rec.accessRequestRecord = accRecord;
            rec.status = accRecord.Request_Status__c;
            rec.userName = accRecord.Requested_To__r.Name;
            rec.salesTerritory = accRecord.Sales_Territory__r.Name;
            if(accRecord.Access_End_Date__c != null){
                date until = accRecord.Access_End_Date__c;
                Integer d = until.day();
                Integer mo = until.month();
                Integer yr = until.year();
                DateTime DT = DateTime.newInstance(yr, mo, d);
                rec.closedDate  = DT.format('MMM dd yyyy'); 
            }
            else{
                rec.closedDate = '';
            }
            TBHCaseWrapList.add(rec);
        }
        return TBHCaseWrapList;
    }
    
    @AuraEnabled
    public static List<TBHCoverageWrap> getTBHCoverageList(string selectedTBHTerritorie){
        List<TBHCoverageWrap> TBHCoverageWrapList = new List<TBHCoverageWrap>();
        Map<String, Access_Request__c> accMap = new Map<String, Access_Request__c>();
        Id TBH_CoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('TBH Coverage').getRecordTypeId();
        for(Access_Request__c accRecord : [SELECT Id, Access_End_Date__c, Requested_For__c, Requested_For__r.Name, 
                                                    Requested_To__c,
                                                    Requested_To__r.Name,
                                                    Sales_Territory__c,
                                                    Sales_Territory__r.Name,
                                                    Request_Status__c,
                                                    Request_Type__c 
                                                    FROM 
                                                    Access_Request__c 
                                                    WHERE 
                                                    RecordTypeId =: TBH_CoverageRecordTypeId 
                                                    AND 
                                                    Request_Type__c = 'TBH Coverage' 
                                                    AND 
                                                    Sales_Territory__c =: selectedTBHTerritorie]){
        	accMap.put(accRecord.Requested_To__c + '' + accRecord.Sales_Territory__c, accRecord);
        }
        system.debug('-------------' + accMap);
        for(PatchTeamMember__c patchMemberRecord : [SELECT Id, Name, PatchTeam__c, PatchTeam__r.Name, Role__c,
                                                            User__c,
                                                            User__r.Name 
                                                            FROM 
                                                            PatchTeamMember__c 
                                                            WHERE 
                                                            PatchTeam__c =: selectedTBHTerritorie 
                                                            AND 
                                                            Role__c = 'TBH Coverage']){
            TBHCoverageWrap rec = new TBHCoverageWrap();
            rec.userName  = patchMemberRecord.User__r.Name;
            rec.salesTerritoryName  = patchMemberRecord.PatchTeam__r.Name;
            rec.salesTeamName  = patchMemberRecord.Name;
            rec.role  = patchMemberRecord.Role__c;
            if(accMap.get(patchMemberRecord.User__c + '' + patchMemberRecord.PatchTeam__c) != null ){
                if(accMap.get(patchMemberRecord.User__c + '' + patchMemberRecord.PatchTeam__c).Request_Status__c != null){
                     rec.status = accMap.get(patchMemberRecord.User__c + '' + patchMemberRecord.PatchTeam__c).Request_Status__c ;
                }
                if(accMap.get(patchMemberRecord.User__c + '' + patchMemberRecord.PatchTeam__c).Access_End_Date__c != null){
                    date until = accMap.get(patchMemberRecord.User__c + '' + patchMemberRecord.PatchTeam__c).Access_End_Date__c;
                    Integer d = until.day();
                    Integer mo = until.month();
                    Integer yr = until.year();
                    DateTime DT = DateTime.newInstance(yr, mo, d);
                    rec.closedDate = DT.format('MMM dd yyyy'); 
                }
                else{
                    rec.closedDate = '';
                }
            }
            else{
                rec.closedDate = '';
            }
            TBHCoverageWrapList.add(rec);
        }
        return TBHCoverageWrapList;
    }
    
    @AuraEnabled
    public static List<VacationCoverageWrap> getVacationCoverageList(string selectedVacationManager, string selectedCoveringManager,boolean isRep){
        List<VacationCoverageWrap> VacationCoverageWrapList = new List<VacationCoverageWrap> ();
        Id VacationCoverageRecordTypeId = Schema.SObjectType.Access_Request__c.getRecordTypeInfosByName().get('Vacation Coverage').getRecordTypeId();
        list<Access_Request__c> Access_RequestList = new list<Access_Request__c>();
        
        if(selectedVacationManager != null && selectedVacationManager != ''){
            Access_RequestList = [SELECT Id, Access_End_Date__c, Requested_For__c, Requested_For__r.Name, Requested_To__c,
                                  Requested_To__r.Name,
                                  Sales_Territory__c,
                                  Sales_Territory__r.Name,
                                  Request_Status__c,
                                  Request_Type__c 
                                  FROM 
                                  Access_Request__c 
                                  WHERE 
                                  RecordTypeId =: VacationCoverageRecordTypeId 
                                  AND 
                                  Requested_For__c =: selectedVacationManager];
        }
        else{
            Access_RequestList = [SELECT Id, Access_End_Date__c, Requested_For__c, Requested_For__r.Name, Requested_To__c,
                                  Requested_To__r.Name,
                                  Sales_Territory__c,
                                  Sales_Territory__r.Name,
                                  Request_Status__c,
                                  Request_Type__c 
                                  FROM 
                                  Access_Request__c 
                                  WHERE 
                                  RecordTypeId =: VacationCoverageRecordTypeId And OwnerId=:userinfo.getuserid()];
        }
        

        
        
        for(Access_Request__c accreq : Access_RequestList){ //And Requested_To__c =: selectedCoveringManager]){
            VacationCoverageWrap rec = new VacationCoverageWrap();
            rec.vacationManager = accreq.Requested_For__r.Name;
            rec.coveringManager = accreq.Requested_To__r.Name;
            rec.status = accreq.Request_Status__c;
            if(accreq.Access_End_Date__c != null ){
                date until = accreq.Access_End_Date__c;
                Integer d = until.day();
                Integer mo = until.month();
                Integer yr = until.year();
                DateTime DT = DateTime.newInstance(yr, mo, d);
                rec.closedDate  = DT.format('MMM dd yyyy'); 
            }
            else{
                rec.closedDate = '';
            }
            VacationCoverageWrapList.add(rec);
        }
        return VacationCoverageWrapList;
    }
    
    @AuraEnabled
    public static List<VacationCaseWrap> getVacationCases(string selectedRemovaVacationManager,boolean isRep){
        List<VacationCaseWrap> VacationCoverageWrapList = new list<VacationCaseWrap>();
        list<Access_Request__c> Access_RequestList = new list<Access_Request__c>();
        if(selectedRemovaVacationManager != null && selectedRemovaVacationManager != '' ){
            Access_RequestList = [SELECT Id, Request_Type__c, Object_Type__c, Requested_From__c,
                                                    Requested_For__c,
                                                    Requested_For__r.Name,
                                                    Request_Status__c,
                                                    Requested_To__c,
                                                    Requested_To__r.Name,
                                                    Access_End_Date__c
                                       	            FROM 
                                       	            Access_Request__c 
                                       	            WHERE 
                                       	            Requested_For__c =: selectedRemovaVacationManager  
                                       	            AND 
                                                    Request_Type__c = 'Vacation Coverage' 
                                                    AND 
                                                    Request_Status__c  ='Active'];
        }
        else{
            Access_RequestList = [SELECT Id, Request_Type__c, Object_Type__c, Requested_From__c,
                                                    Requested_For__c,
                                                    Requested_For__r.Name,
                                                    Request_Status__c,
                                                    Requested_To__c,
                                                    Requested_To__r.Name,
                                                    Access_End_Date__c
                                       	            FROM 
                                       	            Access_Request__c 
                                       	            WHERE 
                                       	            OwnerId =: userinfo.getuserid() 
                                       	            AND 
                                                    Request_Type__c = 'Vacation Coverage' 
                                                    AND 
                                                    Request_Status__c  ='Active'];
        }
        for(Access_Request__c accRec : Access_RequestList){ 
            VacationCaseWrap rec = new VacationCaseWrap();
            rec.isSelected = false;
            rec.status = accRec.Request_Status__c;
            rec.requestedFor = accRec.Requested_For__r.Name;
            rec.requestedTo = accRec.Requested_To__r.Name;
            rec.requestedForId = accRec.Requested_For__c;
            rec.requestedToId = accRec.Requested_To__c;
            if(accRec.Access_End_Date__c != null){
                date until = accRec.Access_End_Date__c;
                Integer d = until.day();
                Integer mo = until.month();
                Integer yr = until.year();
                
                DateTime DT = DateTime.newInstance(yr, mo, d);
                rec.closedDate  = DT.format('MMM dd yyyy'); 
            } 
            rec.accessRequestRecord = accRec;
            VacationCoverageWrapList.add(rec);
        }
        return VacationCoverageWrapList;
    }
    
    /**
    @AuraEnabled
    public static list<VacationCaseWrap> getVacationCases(string selectedRemovaVacationManager){
        list<VacationCaseWrap> VacationCoverageWrapList = new list<VacationCaseWrap>();
        for(case caseRecord:[Select id,TBH_Until__c,User__c,User__r.Name,Account.Name,Sales_Territory__c,Sales_Territory__r.Name,Subject,Status from case where  Subject Like 'Remove Vacation Coverage for%' And Status = 'New' And User__c=:selectedRemovaVacationManager And AccountId != null]){
            VacationCaseWrap rec = new VacationCaseWrap();
            rec.isSelected = false;
            rec.caseRecord = caseRecord;
            rec.userName = caseRecord.User__r.Name;
            rec.AccountName = caseRecord.Account.Name;
            if(caseRecord.TBH_Until__c != null){
                date until = caseRecord.TBH_Until__c;
                Integer d = until.day();
                Integer mo = until.month();
                Integer yr = until.year();
                
                DateTime DT = DateTime.newInstance(yr, mo, d);
                rec.closedDate  = DT.format('dd/MM/yyyy'); 
            }
            else{
                rec.closedDate = '';
            }
            VacationCoverageWrapList.add(rec);
        }
        return VacationCoverageWrapList;
    }*/
    
    public class TBHCaseWrap{
        @AuraEnabled public case caseRecord {get;set;}
        @AuraEnabled public Access_Request__c accessRequestRecord {get;set;}
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string closedDate {get;set;}
        @AuraEnabled public string userName {get;set;}
        @AuraEnabled public string salesTerritory {get;set;}
    }
    public class VacationCaseWrap{
        @AuraEnabled public Access_Request__c accessRequestRecord {get;set;}
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string closedDate {get;set;}
        @AuraEnabled public string requestedFor {get;set;}
        @AuraEnabled public string requestedTo {get;set;}
        @AuraEnabled public string requestedForId {get;set;}
        @AuraEnabled public string requestedToId {get;set;}
        
    }
    public class TBHCoverageWrap{
        @AuraEnabled public string closedDate {get;set;}
        @AuraEnabled public string userName {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string salesTerritoryName {get;set;}
        @AuraEnabled public string salesTeamName {get;set;}
        @AuraEnabled public string role {get;set;}
    }
    public class VacationCoverageWrap{
        @AuraEnabled public string closedDate {get;set;}
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string AccountName {get;set;}
        @AuraEnabled public string vacationManager {get;set;}
        @AuraEnabled public string coveringManager {get;set;}
        @AuraEnabled public string role {get;set;}
    }
    
    public class response{
        @AuraEnabled public string status {get;set;}
        @AuraEnabled public string message {get;set;}
    }
    
}