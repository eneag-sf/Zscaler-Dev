/*****************************************************************************************
Name: CaptureUserOpportunityListBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
1. Batch class to capture user specific list of opportunity which is having data issue.

==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL
1.0            Kunal Raj            17-May-2015    Initial Development
1.1            Vijay Prakash        10-Jan-2018    Removed Marketo Lead Score > 69 check for MQL
******************************************************************************************/



global class CaptureUserOpportunityListBatch implements Database.Batchable<sObject>, Database.Stateful{

    string jobId;
    OrgWideEmailAddress[] owea = new List<OrgWideEmailAddress>();
    List<String> errorlst = new List<String>();
    List<String> successlst = new List<String>();
    set<Id> managerIdSet = new set<Id>();
    set<Id> dataUserIdSet = new set<id>();
    map<id, user> userMap = new map<id, user>();
    map<id, id> usrIdMgrIdMap = new map<id, id>();
    map<id, string> userIdNameMap = new map<id, string>();
    map<id, string> userIdEmailMap = new map<id, string>();
    map<Id, Map<Id, Contact>> managerIdContactMapMap = new map<id, Map<id, Contact>>();
    map<Id, Map<Id, Lead>> managerIdLeadMapMap = new map<id, Map<id, Lead>>();
    map<Id, Map<Id, Opportunity>> managerIdOpportunityMapMap = new map<id, Map<id, Opportunity>>();

    Map<Id, String> oppIdIssueTypeMap = new map<Id, String>();
    set<String> issueTypeSet = new set<String>();

    public static final string emailStart = '<html><body>';
    public static final string emailEnd = '</body></html>';
    public static final string tableStart = '<table  width=\"100%\" style=\"border: 1px solid black;border-collapse: collapse;\" >';
    public static final string summTableStart = '<table  width=\"50%\" style=\"border: 1px solid black;border-collapse: collapse;\" >';
    public static final string tableEnd = '</table>';

    public static final string urlHere = 'https://drive.google.com/file/d/0B2QbEyYJCByYejZIN2daWlQxYXc/view';
    public static final string clickHereText = 'here';
    public static final string clickHere = '<a href=\''+ urlHere + '\''  + '>'+clickHereText+'</a>';

    public static final string SummTableHeaderForOpp = '<td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Sales Rep</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Stage</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: center;\"><b>Close Date</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Partner</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Next Steps</b></td></tr>';

    public static final string LDRSummTableHeader = '<tr color=\"red\"style=\"font-weight:bold;\"><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Sales Rep</b> </td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Count</b> </td></tr>';
    public static final string LDRSummTableFooter = '';

    public static final string ISRSummTableHeader = '<td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Sales Rep</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Stage</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: center;\"><b>Close Date</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Partner</b></td> <td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>Next Steps</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color: white;background-color: #002060;text-align: center;\"><b>MQL\'s</b></td></tr>';
    public static final string ISRSummTableFooter = '';

    public static final string oppTableHeader = '<tr color=\"red\" ' + ' style=\"font-weight:bold\"><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Owner</b> </td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Opportunity Name</b> </td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Amount</b> </td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Stage</b> </td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Close Date</b> </td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Issues</b> </td></tr>';
    public static final string oppTableFooter = '';

    public static final string leadTableHeader = '<tr color=\"red\"style=\"font-weight:bold;\"><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Owner</b> </td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Lead Name</b> </td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Company</b> </td> <td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Lead Title</b> </td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Lead Status</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Lead Score</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Lead Source Recent</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>MQL Date</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Original Lead Source</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color:#002060;text-align: center;\"><b>Account Manager</b></td></tr>';
    public static final string leadTableFooter = '';

    public static final string ldrUserContent = 'The MQL\'s shown in this email are un touched marketing qualified leads that are currently assigned to your territory. Please call them at the earliest or move the MQL\'s to an appropriate status. ';
    public static final string ldrManagerContent = 'The opportunities and MQL\'s listed in this notification are owned by your team members and have been identified as having critical data gaps or have not been touched. Please work to close the gaps.';
    public static final string isrUserContent = 'The opportunities listed in this notification are owned by you and have been identified as having critical data gaps. Please work to close the gaps.<br/><br/>The MQL\'s shown in this email are un touched marketing qualified leads that are currently assigned to your territory. Please call them at the earliest or move the MQL\'s to an appropriate status.';

    public static final string userContentForLead = 'The MQL\'s shown in this email are un touched marketing qualified leads that are currently owned by you. Please call them at the earliest or move the MQL\'s to an appropriate status.';
    public static final string mgrContentForLead = 'The MQL\'s shown in this email are un touched marketing qualified leads that are currently owned your team member.  Please work with them to move the MQL\'s to an appropriate status.';
    public static final string userContentForLeadAndOpp = 'The opportunities listed in this notification are owned by you and have been identified as having critical data gaps. Please work to close the gaps.<br/><br/>The MQL\'s shown in this email are un touched marketing qualified leads that are currently assigned to your territory. Please call them at the earliest or move the MQL\'s to an appropriate status.';
    public static final string userContentForOpp = 'The opportunities listed in this notification are owned by you and  have been identified as having critical data gaps. Please work to close the gaps.<br/>To understand more about why you are receiving this notification, please click ' + clickHere ;
    public static final string mgrContentForOpp = 'The opportunities listed in this notification are owned by your team member and  have been identified as having critical data gaps. Please work with your team members to close the gaps.<br/>To understand more about why you are receiving this notification, please click ' + clickHere ;

    global Database.QueryLocator start(Database.BatchableContext context){
        jobId = context.getJobId();
        owea = [select Id from OrgWideEmailAddress where Address = 'sfdcsupport@zscaler.com'];
        return Database.getQueryLocator([Select Id, Department, ManagerId, Manager.Email, Email, Name, Manager.Name from User Where  isActive =: true]);
    }

    global void execute (Database.BatchableContext context, List<sObject> userList){
        list<Lead_Issue__c> leadIssueInsertList = new list<Lead_Issue__c>();
        set<id> userIdSet = new set<id>();
        map<Id, Map<Id, Contact>> userIdContactMapMap = new map<id, Map<id, Contact>>();
        map<Id, Map<Id, Lead>> userIdLeadMapMap = new map<id, Map<id, Lead>>();
        map<Id, Map<Id, Opportunity>> userIdOpportunityMapMap = new map<id, Map<id, Opportunity>>();

        for(User usr : (list<User>) userList){
            userMap.put(usr.Id, usr);
            userIdSet.add(usr.Id);
            userIdNameMap.put(usr.Id, usr.Name);
            userIdEmailMap.put(usr.Id, usr.Email);
            if(usr.ManagerId != null){
                usrIdMgrIdMap.put(usr.Id, usr.ManagerId);
                managerIdSet.add(usr.ManagerId);
                //userIdSet.add(usr.ManagerId);
                userIdNameMap.put(usr.ManagerId, usr.Manager.Name);
                userIdEmailMap.put(usr.ManagerId, usr.Manager.Email);
            }
        }


        Date startDate;
        Date endDate;

        integer currentMonth = System.today().Month();
        if(currentMonth > 7)
            startDate = date.newInstance(System.today().year(), 8, 1);
        else
            startDate = date.newInstance(System.today().year() - 1, 8, 1);
        endDate = startDate.addMonths(12) - 1;

        /*map<id, Contact> tempContactMap = new map<id, Contact>();
        for(Contact con : [Select id, Name, FirstName, LastName, Email, Company_Name__c, LeadSource, mkto2__Lead_Score__c, MQL_Date__c, Account_Manager__c, Account_Manager__r.Name, OwnerId, Owner.ManagerId, Lead_Source_Recent__c, Contact_Lead_Status__c, Title from Contact where  MQL_Date__c >=:  startDate AND MQL_Date__c <=: endDate AND Contact_Lead_Status__c =: '2 - Re-engaged with New Activity' AND mkto2__Lead_Score__c > 69 AND OwnerId IN: userIdSet AND Geo__c != 'CHANNEL']){
            tempContactMap = new map<id, Contact>();
            if(userIdContactMapMap.keySet().Contains(con.OwnerId)){
                tempContactMap = userIdContactMapMap.get(con.OwnerId);
                tempContactMap.put(con.Id, con);
                userIdContactMapMap.put(con.ownerId, tempContactMap);
            }else{
                dataUserIdSet.add(con.OwnerId);
                tempContactMap.put(con.Id, con);
                userIdContactMapMap.put(con.ownerId, tempContactMap);
            }
            if(con.Owner.ManagerId != null){
                tempContactMap = new map<id, Contact>();
                if(managerIdContactMapMap.keySet().Contains(con.Owner.ManagerId)){
                    tempContactMap = managerIdContactMapMap.get(con.Owner.ManagerId);
                    tempContactMap.put(con.Id, con);
                    managerIdContactMapMap.put(con.Owner.ManagerId, tempContactMap);
                }else{
                    dataUserIdSet.add(con.Owner.ManagerId);
                    tempContactMap.put(con.Id, con);
                    managerIdContactMapMap.put(con.Owner.ManagerId, tempContactMap);
                }
            }
        }

        set<string> leadStatusSet = new set<string>();
        leadStatusSet.add('0 - Prospect');
        leadStatusSet.add('1 - Not Touched');
        leadStatusSet.add('2 - Re-engaged with New Activity');
        map<id,Lead> tempLeadMap = new map<id,Lead>();
        for(Lead le : [Select Id, Status, Account_Manager__c, Account_Manager__r.Name, Company, LeadSource, mkto2__Lead_Score__c, Name, MQL_Date__c, OwnerId,  Lead_Source_Recent__c, Title from Lead Where MQL_Date__c >=:  startDate AND MQL_Date__c <=: endDate AND Status IN: leadStatusSet AND OwnerId IN: userIdSet AND Geo__c != 'CHANNEL' AND (NOT Email LIKE '%zscaler.com')]){
            tempLeadMap = new map<id,Lead>();
            if(userIdLeadMapMap.keySet().Contains(le.OwnerId)){
                tempLeadMap = userIdLeadMapMap.get(le.OwnerId);
                tempLeadMap.put(le.Id, le);
                userIdLeadMapMap.put(le.OwnerId, tempLeadMap);
            }else{
                dataUserIdSet.add(le.OwnerId);
                tempLeadMap.put(le.Id, le);
                userIdLeadMapMap.put(le.OwnerId, tempLeadMap);
            }

            if(usrIdMgrIdMap.keySet().Contains(le.OwnerId)){
                tempLeadMap = new map<id, Lead>();
                id mgrId = usrIdMgrIdMap.get(le.OwnerId);
                if(managerIdLeadMapMap.keySet().Contains(mgrId)){
                    tempLeadMap = managerIdLeadMapMap.get(mgrId);
                    tempLeadMap.put(le.Id, le);
                    managerIdLeadMapMap.put(mgrId, tempLeadMap);
                }else{
                    dataUserIdSet.add(mgrId);
                    tempLeadMap.put(le.Id, le);
                    managerIdLeadMapMap.put(mgrId, tempLeadMap);
                }
            }
        }
        
        */
        set<String> oppTypeSet = new set<string>();
        oppTypeSet.add('New Business');
        oppTypeSet.add('Existing Customer (Add On)');
        oppTypeSet.add('Existing Customer (Renewal)');

        list<String> oppStageList = new list<String>();
        oppStageList.add(label.Stage_1_Alignment); //1 - Qualified and Budgeted
        oppStageList.add(label.Stage_2_Qualified_Budgeted); //2- Technical Validation
        oppStageList.add(label.Stage_4_Economic_Buyer_Signoff); //7-Negotiation and review	
        //oppStageList.add('8 - Expecting Order');              // Commented as 7-Negotiation and review, 8- Expecting Order, 9 - Deal Stuck has same replaceable value:-  label.Stage_4_Economic_Buyer_Signoff
        //oppStageList.add('9 - Deal Stuck');

        map<id, Opportunity> tempOppMap = new map<id, Opportunity>();
        for(Opportunity opp : [Select Id,Type, CreatedDate, NextStep, Fiscal_Quarter_To_Close__c, Name, StageName, Owner.Email, Owner.FirstName, Owner.LastName, Owner.Manager.Email, Owner.Manager.FirstName, Owner.Manager.LastName, OwnerId, Owner.ManagerId,  Issue_Type__c, Amount, CloseDate, Last_Stage_Changed_Date__c, Last_Next_Step_Updated_Date__c, Days_in_Current_Stage__c, Days_Since_Next_Step_Updated__c, (select AccountToId, AccountTo.Name from OpportunityPartnersFrom where IsPrimary=true) from Opportunity where IsClosed = false AND StageName IN: oppStageList  AND Type IN: oppTypeSet AND OwnerId IN: userIdSet]){

            tempOppMap = new map<id, Opportunity>();
            boolean oppAdded = false;

            if(Opp.Issue_Type__c != null && Opp.Issue_Type__c != ''){
                oppIdIssueTypeMap.put(opp.Id, Opp.Issue_Type__c);
                issueTypeSet.addAll(Opp.Issue_Type__c.split(','));
                oppAdded = true;

                if(userIdOpportunityMapMap.keySet().Contains(opp.OwnerId)){
                    tempOppMap = userIdOpportunityMapMap.get(opp.OwnerId);
                    tempOppMap.put(opp.Id, opp);
                    userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                }else{
                    dataUserIdSet.add(opp.OwnerId);
                    tempOppMap.put(opp.Id, opp);
                    userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                }

                if(opp.Owner.ManagerId != null){
                    tempOppMap = new map<id, opportunity>();
                    if(managerIdOpportunityMapMap.keySet().Contains(opp.Owner.ManagerId)){
                        tempOppMap = managerIdOpportunityMapMap.get(opp.Owner.ManagerId);
                        tempOppMap.put(opp.Id, opp);
                        managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                    }else{
                        dataUserIdSet.add(opp.Owner.ManagerId);
                        tempOppMap.put(opp.Id, opp);
                        managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                    }
                }
            }


            if(opp.stageName != label.Stage_4_Economic_Buyer_Signoff /*'8 - Expecting Order', 9 - Deal Stuck'*/ ){
                if(opp.NextStep != null){
                    if(opp.Last_Next_Step_Updated_Date__c != null && ((opp.Fiscal_Quarter_To_Close__c == 0 && opp.Last_Next_Step_Updated_Date__c + 10 < system.today() && opp.Last_Next_Step_Updated_Date__c < System.today()) || (opp.Fiscal_Quarter_To_Close__c == 1 && opp.Last_Next_Step_Updated_Date__c + 30 < System.today() && opp.Last_Next_Step_Updated_Date__c < System.Today() )) && opp.StageName != '0 - Initial Prospecting'  ){
                        //nextStepIssueMap.put(opp.Id, 'Next step needs update');
                        issueTypeSet.add('Next step needs update');
                        if(!oppIdIssueTypeMap.keySet().Contains(opp.Id))
                            oppIdIssueTypeMap.put(opp.Id, 'Next step needs update');
                        else
                            oppIdIssueTypeMap.put(opp.Id,oppIdIssueTypeMap.get(opp.id)+',Next step needs update');
                        if(!oppAdded){
                            if(userIdOpportunityMapMap.keySet().Contains(opp.OwnerId)){
                                tempOppMap = userIdOpportunityMapMap.get(opp.OwnerId);
                                tempOppMap.put(opp.Id, opp);
                                userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                            }else{
                                dataUserIdSet.add(opp.OwnerId);
                                tempOppMap.put(opp.Id, opp);
                                userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                            }

                            if(opp.Owner.ManagerId != null){
                                tempOppMap = new map<id, opportunity>();
                                if(managerIdOpportunityMapMap.keySet().Contains(opp.Owner.ManagerId)){
                                    tempOppMap = managerIdOpportunityMapMap.get(opp.Owner.ManagerId);
                                    tempOppMap.put(opp.Id, opp);
                                    managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                                }else{
                                    dataUserIdSet.add(opp.Owner.ManagerId);
                                    tempOppMap.put(opp.Id, opp);
                                    managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                                }
                            }
                            oppAdded = true;
                        }
                    }

                }else{
                    date oppCreatedDate  =date.newinstance(opp.CreatedDate.year(), opp.CreatedDate.month(), opp.CreatedDate.day());
                    if(((opp.Fiscal_Quarter_To_Close__c == 0 && oppCreatedDate + 10 < system.today() && oppCreatedDate < System.today()) || (opp.Fiscal_Quarter_To_Close__c == 1 && oppCreatedDate + 30 < System.today() && oppCreatedDate < System.Today() )) && opp.StageName != '0 - Initial Prospecting'  ){
                       // nextStepIssueMap.put(opp.Id, 'Next step needs update');
                        issueTypeSet.add('Next step needs update');
                        if(!oppIdIssueTypeMap.keySet().Contains(opp.Id))
                            oppIdIssueTypeMap.put(opp.Id, 'Next step needs update');
                        else
                            oppIdIssueTypeMap.put(opp.Id,oppIdIssueTypeMap.get(opp.id)+',Next step needs update');
                        if(!oppAdded){
                            if(userIdOpportunityMapMap.keySet().Contains(opp.OwnerId)){
                                tempOppMap = userIdOpportunityMapMap.get(opp.OwnerId);
                                tempOppMap.put(opp.Id, opp);
                                userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                            }else{
                                dataUserIdSet.add(opp.OwnerId);
                                tempOppMap.put(opp.Id, opp);
                                userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                            }

                            if(opp.Owner.ManagerId != null){
                                tempOppMap = new map<id, opportunity>();
                                if(managerIdOpportunityMapMap.keySet().Contains(opp.Owner.ManagerId)){
                                    tempOppMap = managerIdOpportunityMapMap.get(opp.Owner.ManagerId);
                                    tempOppMap.put(opp.Id, opp);
                                    managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                                }else{
                                    dataUserIdSet.add(opp.Owner.ManagerId);
                                    tempOppMap.put(opp.Id, opp);
                                    managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                                }
                            }
                            oppAdded = true;
                        }
                    }
                }
            }

            if(opp.StageName != '0 - Initial Prospecting' && opp.stageName != label.Stage_1_Alignment /*'1 - Qualified and Budgeted'*/  && opp.OpportunityPartnersFrom.size() < 1 && (opp.Type == 'New Business' || opp.Type == 'Existing Customer (Add On)')){
                //primaryPartnerIssueMap.put(opp.Id, 'Missing Primary Partner');
                issueTypeSet.add('Missing Primary Partner');
                if(!oppIdIssueTypeMap.keySet().Contains(opp.Id))
                    oppIdIssueTypeMap.put(opp.Id, 'Missing Primary Partner');
                else
                    oppIdIssueTypeMap.put(opp.Id,oppIdIssueTypeMap.get(opp.id)+',Missing Primary Partner');
                if(!oppAdded){
                    if(userIdOpportunityMapMap.keySet().Contains(opp.OwnerId)){
                        tempOppMap = userIdOpportunityMapMap.get(opp.OwnerId);
                        tempOppMap.put(opp.Id, opp);
                        userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                    }else{
                        dataUserIdSet.add(opp.OwnerId);
                        tempOppMap.put(opp.Id, opp);
                        userIdOpportunityMapMap.put(opp.OwnerId, tempOppMap);
                    }

                    if(opp.Owner.ManagerId != null){
                        tempOppMap = new map<id, opportunity>();
                        if(managerIdOpportunityMapMap.keySet().Contains(opp.Owner.ManagerId)){
                            tempOppMap = managerIdOpportunityMapMap.get(opp.Owner.ManagerId);
                            tempOppMap.put(opp.Id, opp);
                            managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                        }else{
                            dataUserIdSet.add(opp.Owner.ManagerId);
                            tempOppMap.put(opp.Id, opp);
                            managerIdOpportunityMapMap.put(opp.Owner.ManagerId, tempOppMap);
                        }
                    }
                }
            }
        }

        set<id> usrIdSet = new set<id>();
        if(userIdOpportunityMapMap != null)
            usrIdSet.addAll(userIdOpportunityMapMap.keySet());
        /*if(userIdLeadMapMap != null)
            usrIdSet.addAll(userIdLeadMapMap.keySet());
        if(userIdContactMapMap != null)
            usrIdSet.addAll(userIdContactMapMap.keySet());
        */

        string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
        boolean hasLead = false;
        boolean hasOpp = false;
        string emailBody = '';
        integer leadCount = 0;
        string leadListData = '';
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        list<Opportunity_Notification__c> oppNotificationInsertList = new list<Opportunity_Notification__c>();

        for(id usrId : usrIdSet){
            Opportunity_Notification__c tempOppNotification = new Opportunity_Notification__c();

            User usr = new User();
            usr = userMap.get(usrId);

            //if(userIdLeadMapMap.keySet().Contains(usr.Id) || userIdContactMapMap.keySet().Contains(usr.Id))
            //    hasLead = true;
            if(userIdOpportunityMapMap.keySet().Contains(usr.Id))
                hasOpp = true;
            /*if(userIdLeadMapMap.keySet().Contains(usr.Id)){
                leadCount += (userIdLeadMapMap.get(usr.Id)).keySet().Size();
                for(Lead le : (userIdLeadMapMap.get(usr.Id)).Values()){
                    Lead_Issue__c tempLeadIssue = new Lead_Issue__c();
                    tempLeadIssue.Lead__c = le.Id;
                    tempLeadIssue.Issue_Type__c = 'MQL Issue';
                    leadIssueInsertList.add(tempLeadIssue);
                    string url = sBaseURL + '/' +le.Id;
                    string sLink = '<a href=\''+ url + '\''  + '>'+le.Name+'</a>';
                    leadListData += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:#DDEBF7;\">' + userIdNameMap.get(le.OwnerId) + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +(le.Company != null ? le.Company : '')  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Title != null ? le.Title : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Status != null ? le.Status : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + le.mkto2__Lead_Score__c +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Lead_Source_Recent__c != null ? le.Lead_Source_Recent__c : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + le.MQL_Date__c.format() +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.LeadSource != null ? le.LeadSource : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Account_Manager__c != null ? le.Account_Manager__r.Name : '') +'</td></tr>' ;
                }
            }


            if(userIdContactMapMap.keySet().Contains(usr.Id)){
                leadCount += (userIdContactMapMap.get(usr.Id)).keySet().Size();
                for(Contact con : (userIdContactMapMap.get(usr.Id)).Values()){
                    Lead_Issue__c tempLeadIssue = new Lead_Issue__c();
                    tempLeadIssue.Contact__c = con.Id;
                    tempLeadIssue.Issue_Type__c = 'MQL Issue';
                    leadIssueInsertList.add(tempLeadIssue);
                    string url = sBaseURL + '/' +con.Id;
                    string sLink = '<a href=\''+ url + '\''  + '>'+con.Name+'</a>';
                    leadListData += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:#DDEBF7;\">' + userIdNameMap.get(con.OwnerId) + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +(con.Company_Name__c != null ? con.Company_Name__c : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Title != null ? con.Title : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Contact_Lead_Status__c != null ? con.Contact_Lead_Status__c : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + con.mkto2__Lead_Score__c +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Lead_Source_Recent__c != null ? con.Lead_Source_Recent__c : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + con.MQL_Date__c.format() +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.LeadSource != null ? con.LeadSource : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Account_Manager__c != null ? con.Account_Manager__r.Name : '') +'</td></tr>' ;
                }
            }
            */
            string userOppListData = '';
            integer satgeIssue = 0;
            integer closeDateIssue = 0;
            integer nextStepIssue = 0;
            integer missingPartnerIssue = 0;

            if(userIdOpportunityMapMap.keySet().Contains(usr.Id)){
                for(Opportunity opp : (userIdOpportunityMapMap.get(usr.Id)).values()){
                    string url = sBaseURL + '/' +opp.Id;
                    string sLink = '<a href=\''+ url + '\''  + '>'+Opp.Name+'</a>';
                    userOppListData += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + Opp.Owner.firstName + ' '+ opp.Owner.LastName+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\"> ' + sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (opp.Amount != null ? opp.Amount : 0)  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + opp.StageName  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + opp.CloseDate.format()+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\"> ' + oppIdIssueTypeMap.get(opp.Id)+'</td></tr>';

                    for(string issueType : oppIdIssueTypeMap.get(opp.Id).split(',')){
                        if(issueType == 'Stage not updated for more than 60 days')
                            satgeIssue +=1;
                        if(issueType == 'Close Date in Past')
                            closeDateIssue +=1;
                        if(issueType == 'Missing Primary Partner')
                            missingPartnerIssue +=1;
                        if(issueType == 'Next step needs update')
                            nextStepIssue +=1;
                    }
                }
            }


            string summTableDataWithOppAndLead = '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(usr.Id)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + satgeIssue + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + closeDateIssue  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + missingPartnerIssue + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + nextStepIssue  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + leadCount  + '</td></tr>';

            string summTableDataWithOpp = '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(usr.Id)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + satgeIssue + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + closeDateIssue  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + missingPartnerIssue + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + nextStepIssue  + '</td></tr>';

            string summTableDataWithLead = '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(usr.Id)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + leadCount + '</td></tr>';

            emailBody += emailStart + (hasOpp && hasLead ? userContentForLeadAndOpp : (hasOpp ? userContentForOpp : (hasLead ? userContentForLead : ''))) + '<br/><br/>' +  summTableStart + (hasLead && hasOpp ? (ISRSummTableHeader + summTableDataWithOppAndLead) : (hasLead ? (LDRSummTableHeader + summTableDataWithLead) : (hasOpp ? (SummTableHeaderForOpp + summTableDataWithOpp) : '') ))  + tableEnd+ '<br/><br/>' + (hasOpp ? (tableStart +  oppTableHeader + userOppListData + tableEnd) : '') + '<br/><br/>'+ (hasLead ? (tableStart + leadTableHeader + leadListData + tableEnd) : '') +emailEnd;

            tempOppNotification.Job_Id__c = jobId;
            tempOppNotification.Sales_User__c = usr.Id;
            tempOppNotification.Manager__c = usr.ManagerId;
            tempOppNotification.Close_Date_Issue_Count__c = closeDateIssue != null ? closeDateIssue : 0;
            tempOppNotification.Next_Step_Count__c = nextStepIssue != null ? nextStepIssue : 0;
            tempOppNotification.Primary_Partner_Issue_Count__c = missingPartnerIssue != null ? missingPartnerIssue : 0;
            tempOppNotification.Stage_Issue_Count__c = satgeIssue != null ? satgeIssue : 0;
            tempOppNotification.Email_Body__c = emailBody;
            tempOppNotification.Lead_Count__c = leadCount != null ? leadCount : 0;
            oppNotificationInsertList.add(tempOppNotification);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            list<string> emailIdList = new list<string>();
            list<string> ccEmailIdList = new list<string>();
            emailIdList.add(userIdEmailMap.get(usrId));
            /*if(!emailIdList.isEmpty()){
                if(emailIdList[0] == 'srobertson@zscaler.com' ||emailIdList[0] == 'WWelch@zscaler.com' ||emailIdList[0] == 'golson@zscaler.com' ||emailIdList[0] == 'mpiercy@zscaler.com' ){
                    ccEmailIdList.add('ckear@zscaler.com');
                    ccEmailIdList.add('akwong@zscaler.com');
                    ccEmailIdList.add('deastwood@zscaler.com');
                    ccEmailIdList.add('sworbey@zscaler.com');
                    ccEmailIdList.add('sajag@zscaler.com');
                    if(emailIdList[0] == 'golson@zscaler.com'){
                       ccEmailIdList.add('bfinnie@zscaler.com');
                       ccEmailIdList.add('adithya.a@zscaler.com');
                    }
                    if(emailIdList[0] == 'srobertson@zscaler.com'){
                        ccEmailIdList.add('baljeet.singh@zscaler.com');
                    }
                    mail.setCcAddresses(ccEmailIdList);
                }
            }*/
            if(!emailIdList.isEmpty()){
                Map<String, VP_team_inclusion_Opportunity_Hygiene__c> mapVPteam = VP_team_inclusion_Opportunity_Hygiene__c.getAll();
                if(mapVPteam != null && mapVPteam.keyset() != null && mapVPteam.containskey(emailIdList[0]) && mapVPteam.get(emailIdList[0]) != null && mapVPteam.get(emailIdList[0]).VP_team_email__c != null){
                    ccEmailIdList.addAll(mapVPteam.get(emailIdList[0]).VP_team_email__c.split(','));
                    mail.setCcAddresses(ccEmailIdList);
                }
            }
            mail.setToAddresses(emailIdList);
            mail.setSubject(hasLead && hasOpp ? 'Opportunity/MQL Hygiene Report' : (hasOpp ? 'Opportunity Hygiene Report' : (hasLead ? 'MQL Hygiene Report' :'Opportunity/MQL Hygiene Report')));
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail.setsenderDisplayName('Sales Ops System Admin');
            }
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setHtmlBody(emailBody);
            messageList.add(mail);
        }
        Messaging.sendEmail(messageList);
        Database.SaveResult[] srList = database.insert(oppNotificationInsertList, false) ;
        //Database.insert(leadIssueInsertList, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successlst.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(err.getMessage());
                }
            }
        }


    }

    global void finish(Database.BatchableContext context){
        set<id> allUerIdSet = new set<Id>();
        
        list<Messaging.SingleEmailMessage> messageList = new list<Messaging.SingleEmailMessage>();
        list<Opportunity_Notification__c> oppNotificationInsertList = new list<Opportunity_Notification__c>();
        string sBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
        boolean hasLead = false;
        boolean hasOpp = false;
        string emailBody = '';
        string subjectLine = '';
        map<id,list<Opportunity_Notification__c>> managerIdOppNotificationListMap = new map<id, list<Opportunity_Notification__c>>();


        list<Opportunity_Notification__c> tempOppNotificationList = new list<Opportunity_Notification__c>();
        for(Opportunity_Notification__c oppNotify : [Select Id, Manager__c, Sales_User__c, Lead_Count__c, Stage_Issue_Count__c, Close_Date_Issue_Count__c, Next_Step_Count__c, Primary_Partner_Issue_Count__c from Opportunity_Notification__c where Job_Id__c =: jobId]){
            if(oppNotify.Manager__c != null){
                tempOppNotificationList = new list<Opportunity_Notification__c>();
                if(managerIdOppNotificationListMap.keySet().Contains(oppNotify.Manager__c)){
                    tempOppNotificationList = managerIdOppNotificationListMap.get(oppNotify.Manager__c);
                    tempOppNotificationList.add(oppNotify);
                    managerIdOppNotificationListMap.put(oppNotify.Manager__c, tempOppNotificationList);
                }else{
                    tempOppNotificationList.add(oppNotify);
                    managerIdOppNotificationListMap.put(oppNotify.Manager__c, tempOppNotificationList);
                }
            }
        }

        list<Opportunity_Notification__c> managerNotificationList = new list<Opportunity_Notification__c>();
        for(id mgrId : managerIdOppNotificationListMap.keySet()){
                decimal closeDateIssueCount = 0;
                decimal satgeIssueCount = 0;
                decimal missingPartnerIssueCount = 0;
                decimal nextStepIssueCount = 0;
                decimal leadCount = 0;
                hasOpp = false;
                hasLead = false;
                emailBody = '';
                string sumDataTable = '';
                string oppDataTable = '';
                string leadDataTable = '';
                /*if(managerIdContactMapMap.keySet().Contains(mgrId) || managerIdLeadMapMap.keySet().Contains(mgrId))
                    hasLead = true;*/
                if(managerIdOpportunityMapMap.keySet().Contains(mgrId))
                    hasOpp = true;

                for(Opportunity_Notification__c oppNotification : managerIdOppNotificationListMap.get(mgrId)){
                    leadCount += oppNotification.Lead_Count__c;
                    satgeIssueCount += oppNotification.Stage_Issue_Count__c;
                    missingPartnerIssueCount += oppNotification.Primary_Partner_Issue_Count__c;
                    nextStepIssueCount += oppNotification.Next_Step_Count__c;
                    closeDateIssueCount += oppNotification.Close_Date_Issue_Count__c;
                    if(hasLead && hasOpp){
                        sumDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(oppNotification.Sales_User__c)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Stage_Issue_Count__c + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Close_Date_Issue_Count__c  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Primary_Partner_Issue_Count__c + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Next_Step_Count__c  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Lead_Count__c  + '</td></tr>';

                    }else if(hasOpp){
                        sumDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(oppNotification.Sales_User__c)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Stage_Issue_Count__c + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Close_Date_Issue_Count__c  + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Primary_Partner_Issue_Count__c + '</td> <td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Next_Step_Count__c  + '</td></tr>';
                    }else if(hasLead){
                        sumDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:#DDEBF7\">' + userIdNameMap.get(oppNotification.Sales_User__c)+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black; background-color:white;text-align: center;\"> ' + oppNotification.Lead_Count__c + '</td></tr>';
                    }
                }

                /*if(managerIdContactMapMap.keySet().Contains(mgrId)){
                     for(Contact con : (managerIdContactMapMap.get(mgrId)).values()){
                        string url = sBaseURL + '/' +con.Id;
                        string sLink = '<a href=\''+ url + '\''  + '>'+con.Name+'</a>';
                        leadDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:#DDEBF7;\">' + userIdNameMap.get(con.OwnerId) + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +(con.Company_Name__c != null ? con.Company_Name__c : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Title != null ? con.Title : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Contact_Lead_Status__c != null ? con.Contact_Lead_Status__c : '')  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + con.mkto2__Lead_Score__c +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Lead_Source_Recent__c != null ? con.Lead_Source_Recent__c : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + con.MQL_Date__c.format() +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.LeadSource != null ? con.LeadSource : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (con.Account_Manager__c != null ? con.Account_Manager__r.Name : '') +'</td></tr>' ;
                    }
                }

                if(managerIdLeadMapMap.keySet().Contains(mgrId)){
                    for(Lead le : (managerIdLeadMapMap.get(mgrID)).values()){
                        string url = sBaseURL + '/' +le.Id;
                        string sLink = '<a href=\''+ url + '\''  + '>'+le.Name+'</a>';
                        leadDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:#DDEBF7;\">' + userIdNameMap.get(le.OwnerId) + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' +(le.Company != null ? le.Company : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Title != null ? le.Title : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Status != null ? le.Status : '') + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + le.mkto2__Lead_Score__c +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Lead_Source_Recent__c != null ? le.Lead_Source_Recent__c : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + le.MQL_Date__c.format() +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.LeadSource != null ? le.LeadSource : '') +'</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (le.Account_Manager__c != null ? le.Account_Manager__r.Name : '') +'</td></tr>' ;
                    }
                }
                */
                if(managerIdOpportunityMapMap.keySet().Contains(mgrId)){
                    for(Opportunity opp : (managerIdOpportunityMapMap.get(mgrId)).values()){
                        string url = sBaseURL + '/' +opp.Id;
                        string sLink = '<a href=\''+ url + '\''  + '>'+Opp.Name+'</a>';

                        oppDataTable += '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + Opp.Owner.firstName + ' '+ opp.Owner.LastName+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\"> ' + sLink + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + (opp.Amount != null ? opp.Amount : 0)  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + opp.StageName  + '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\">' + opp.CloseDate.format()+ '</td><td style=\"border: 1px solid black;border-collapse: collapse;color:black;background-color:white;\"> ' + oppIdIssueTypeMap.get(opp.Id)+'</td></tr>';
                    }

                }
                emailBody += emailStart + (hasOpp && hasLead ? ldrManagerContent : (hasOpp ?  mgrContentForOpp : (hasLead ? mgrContentForLead : ''))) + '<br/><br/>' +  summTableStart + (hasLead && hasOpp ? (ISRSummTableHeader + sumDataTable) : (hasLead ? (LDRSummTableHeader + sumDataTable) : (hasOpp ? (SummTableHeaderForOpp + sumDataTable) : '') ))  + tableEnd+ '<br/><br/>' + (hasOpp ? (tableStart +  oppTableHeader + oppDataTable + tableEnd) : '') + '<br/><br/>'+ (hasLead ? (tableStart + leadTableHeader + leadDataTable + tableEnd) : '') +emailEnd;


                Opportunity_Notification__c tempOppNotification = new Opportunity_Notification__c();
                tempOppNotification.Sales_User__c = mgrId;
                tempOppNotification.Job_Id__c = jobId;
                tempOppNotification.Close_Date_Issue_Count__c = closeDateIssueCount;
                tempOppNotification.Next_Step_Count__c = nextStepIssueCount;
                tempOppNotification.Primary_Partner_Issue_Count__c = missingPartnerIssueCount;
                tempOppNotification.Stage_Issue_Count__c = satgeIssueCount;
                tempOppNotification.Lead_Count__c = leadCount;
                oppNotificationInsertList.add(tempOppNotification);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                list<string> emailIdList = new list<string>();
                list<string> ccEmailIdList = new list<string>();
                emailIdList.add(userIdEmailMap.get(mgrId));
                if(!emailIdList.isEmpty()){
                    Map<String, VP_team_inclusion_Opportunity_Hygiene__c> mapVPteam = VP_team_inclusion_Opportunity_Hygiene__c.getAll();
                    if(mapVPteam != null && mapVPteam.keyset() != null && mapVPteam.containskey(emailIdList[0]) && mapVPteam.get(emailIdList[0]) != null && mapVPteam.get(emailIdList[0]).VP_team_email__c != null){
                        ccEmailIdList.addAll(mapVPteam.get(emailIdList[0]).VP_team_email__c.split(','));
                        mail.setCcAddresses(ccEmailIdList);
                    }
                }
                /*if(!emailIdList.isEmpty()){
                    if(emailIdList[0] == 'srobertson@zscaler.com' ||emailIdList[0] == 'WWelch@zscaler.com' ||emailIdList[0] == 'golson@zscaler.com' ||emailIdList[0] == 'mpiercy@zscaler.com' ){
                        ccEmailIdList.add('ckear@zscaler.com');
                        ccEmailIdList.add('sajag@zscaler.com');
                        ccEmailIdList.add('akwong@zscaler.com');
                        ccEmailIdList.add('deastwood@zscaler.com');
                        ccEmailIdList.add('sworbey@zscaler.com');
                        ccEmailIdList.add('baljeet.singh@zscaler.com');
                        if(emailIdList[0] == 'golson@zscaler.com'){
                            ccEmailIdList.add('bfinnie@zscaler.com');
                            ccEmailIdList.add('adithya.a@zscaler.com');
                        }

                        mail.setCcAddresses(ccEmailIdList);
                    }
                }*/
                if(Label.Emails_to_exclude_Opportunity_Hygiene != null ){
                    for(String s: Label.Emails_to_exclude_Opportunity_Hygiene.split(',')){
                        if(emailIdList.indexOf(s) != -1){
                            emailIdList.remove(emailIdList.indexOf(s));
                        }
                    }
                }
                mail.setToAddresses(emailIdList);
                mail.setSubject(hasLead && hasOpp ? 'Opportunity/MQL Hygiene Report – Manager View' : (hasOpp ? 'Opportunity Hygiene Report – Manager View' : (hasLead ? 'MQL Hygiene Report' :'Opportunity/MQL Hygiene Report – Manager View')));
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else{
                    mail.setsenderDisplayName('Sales Ops System Admin');
                }
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setHtmlBody(emailBody);
                messageList.add(mail);
        }

        system.debug('# Heap Size : '+Limits.getHeapSize());
        system.debug('# Heap Size Limit : '+Limits.getLimitHeapSize());
        
        Database.SaveResult[] srList = database.insert(oppNotificationInsertList, false) ;
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                successlst.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    errorlst.add(err.getMessage());
                }
            }
        }
        
        if(!errorlst.isEmpty()){
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setToAddresses(new String[] {Label.BSYS_ALERT});
            if ( owea.size() > 0 ) {
                mail1.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail1.setsenderDisplayName('Sales Ops System Admin');
            }
            mail1.setSubject('Opportunity Hygiene Error result');
            mail1.setPlainTextBody('Below are the details of the records that have failed: ' + errorlst);
            
            messageList.add(mail1);
        }else{
            Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
            mail2.setToAddresses(new String[] {Label.BSYS_INFO});
            if ( owea.size() > 0 ) {
                mail2.setOrgWideEmailAddressId(owea[0].Id);
            }else{
                mail2.setsenderDisplayName('Sales Ops System Admin');
            }
            mail2.setSubject('Opportunity Hygiene success result');
            mail2.setPlainTextBody('Opportunity Hygiene Batch has been successfully executed');
            messageList.add(mail2);
        }
        Messaging.sendEmail(messageList);

    }
}