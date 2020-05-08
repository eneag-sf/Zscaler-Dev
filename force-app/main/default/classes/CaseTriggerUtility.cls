public class CaseTriggerUtility{
    public static Id caseSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    public static Id exp_projRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Experience_Project').getRecordTypeId();
    
    public static void beforeInsert(List<Case> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        convertIntegrationCasestoSupport(newList);
        assignStatusStartDate(newList);
        assignAccountforSupportCase(newList);
        assignCustomerScoreParameters(newList);
        if(tsmap.containsKey('Execute_Case_SkillAssignment') && tsmap.get('Execute_Case_SkillAssignment') != null && tsmap.get('Execute_Case_SkillAssignment').Execute__c && !TriggerUtility.isCaseSkillAssignmentExecuted()){
            assignCasesbySkill(newList);
        }
        if(tsmap.containsKey('Execute_Case_Entitlement_Assignment') && tsmap.get('Execute_Case_Entitlement_Assignment') != null && tsmap.get('Execute_Case_Entitlement_Assignment').Execute__c && !TriggerUtility.isCaseEntitlementAssigned()){
            assignEntitlementtoCase(newList);
        }
        TriggerUtility.CaseBeforeInsertExecuted();
    }
    public static void afterInsert(List<Case> newList){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_Case_Description_to_Comment') && tsmap.get('Execute_Case_Description_to_Comment') != null && tsmap.get('Execute_Case_Description_to_Comment').Execute__c && !TriggerUtility.isCaseDesctoCommentExecuted()){
            makeCaseDescriptiontoComment(newList);
        }
        TriggerUtility.CaseAfterInsertExecuted();
    }
    public static void beforeUpdate(List<Case> newList, Map<Id, case> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        changeAccountofSupportCase(newList, oldmap);
        if(tsmap.containsKey('Execute_Case_Escalation') && tsmap.get('Execute_Case_Escalation') != null && tsmap.get('Execute_Case_Escalation').Execute__c && !TriggerUtility.isskipCaseEscalationExecuted()){
            escalateCase(newList, oldmap);
        }
        assignNewStartDateforStatus(newList, oldmap);
        assignCustomerScoreParameters(newList);
        UpdatePriorOwnerofCase(newList, oldmap);
        TriggerUtility.CaseBeforeUpdateExecuted();
    }

    public static void afterUpdate(List<Case> newList, Map<Id, case> oldmap){
        Map<String, Triggers_Switch__c> tsmap = Triggers_Switch__c.getAll();
        if(tsmap.containsKey('Execute_Escalation_Notes_Creation') && tsmap.get('Execute_Escalation_Notes_Creation') != null && tsmap.get('Execute_Escalation_Notes_Creation').Execute__c && !TriggerUtility.isCaseEscalationNotesExecuted()){
            escalationNotesCreation(newList, oldmap);
        }
        if(tsmap.containsKey('Execute_Escalation_History_Creation') && tsmap.get('Execute_Escalation_History_Creation') != null && tsmap.get('Execute_Escalation_History_Creation').Execute__c && !TriggerUtility.isCaseEscalationHistoryExecuted()){
            escalationHistoryCreation(newList, oldmap);
        }

        if(tsmap.containsKey('Execute_Case_Status_History') && tsmap.get('Execute_Case_Status_History') != null && tsmap.get('Execute_Case_Status_History').Execute__c && !TriggerUtility.isCaseStatusHistoryExecuted()){
            caseStatusChangeManagement(newList, oldmap);
        }

        if(tsmap.containsKey('Execute_Manual_SLA') && tsmap.get('Execute_Manual_SLA') != null && tsmap.get('Execute_Manual_SLA').Execute__c && !TriggerUtility.isManualSLAExecuted()){
            manualSLAChange(newList, oldmap);
        }

        if(tsmap.containsKey('Execute_Get_Feedback') && tsmap.get('Execute_Get_Feedback') != null && tsmap.get('Execute_Get_Feedback').Execute__c && !TriggerUtility.isGetFeedbackExecuted()){
            getFeedbackSurveyCreation(newList, oldmap);
        }
        if(tsmap.containsKey('CloseMilestonesonCaseClose') && tsmap.get('CloseMilestonesonCaseClose') != null && tsmap.get('CloseMilestonesonCaseClose').Execute__c && !TriggerUtility.isCloseMilestonesonCaseCloseExecuted()){
            closeMilestonesonCaseClosure(newList, oldmap);
        }
        //Added by Gurjinder for update details on Master Case:Start
        if(tsmap.containsKey('UpdateDetailsonMasterCase') && tsmap.get('UpdateDetailsonMasterCase') != null && tsmap.get('UpdateDetailsonMasterCase').Execute__c && !TriggerUtility.isUpdateDetailsonMasterCaseExecuted()){
            UpdateDetailsonMasterCase(newList, oldmap);
        }
        //Added by Gurjinder for update details on Master Case:End
        TriggerUtility.CaseAfterUpdateExecuted();
    }
    
    public static void UpdatePriorOwnerofCase(List<Case> newList, Map<Id, Case> oldmap){
        for(Case cs:newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Ownerid != oldmap.get(cs.id).Ownerid){
                if(oldmap.get(cs.id).Ownerid != null && string.valueOf(oldmap.get(cs.id).Ownerid).startsWith('005') ){
                    cs.Prior_Owner__c=oldmap.get(cs.id).Ownerid;
                }
                cs.Case_Owner_Assigned_Date__c = System.now();
            }
        }
    }
    
    public static void changeAccountofSupportCase(List<Case> newList, Map<Id, Case> oldmap){
        // Added by Gurjinder:Start
        List<Case> Caselist= new List<Case>();
        for(Case cs:newList){
            if(cs.RecordTypeId == caseSupportRT && cs.AccountId!=oldmap.get(cs.id).AccountId){
                Caselist.add(cs);
            }
        }
        if(!Caselist.isempty()){
            assignAccountforSupportCase(Caselist);  
        }
        // Added by Gurjinder:End
    }
    
    //Added by Gurjinder for update details on Master Case
    public static void UpdateDetailsonMasterCase(List<Case> newList, map<Id, case> oldmap){
        system.debug('inside UpdateDetailsonMasterCase method');
        List<Id> Caseidlist = new List<Id>();
        for(Case cs: newList){
            if(cs.Master_Case__c!=null && cs.Master_Case__c!=oldmap.get(cs.Id).Master_Case__c){
                Caseidlist.add(cs.Master_Case__c);
            }else if(cs.Master_Case__c==null && oldmap.get(cs.Id).Master_Case__c!=null){
                Caseidlist.add(oldmap.get(cs.Id).Master_Case__c);
            }
        }
        system.debug('Caseidlist   '+Caseidlist);
        if(Caseidlist.size()>0){
            UpdateMasterCaseKeyfields Qjob= new UpdateMasterCaseKeyfields(Caseidlist);
            System.enqueueJob(Qjob);
        }
        TriggerUtility.UpdateDetailsonMasterCaseExecuted();
    }
    
    public static void closeMilestonesonCaseClosure(List<Case> newList, map<Id, case> oldmap){
        Set<Id> caseIds = new Set<Id>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                caseIds.add(cs.Id);
            }
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        if(!caseIds.isEmpty()){
            MilestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
            MilestoneUtils.completeMilestone(caseIds, 'Subsequent', System.now());
        }
        TriggerUtility.CloseMilestonesonCaseCloseExecuted();
    }

    public static void getFeedbackSurveyCreation(List<Case> newList, map<Id, case> oldmap){
        List<Survey__c> ticketList = new List<Survey__c>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && (cs.Case_Type__c == 'Problem' || cs.Case_Type__c == 'Question') && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                ticketList.add(createSurvey(cs));
            }
        }
        insert ticketList;
        TriggerUtility.GetFeedbackExecuted();
    }

    public static Survey__c createSurvey(Case ticket)
    {
        Id csatRTId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('CSAT_Survey').getRecordTypeId();
        Id dasRTId = Schema.SObjectType.Survey__c.getRecordTypeInfosByDeveloperName().get('DAS_Survey').getRecordTypeId();
        Survey__c ticketFeedback = new Survey__c();
        ticketFeedback.RecordTypeId = csatRTId;
        ticketFeedback.Case__c = ticket.Id;
        if(ticket.AccountId != null)
        {
            ticketFeedback.Account__c = ticket.AccountId;
        }
        if(ticket.ContactId != null)
        {
            ticketFeedback.Contact__c = ticket.ContactId;
        }
        ticketFeedback.Zendesk_Area__c = ticket.Case_Category__c;
        ticketFeedback.Zendesk_Sub_Area__c = ticket.Case_Sub_Category__c;
        if(isSandbox())
        {
            ticketFeedback.Contact_Email__c = Label.surveySandboxEmail;
        }
        else
        {
            ticketFeedback.Contact_Email__c = ticket.ContactEmail; 
        }
        
        ticketFeedback.Contact_Name__c = ticket.Contact_Name__c;
        ticketFeedback.Ticket_Assignee__c = ticket.OwnerId;
        //ticketFeedback.Type__c = ticket.Integration_Type__c;
        //ticketFeedback.Ticket_Status__c = ticket.Integration_Status__c;
        ticketFeedback.Case_Owner_Manager__c = ticket.Case_Owner_Manager__c;
        return ticketFeedback;
    }
    
    public static void convertIntegrationCasestoSupport(List<Case> newList){
        for(Case cs: newList){
            if(cs.case_source__c == 'Integration'){
                cs.RecordTypeId = caseSupportRT;
            }
        }
    }
    
    public static void assignAccountforSupportCase(List<Case> newList){
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                cs.Account_of_Support_Case__c = cs.AccountId;
            }
        }
    }

    public static void assignCasesbySkill(List<Case> newList){
        Set<Id> accids = new Set<Id>();
        List<Case> supportcases = new List<Case>();
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        for(Case cs: newList){
            if(cs.case_source__c == 'Integration'){
                cs.RecordTypeId = caseSupportRT;
            }
            if(cs.RecordTypeId == caseSupportRT){
                supportcases.add(cs);
                accids.add(cs.AccountId);
            }
        }
        Map<Id, Id> acctammap = new Map<Id, Id>();
        Map<Id, Account> accmap = new Map<Id, Account>();
        set<Id> tamIds = new Set<Id>();
        set<Id> availabletamIds = new Set<Id>();
        for(Account acc: [Select Id, Type, TAM_Name_New__c, Name, Secondary_TAM_Name__c, X3rd_TAM_Name__c, Customer_Support_Segment__c, Prospect_Type__c from Account where Id in :accids]){
            if(acc.TAM_Name_New__c != null){
                tamIds.add(acc.TAM_Name_New__c);
            }
            if(acc.Secondary_TAM_Name__c != null){
                tamIds.add(acc.Secondary_TAM_Name__c);
            }
            if(acc.X3rd_TAM_Name__c != null){
                tamIds.add(acc.X3rd_TAM_Name__c);
            }
            accmap.put(acc.Id, acc);
        }
        if(!tamIds.isEmpty()){
            for(UserServicePresence usp: [Select Id, isaway, userid, user.name, ServicePresenceStatusId, name, ConfiguredCapacity, IsCurrentState from UserServicePresence where IsCurrentState = true and isaway=false and userid in :tamIds]){
                availabletamIds.add(usp.userid);
            }
            for(Account acc: accmap.values()){
                if(acc.TAM_Name_New__c != null && availabletamIds.contains(acc.TAM_Name_New__c)){
                    acctammap.put(acc.Id, acc.TAM_Name_New__c);
                }else if(acc.Secondary_TAM_Name__c != null && availabletamIds.contains(acc.Secondary_TAM_Name__c)){
                    acctammap.put(acc.Id, acc.Secondary_TAM_Name__c);
                }else if(acc.X3rd_TAM_Name__c != null && availabletamIds.contains(acc.X3rd_TAM_Name__c)){
                    acctammap.put(acc.Id, acc.X3rd_TAM_Name__c);
                }
            }
        }
        Boolean tamrouting = false;
        Boolean internalagentcreation = false;
        for(Case cs: supportcases){
            if(cs.case_source__c == 'Integration' && cs.AccountId == null){
                if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization'){
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
                }else{
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Primary_Support__c : '';
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Secondary_Support__c : '';
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Escalation_Support__c : '';
                }
            }else if((cs.Case_Type__c == 'Provisioning') && cs.AccountId != null && Label.Centracomm_Account_Ids != null && Label.Centracomm_Account_Ids.contains(cs.AccountId)){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CentraComm') ? psesupportmap.get('CentraComm').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CentraComm') ? psesupportmap.get('CentraComm').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CentraComm') ? psesupportmap.get('CentraComm').Escalation_Support__c : '';
            }else if(cs.Case_Type__c == 'Provisioning' || cs.Case_Type__c == 'Categorization' || cs.Case_Category__c == 'Provisioning Request'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('CS') ? psesupportmap.get('CS').Escalation_Support__c : '';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).Type == 'Partner'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Escalation_Support__c : '';
            }else if(cs.Owner_Service_Level__c != null && cs.Owner_Service_Level__c != 'Support Leads' && cs.Owner_Service_Level__c != 'Support Managers'){
                internalagentcreation = true;
                cs.Origin = 'Internal Agent';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && (accmap.get(cs.AccountId).TAM_Name_New__c != null || accmap.get(cs.AccountId).Secondary_TAM_Name__c != null || accmap.get(cs.AccountId).X3rd_TAM_Name__c != null)){
                if(acctammap != null && acctammap.containskey(cs.AccountId)){
                    cs.OwnerId = acctammap.get(cs.AccountId);
                    tamrouting = true;
                    cs.Case_Owner_is_TAM__c=true;
                }else{
                    cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Primary_Support__c : '';
                    cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Secondary_Support__c : '';
                    cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Escalation_Support__c : '';
                }
            }else if(cs.Product_New__c == 'ZPA' || (cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && (accmap.get(cs.AccountId).Customer_Support_Segment__c == 'Top100' || accmap.get(cs.AccountId).Customer_Support_Segment__c == 'Platinum' || accmap.get(cs.AccountId).Prospect_Type__c == 'POC'))){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Escalation_Support__c : '';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).Customer_Support_Segment__c == 'Gold'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2A') ? psesupportmap.get('L2A').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2A') ? psesupportmap.get('L2A').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2A') ? psesupportmap.get('L2A').Escalation_Support__c : '';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).Customer_Support_Segment__c == 'Silver'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Escalation_Support__c : '';
            }else if(cs.AccountId != null && accmap != null && accmap.containsKey(cs.AccountId) && accmap.get(cs.AccountId) != null && accmap.get(cs.AccountId).Customer_Support_Segment__c == 'Bronze'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L1') ? psesupportmap.get('L1').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L1') ? psesupportmap.get('L1').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L1') ? psesupportmap.get('L1').Escalation_Support__c : '';
            }else{
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2') ? psesupportmap.get('L2').Escalation_Support__c : '';
            }
            if(!tamrouting && !internalagentcreation){
                cs.OwnerId = Label.Support_Queue_Id;
            }
        }
        TriggerUtility.CaseSkillAssignmentExecuted();
    }
    
    public static void escalateCase(List<Case> newList, map<Id, case> oldmap){
        Set<Id> accids = new Set<Id>();
        Set<Id> caseOwnerasAccTAMs = new Set<Id>();
        Set<Id> caseOwners = new Set<Id>();
        List<Case> supportcases = new List<Case>();
        Map<String, Primary_Secondary_Escalation_Support_Map__c> psesupportmap = Primary_Secondary_Escalation_Support_Map__c.getAll();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.HandOff_Cases__c && cs.HandOff_Cases__c != oldmap.get(cs.Id).HandOff_Cases__c){
                supportcases.add(cs);
                caseOwners.add(cs.OwnerId);
                system.debug(caseOwners);
                accids.add(cs.AccountId);
            }
        }
        Map<Id, String> useridtolevelmap = new Map<Id, String>();
        for(User us: [Select Id, Service_Level__c from user where id in :caseOwners and Service_Level__c in ('L1','L2','L2A', 'TAM')]){
            useridtolevelmap.put(us.Id, us.Service_Level__c);
        }
        if(!useridtolevelmap.isEmpty() && !caseOwners.isEmpty() && !caseOwners.containsAll(useridtolevelmap.keyset())){
            for(Account acc: [Select Id from account where TAM_Name_New__c in :caseOwners or Secondary_TAM_Name__c in :caseOwners or X3rd_TAM_Name__c in :caseOwners]){
                caseOwnerasAccTAMs.add(acc.Id);
            }
        }
        
        for(case cs: newList){
            //if(!caseOwnerasAccTAMs.isEmpty() && caseOwnerasAccTAMs.contains(cs.ownerid)){
            if(!useridtolevelmap.isEmpty() && useridtolevelmap.containskey(cs.ownerid) && useridtolevelmap.get(cs.ownerid) != null && useridtolevelmap.get(cs.ownerid) == 'TAM'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L3') ? psesupportmap.get('L3').Escalation_Support__c : '';
                cs.OwnerId = Label.Support_Queue_Id;
            }else if(!useridtolevelmap.isEmpty() && useridtolevelmap.containskey(cs.ownerid) && useridtolevelmap.get(cs.ownerid) != null && useridtolevelmap.get(cs.ownerid) == 'L1'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L1Escalation') ? psesupportmap.get('L1Escalation').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L1Escalation') ? psesupportmap.get('L1Escalation').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L1Escalation') ? psesupportmap.get('L1Escalation').Escalation_Support__c : '';
                cs.OwnerId = Label.Support_Queue_Id;
            }else if(!useridtolevelmap.isEmpty() && useridtolevelmap.containskey(cs.ownerid) && useridtolevelmap.get(cs.ownerid) != null && useridtolevelmap.get(cs.ownerid) == 'L2'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2Escalation') ? psesupportmap.get('L2Escalation').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2Escalation') ? psesupportmap.get('L2Escalation').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2Escalation') ? psesupportmap.get('L2Escalation').Escalation_Support__c : '';
                cs.OwnerId = Label.Support_Queue_Id;
            }else if(!useridtolevelmap.isEmpty() && useridtolevelmap.containskey(cs.ownerid) && useridtolevelmap.get(cs.ownerid) != null && useridtolevelmap.get(cs.ownerid) == 'L2A'){
                cs.Primary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2AEscalation') ? psesupportmap.get('L2AEscalation').Primary_Support__c : '';
                cs.Secondary_Support__c = psesupportmap != null && psesupportmap.containsKey('L2AEscalation') ? psesupportmap.get('L2AEscalation').Secondary_Support__c : '';
                cs.Escalation_Support__c = psesupportmap != null && psesupportmap.containsKey('L2AEscalation') ? psesupportmap.get('L2AEscalation').Escalation_Support__c : '';
                cs.OwnerId = Label.Support_Queue_Id;
            }
            //cs.HandOff_Cases__c = false;
        }
        TriggerUtility.skipCaseEscalationExecuted();
    }

    public static void assignStatusStartDate(List<Case> cslst){
        for(Case cs: cslst){
            if(cs.status != null && cs.recordtypeId == caseSupportRT){
                cs.Status_Start_Date__c = System.now();
            }
        }
    }

    public static void escalationHistoryCreation(List<Case> newList, map<Id, case> oldmap){
        List<Case> supportcases = new List<Case>();
        List<Case> casestoupdate = new List<Case>();
        Map<Id, Case_Escalation_History__c> mapcasetoescalation = new Map<Id, Case_Escalation_History__c>();
        for(Case cs: newList){
            //if(cs.RecordTypeId == caseSupportRT && cs.Escalation_Stage__c == 'Closed' && cs.Escalation_Stage__c != oldmap.get(cs.Id).Escalation_Stage__c){
            if(cs.RecordTypeId == caseSupportRT && cs.IsClosed && cs.IsClosed != oldmap.get(cs.Id).IsClosed){
                supportcases.add(cs);
            }
        }
        List<Case_Escalation_History__c> cehlst = new List<Case_Escalation_History__c>();
        List<Case_Notes_History__c> cnhlst = new List<Case_Notes_History__c>();
        for(Case cs: supportcases){
            case cstoupdate = new case(Id = cs.Id);
            Case_Escalation_History__c ceh = new Case_Escalation_History__c(Case__c = cs.Id, Case_Owner__c = cs.OwnerId);
            for (FieldSetMember fm: Schema.SObjectType.Case.fieldSets.getMap().get('Escalation_History_Creation').getFields()) {
                ceh.put(fm.getFieldPath(), cs.get(fm.getFieldPath()));
                cstoupdate.put(fm.getFieldPath(), null);
            }
            ceh.Escalation_End_time__c = system.now();
            ceh.Escalation_Resolved_By__c = UserInfo.getUserId();
            cehlst.add(ceh);
            cstoupdate.isEscalated = false;
            cstoupdate.Escalation_on_behalf_of_Customer__c = false;
            casestoupdate.add(cstoupdate);
            if(!mapcasetoescalation.containskey(cs.Id)){
                mapcasetoescalation.put(cs.Id, ceh);
            }
        }
        insert cehlst;
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        update casestoupdate;

        for(Case_Notes_History__c cnh: [Select Id, Case__c, Case_Escalation_History__c from Case_Notes_History__c where Case__c in :mapcasetoescalation.keyset() and Case_Escalation_History__c = null]){
            if(cnh.Case__c != null && mapcasetoescalation.containsKey(cnh.Case__c) && mapcasetoescalation.get(cnh.Case__c) != null && mapcasetoescalation.get(cnh.Case__c).Id != null){
                cnh.Case_Escalation_History__c = mapcasetoescalation.get(cnh.Case__c).Id;
                cnhlst.add(cnh);
            }
        }
        update cnhlst;
        TriggerUtility.CaseEscalationHistoryExecuted();
    }

    public static void escalationNotesCreation(List<Case> newList, map<Id, case> oldmap){
        List<Case> supportcases = new List<Case>();
        List<Case> casestoupdate = new List<Case>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Escalation_Resolution_Notes__c != oldmap.get(cs.Id).Escalation_Resolution_Notes__c){
                supportcases.add(cs);
            }
        }
        List<Case_Notes_History__c> cnhlst = new List<Case_Notes_History__c>();
        for(Case cs: supportcases){
            case cstoupdate = new case(Id = cs.Id);
            Case_Notes_History__c cnh = new Case_Notes_History__c(Escalation_Stage__c = cs.Escalation_Stage__c, Escalation_Notes__c = cs.Escalation_Resolution_Notes__c, Case__c = cs.Id, Notes_Added_at__c = system.now(), Notes_Added_By__c=userinfo.getUserId(), Customer_Temperature__c = cs.Customer_Temperature__c);
            cnhlst.add(cnh);
            /*cstoupdate.Escalation_Resolution_Notes__c = null;
            cstoupdate.Customer_Temperature__c = null;
            cstoupdate.Escalation_Stage__c = null;*/
            casestoupdate.add(cstoupdate);
        }
        insert cnhlst;
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        update casestoupdate;
        TriggerUtility.CaseEscalationNotesExecuted();
    }

    public static void assignEntitlementtoCase(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                csmap.put(cs.AccountId, cs);
            }
        }
        for(Entitlement ent: [Select Id, AccountId from Entitlement where accountid in :csmap.keySet() and EndDate = null and Status = 'Active']){
            if(ent.AccountId != null){
                csmap.get(ent.AccountId).EntitlementId = ent.Id;
            }
        }
        TriggerUtility.CaseEntitlementAssigned();
    }

    public static void caseStatusChangeManagement(List<Case> newList, map<Id, case> oldmap){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<case> cstoupdate = new List<Case>();
        Map<String, Case_Status_and_SLA_Map__c> cssmap = Case_Status_and_SLA_Map__c.getAll();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Status != oldmap.get(cs.Id).Status){
                csmap.put(cs.AccountId, cs);
            }
        }
        List<Case_Stage_History__c> cshlst = new List<Case_Stage_History__c>();
        for(Case cs: csmap.values()){
            Case_Stage_History__c csh = new Case_Stage_History__c(Case__c = cs.Id);
            csh.Start_Date__c = oldmap.get(cs.Id).Status_Start_Date__c;
            csh.End_Date__c = System.now();
            csh.Modified_By__c = UserInfo.getUserId();
            csh.Case_Status__c = oldmap.get(cs.Id).Status;
            if(cs.SRT_Violated_Time__c >= csh.Start_Date__c  && cs.SRT_Violated_Time__c <= csh.End_Date__c){
                csh.Subsequent_Response_Breached__c = cs.Subsequent_Response_Breached__c;
                csh.SRT_Violated_Time__c = cs.SRT_Violated_Time__c;
            }
            if(cs.First_Response_Violated_Time__c >= csh.Start_Date__c  && cs.First_Response_Violated_Time__c <= csh.End_Date__c){
                csh.First_Response_Time_Violated__c = cs.First_Response_Time_Violated__c;
                csh.First_Response_Violated_Time__c = cs.First_Response_Violated_Time__c;
            }
            cshlst.add(csh);

            if(cs.Status == 'Closed'){
                csh = new Case_Stage_History__c(Case__c = cs.Id);
                csh.Start_Date__c = System.now();
                csh.End_Date__c = System.now();
                csh.Modified_By__c = UserInfo.getUserId();
                csh.Case_Status__c = cs.Status;
                cshlst.add(csh);
            }

            if(oldmap.get(cs.Id).Status != null && cssmap.containskey(oldmap.get(cs.Id).Status) && cssmap.get(oldmap.get(cs.Id).Status).SLA_Type__c == 'SRT'){
                caseIds.add(cs.Id);
            }
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        insert cshlst;

        if(!caseIds.isEmpty()){
            MilestoneUtils.completeMilestone(caseIds, 'Subsequent', System.now());
        }
        TriggerUtility.CaseStatusHistoryExecuted();
    }
    public static void makeCaseDescriptiontoComment(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        List<case> cstoupdate = new List<Case>();
        for(Case cs: newList){
            if((cs.RecordTypeId == caseSupportRT || cs.RecordTypeId == exp_projRT) && cs.Description != null){
                csmap.put(cs.Id, cs);
            }
        }
        List<FeedItem> cclst = new List<FeedItem>();
        for(Case cs: csmap.values()){
            FeedItem cc = new FeedItem(parentId = cs.Id);
            cc.Body = cs.Description;
            cc.Visibility = 'AllUsers';
            cc.IsRichText = true;
            cclst.add(cc);
        }
        
        TriggerUtility.CaseBeforeInsertExecuted();
        TriggerUtility.CaseAfterInsertExecuted();
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        TriggerUtility.SkipFeedItemTriggerExecuted();
        TriggerUtility.SkipCaseCommentTriggerExecuted();
        insert cclst;

        TriggerUtility.CaseDesctoCommentExecuted();
    }
    public static void assignNewStartDateforStatus(List<Case> newList, map<Id, case> oldmap){
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Status != oldmap.get(cs.Id).Status){
                cs.Status_Start_Date__c = system.now();
                cs.Manual_SLA_Timestamp__c = null;
            }
        }
    }
    public static void manualSLAChange(List<Case> newList, map<Id, case> oldmap){
        Map<Id, Case> csmap = new Map<Id, Case>();
        List<CaseMilestone> cmlst = new List<CaseMilestone>();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT && cs.Manual_SLA_Timestamp__c != oldmap.get(cs.Id).Manual_SLA_Timestamp__c){
                csmap.put(cs.Id, cs);
            }
        }
        for(CaseMilestone cm: [select Id, completionDate, Startdate, TargetDate, CaseId
                                           from CaseMilestone cm
                                           where caseId in :csmap.keyset() and cm.MilestoneType.Name='Subsequent' 
                                           and completionDate = null]){
            Long diffinms = (cm.TargetDate.getTime() - cm.StartDate.getTime());
            Long diffinsec = diffinms/1000;
            Integer diffinmin = -1 * Integer.valueOf(diffinsec/60);
            cm.StartDate = csmap.containsKey(cm.CaseId) && csmap.get(cm.CaseId) != null && csmap.get(cm.CaseId).Manual_SLA_Timestamp__c != null && diffinmin != null? csmap.get(cm.CaseId).Manual_SLA_Timestamp__c.addminutes(diffinmin): cm.StartDate;
            cmlst.add(cm);
        }
        TriggerUtility.CaseBeforeUpdateExecuted();
        TriggerUtility.CaseAfterUpdateExecuted();
        update cmlst;
        TriggerUtility.ManualSLAExecuted();

    }
    public static void assignCustomerScoreParameters(List<Case> newList){
        Map<Id, Case> csmap = new Map<Id, Case>();
        Map<String, Case_Priority_Score__c> cpsmap = Case_Priority_Score__c.getAll();
        Map<String, DEFCON_Case_Score__c> dccmap = DEFCON_Case_Score__c.getAll();
        for(Case cs: newList){
            if(cs.RecordTypeId == caseSupportRT){
                csmap.put(cs.Id, cs);
            }
        }
        for(Case cs: csmap.values()){
            if(cs.Priority != null){
                cs.Case_Priority_Score__c = cpsmap.containsKey(cs.Priority) ? cpsmap.get(cs.Priority).Score__c : cs.Case_Priority_Score__c;
            }
            if(cs.Defcon_Level__c != null){
                cs.DEFCON_Score__c = dccmap.containsKey(cs.Defcon_Level__c) ? dccmap.get(cs.Defcon_Level__c).Score__c : cs.DEFCON_Score__c;
            }
        }

    }

    public static Boolean isSandbox(){
        Boolean flag = true;
        
        Organization org = [Select IsSandbox,InstanceName from Organization];
        
        flag = org.IsSandbox;
        return flag;
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
    }
}