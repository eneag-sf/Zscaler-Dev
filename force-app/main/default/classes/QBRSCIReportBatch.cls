/*****************************************************************************************
Name: QBRSCIReportBatch
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Batch class to notify Customer Advocacy team to add attachments to QBR SCIs
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Vijay Prakash P J     06-Jun-2017      Initial Development
******************************************************************************************/
global class QBRSCIReportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    public static final String emailStart = '<html><body>';
    public static final String emailEnd = '</body></html>';
    public static final String tableStart = '<table width=\"80%\" style=\"border: 1px solid black;border-collapse: collapse;\" >';
    public static final String tableEnd = '</table>';
    public static final String tableRowStart = '<tr>';
    public static final String tableRowEnd = '</tr>';
    public static final String tableCellStart = '<td style=\"border: 1px solid black;border-collapse: collapse;\">';
    public static final String tableCellEnd = '</td>';
    public static final String tableHeader = '<tr><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>SCI Number</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Account</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Type</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Date of Meeting</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Interaction With</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Primary Topic Covered</b></td><td style=\"border: 1px solid black;border-collapse: collapse;color:white;background-color: #002060;text-align: left;\"><b>Owner</b></td></tr>';

    Map<Id, User> mapUserDetails = new Map<Id, User>();
    Map<Id, Id> mapUserManager = new Map<Id, Id>();
    Map<Id, List<Id>> mapManagerUsers = new Map<Id, List<Id>>();
    Map<Id, Significant_Customer_Interaction__c> mapSCIs = new Map<Id, Significant_Customer_Interaction__c>();
    Map<Id, List<Id>> mapOwnerSCIIds = new Map<Id, List<Id>>();
    Map<Id, List<Id>> mapManagerSCIIds = new Map<Id, List<Id>>();
    Set<Id> setAllSCIs = new Set<Id>();

    List<Id> lstSCIsToReport = new List<Id>();
    
    global QBRSCIReportBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select Id, Department, ManagerId, Manager.Email, Manager.Department, Email, Name, Manager.Name from User Where isActive =: true AND Department = 'Customer Advocacy']);
    }

    global void execute(Database.BatchableContext BC, List<sObject> users) {
        List<Id> lstUserIdsToQuery = new List<Id>();
        
        List<Significant_Customer_Interaction__c> lstSCIs = new List<Significant_Customer_Interaction__c>();
        for (User user : (List<User>)users) {
            lstUserIdsToQuery.add(user.Id);
            mapUserDetails.put(user.Id, user);
            if (null != user.ManagerId) {
                mapUserManager.put(user.Id, user.ManagerId);
                if (mapManagerUsers.containsKey(user.ManagerId)) {
                    mapManagerUsers.get(user.ManagerId).add(user.Id);
                } else {
                    mapManagerUsers.put(user.ManagerId, new List<Id>{ user.Id });
                }
            }
        }

        for (User manager : [SELECT Id, Department, ManagerId, Manager.Email, Manager.Department, 
                                    Email, Name, Manager.Name 
                               FROM User WHERE IsActive =: true 
                                AND Name <> 'Matt Piercy' AND Name <> 'Gary Olson' 
                                AND Name <> 'Scott Robertson' AND Id IN :mapManagerUsers.keySet()]) {
            mapUserDetails.put(manager.Id, manager);
        }

        for (Significant_Customer_Interaction__c sciDetail : [SELECT Id, Name, RecordType.Id, RecordType.Name, RecordType.DeveloperName,  OwnerId, Owner.Name,
                                                                     Date__c, Interaction_With__c, Primary_Topic_Covered__c, 
                                                                     Account_Name__c, Account_Name__r.Name
                                                                FROM Significant_Customer_Interaction__c 
                                                               WHERE RecordType.DeveloperName = 'QBR' AND OwnerId IN :lstUserIdsToQuery AND Is_Created_Current_Quarter__c =: true]) {
            lstSCIs.add(sciDetail);
            setAllSCIs.add(sciDetail.Id);
            mapSCIs.put(sciDetail.Id, sciDetail);
        }


        for (AggregateResult aggRes : [SELECT ParentId FROM Attachment 
                                        WHERE ParentId IN :lstSCIs GROUP BY ParentId]) {
            if (setAllSCIs.contains((Id)aggRes.get('ParentId'))) {
                setAllSCIs.remove((Id)aggRes.get('ParentId'));
            }
        }

        for (Id sciId : mapSCIs.keySet()) {
            if (mapOwnerSCIIds.containsKey(mapSCIs.get(sciId).OwnerId)) {
                mapOwnerSCIIds.get(mapSCIs.get(sciId).OwnerId).add(mapSCIs.get(sciId).Id);
            } else {
                mapOwnerSCIIds.put(mapSCIs.get(sciId).OwnerId, new List<Id> { mapSCIs.get(sciId).Id });
            }

            if (mapUserManager.containsKey(mapSCIs.get(sciId).OwnerId)) {
                if (mapManagerSCIIds.containsKey(mapUserManager.get(mapSCIs.get(sciId).OwnerId))) {
                    mapManagerSCIIds.get(mapUserManager.get(mapSCIs.get(sciId).OwnerId)).add(sciId);
                } else {
                    mapManagerSCIIds.put(mapUserManager.get(mapSCIs.get(sciId).OwnerId), new List<Id> { sciId });
                }
            }
        }

        //System.debug('>>>> setAllSCIs having attachment:' + JSON.serialize(setAllSCIs));
        
        //Construct the emails to be sent to SCI Owners
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = System.URL.getSalesforceBaseURL().toExternalForm();
        for (Id ownerId : mapOwnerSCIIds.keySet()) {
            String emailBody = '';

            emailBody += emailStart;
            emailBody += 'Actual To: ' + mapUserDetails.get(ownerId).Email + '<br><br>';

            //Email Intro
            emailBody += 'Hello ' + mapUserDetails.get(ownerId).Name + ',';
            emailBody += '<br><br>';
            emailBody += 'Below are the list of QBR Significant Customer Interactions you own and does not have attachment:<br><br>';
            emailBody += tableStart + tableHeader;

            //Prepare the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { mapUserDetails.get(ownerId).Email }); //mapUserDetails.get(ownerId).Email });
            email.setSubject('Action Required: QBR SCIs Report');
            email.setSenderDisplayName('Sales Ops System Admin');
            email.setBccSender(false);
            email.setUseSignature(false);
            //email.setHtmlBody('>>>> ' + setAllSCIs);
            
            Boolean hasSCIsToReport = false;
            for (Id sciId : mapOwnerSCIIds.get(ownerId)) {
                if (setAllSCIs.contains(sciId)) {
                    emailBody += tableRowStart;
                    emailBody += tableCellStart + '<a href="' + (baseUrl + '/' + sciId) + '">' + mapSCIs.get(sciId).Name + '</a>' + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Account_Name__r.Name + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).RecordType.Name + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Date__c.format() + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Interaction_With__c + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Primary_Topic_Covered__c + tableCellEnd;
                    emailBody += tableCellStart + mapUserDetails.get(ownerId).Name + tableCellEnd;
                    emailBody += tableRowEnd;

                    hasSCIsToReport = true;
                }
            }

            emailBody += tableEnd;

            if (!hasSCIsToReport) {
                continue;
            }

            emailBody += '<br>' + 'Regards,' + '<br>' + 'Sales Ops Team';
            emailBody += emailEnd;
            email.setHtmlBody(emailBody);
            lstEmails.add(email);
        }

        Messaging.sendEmail(lstEmails);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('>>>> mapSCIs.keySet():' + mapSCIs.keySet());
        List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = System.URL.getSalesforceBaseURL().toExternalForm();

        //Construct the emails to be sent to SCI Owners' Managers
        for (Id managerId : mapManagerSCIIds.keySet()) {
            //Skip processing if the manager's user details is not available.
            if (!mapUserDetails.containsKey(managerId)) {
                continue;
            }

            String emailBody = '';

            emailBody += emailStart;
            //emailBody += 'Actual To: ' + mapUserDetails.get(managerId).Email + '<br><br>';

            //Email Intro
            emailBody += 'Hello ' + mapUserDetails.get(managerId).Name + ',';
            emailBody += '<br><br>';
            emailBody += 'Below are the list of QBR Significant Customer Interactions owned by your team member and does not have attachment: Please work with them to address the gap.<br><br>';
            emailBody += tableStart + tableHeader;

            //Prepare the email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> { mapUserDetails.get(managerId).Email });
            email.setSubject('Manager\'s View: QBR SCIs Report');
            email.setSenderDisplayName('Sales Ops System Admin');
            email.setBccSender(false);
            email.setUseSignature(false);
            
            Boolean hasSCIsToReport = false;
            for (Id sciId : mapManagerSCIIds.get(managerId)) {
                if (setAllSCIs.contains(sciId)) {
                    emailBody += tableRowStart;
                    emailBody += tableCellStart + '<a href="' + (baseUrl + '/' + sciId) + '">' + mapSCIs.get(sciId).Name + '</a>' + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Account_Name__r.Name + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).RecordType.Name + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Date__c.format() + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Interaction_With__c + tableCellEnd;
                    emailBody += tableCellStart + mapSCIs.get(sciId).Primary_Topic_Covered__c + tableCellEnd;
                    emailBody += tableCellStart + mapUserDetails.get(mapSCIs.get(sciId).OwnerId).Name + tableCellEnd;
                    emailBody += tableRowEnd;

                    hasSCIsToReport = true;
                }
            }

            emailBody += tableEnd;

            if (!hasSCIsToReport) {
                continue;
            }

            emailBody += '<br>' + 'Regards,' + '<br>' + 'Sales Ops Team';
            emailBody += emailEnd;
            email.setHtmlBody(emailBody);
            lstEmails.add(email);
        }

        Messaging.sendEmail(lstEmails);
    }
    
}