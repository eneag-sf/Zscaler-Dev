trigger APTS_EquipmentRequest_Trigger on Equipment_Request__c (after insert, after update) {

    Map<Id, Opportunity> optty = new Map<Id, Opportunity>();
    Map<Id, Opportunity> opttytoUpdate = new Map<Id, Opportunity>();
    Map<Id, Deal_Reg__c> drMap = new Map<Id, Deal_Reg__c>();
    Set<Id> opportunitiesNotToUpdate = new Set<Id>();

    Id meRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Middle_Eastern_Approval').getRecordTypeId();
    Id meAppReqRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Middle_Eastern_Approval_Requested').getRecordTypeId();
    Id dlpZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('DLP_ZEN').getRecordTypeId();
    Id pZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('PZEN').getRecordTypeId();
    Id pZenwithLBRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Private_ZEN_with_LB').getRecordTypeId();
    Id vZenRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Virtual_ZEN').getRecordTypeId();
    Id fedOppRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('FedRAMP_Cloud_Services').getRecordTypeId();
    Id fedDRRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('FedRAMP_Cloud_Services_Deal_Reg').getRecordTypeId();
    Id serviceedgePZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_PZEN').getRecordTypeId();
    Id serviceedgeVZENRecordTypeId = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('ZIA_Service_Edge_VZEN').getRecordTypeId();
    //Id caviumcardER = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Cavium_Card').getRecordTypeId();
    Id psRecordType = Schema.SObjectType.Equipment_Request__c.getRecordTypeInfosByDeveloperName().get('Professional_Services').getRecordTypeId();
    
    Set<Id> opptySet = new Set<Id>();
    for (Equipment_Request__c ER : Trigger.new) {
        if(ER.Opportunity__c != null){
            opptySet.add(ER.Opportunity__c);
        }
    }
    if(Trigger.isAfter && trigger.isInsert){
        for (Opportunity oppty : [SELECT Id, StageName FROM Opportunity WHERE Id IN :opptySet]) {
            if (oppty.StageName == Label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/
                || oppty.StageName == Label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/
                || oppty.StageName == Label.Stage_7_Closed_Lost /*'11 - Closed Lost'*/
                /*|| oppty.StageName == '12 - Closed With No Decision'
                || oppty.StageName == '14 - Closed: Delete Duplicate'
                || oppty.StageName == '15 - Subscription Payments-FINANCE ONLY'*/) {
                opportunitiesNotToUpdate.add(oppty.Id);
            }
        }

        for (Equipment_Request__c ER : Trigger.new) {
            if (ER.RecordTypeId == psRecordType && ER.Opportunity__c != null 
                && !opportunitiesNotToUpdate.contains(ER.Opportunity__c)) {
                    Opportunity o = new Opportunity();
                    if(opttytoUpdate.containskey(ER.Opportunity__c))
                        o = opttytoUpdate.get(ER.Opportunity__c);
                    else
                        o.Id = ER.Opportunity__c;

                o.Professional_Service_Request_Submitted__c = true;
                opttytoUpdate.put(o.Id, o);
            }
        }
        if (!opttytoUpdate.isEmpty()) {
            update opttytoUpdate.values();
        }
    }
    if(Trigger.isAfter && trigger.isUpdate){
        for (Opportunity oppty : [SELECT Id, StageName FROM Opportunity WHERE Id IN :opptySet]) {
            if (oppty.StageName == Label.Stage_6_Closed_Won /*'13 - Closed & Approved By Finance'*/
                || oppty.StageName == Label.Stage_5_Contracts_Complete /*'10b - PO recd, pending finance approval'*/
                || oppty.StageName == Label.Stage_7_Closed_Lost /*'11 - Closed Lost'*/
                /*|| oppty.StageName == '12 - Closed With No Decision'
                || oppty.StageName == '14 - Closed: Delete Duplicate'
                || oppty.StageName == '15 - Subscription Payments-FINANCE ONLY'*/) {
                opportunitiesNotToUpdate.add(oppty.Id);
            }
        }

        for (Equipment_Request__c ER : Trigger.new) {
            Equipment_Request__c oldER = Trigger.oldMap.get(ER.Id);
            if ((ER.Approval_Status__c == 'Approved' /*|| ER.Approval_Status__c == 'Approved for Quoting'*/) && ER.Opportunity__c != null 
                && !opportunitiesNotToUpdate.contains(ER.Opportunity__c)) {
                if (oldER.Approval_Status__c != 'Approved') {
                    Opportunity o = new Opportunity();
                    if(optty.keySet().Contains(ER.Opportunity__c))
                        o = optty.get(ER.Opportunity__c);
                    else
                        o.Id = ER.Opportunity__c;

                    if(meRecordTypeId == er.RecordTypeId
                        || meAppReqRecordTypeId == er.RecordTypeId) {
                        o.Approved_Pzen_ME__c = true;
                    } if (dlpZenRecordTypeId == er.RecordTypeId) {
                        o.Approved_DLP_PZEN_ER__c = true;
                    }else if(pZenRecordTypeId == er.RecordTypeId || pZenwithLBRecordTypeId == er.RecordTypeId || serviceedgePZENRecordTypeId == er.RecordTypeId){
                        o.Approved_Equipment_Request__c = true;
                    }else if(vZenRecordTypeId == er.RecordTypeId || serviceedgeVZENRecordTypeId ==er.RecordtypeId){
                        o.Approved_Equipment_Request_VZEN__c = true;
                    }/*else if(caviumcardER == er.RecordTypeId){
                        o.Approved_Cavium_Card_Equipment_Request__c = true;
                    }*/
                optty.put(o.Id, o);
                }
            }
            if(oldER.Federal_Deal_Approved_EQ__c != ER.Federal_Deal_Approved_EQ__c){
                if(ER.Opportunity__c != null){
                    Opportunity o = new Opportunity();
                    if(optty.keySet().Contains(ER.Opportunity__c))
                        o = optty.get(ER.Opportunity__c);
                    else
                        o.Id = ER.Opportunity__c;
                    if(fedOppRecordTypeId == er.RecordTypeId){
                        o.Federal_Deal_Approved_OP__c = ER.Federal_Deal_Approved_EQ__c;
                    }
                    optty.put(o.Id, o);
                }else if(ER.Deal_Registration__c != null){
                    Deal_Reg__c dr = new Deal_Reg__c();
                    if(drMap.keySet().Contains(ER.Deal_Registration__c))
                        dr = drMap.get(ER.Deal_Registration__c);
                    else
                        dr.Id = ER.Deal_Registration__c;
                    if(fedDRRecordTypeId == er.RecordTypeId){
                        dr.Federal_Deal_Approved_OP__c = ER.Federal_Deal_Approved_EQ__c;
                    }
                    drMap.put(dr.Id, dr);
                }
            }
            
        }
        if (!optty.isEmpty()) {
            update optty.values();
        }
        
        if (!drMap.isEmpty()) {
            update drMap.values();
        }
    }
}