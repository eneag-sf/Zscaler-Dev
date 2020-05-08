public class NFRLicenceTriggerHandler {
    
    public Static Map<Id, RecordType> recordTyepMap = new Map<Id, RecordType>([Select Id, Name from RecordType Where sObjectType = 'NFR__c']);
    
    public static void onBeforeInsert(List<NFR__c> newNFRList){
        for(NFR__c rec : newNFRList){
            if(rec.Start_Date__c != null && recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
            }
            else if(rec.Start_Date__c != null){
                if(rec.Start_Date__c.month() == 7 || rec.Start_Date__c.month() == 8 || rec.Start_Date__c.month() == 9 || rec.Start_Date__c.month() == 10){
                    rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1,10,31);
                }
                else{
                    if(rec.Start_Date__c.month() == 11 || rec.Start_Date__c.month() == 12){
                        rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+2, 2, 28);
                    }
                    else{
                        if(rec.Start_Date__c.month() == 1 || rec.Start_Date__c.month() == 2 || rec.Start_Date__c.month() == 3){
                            rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1, 4, 30);
                        }
                        else{
                            if(rec.Start_Date__c.month() == 4 || rec.Start_Date__c.month() == 5 || rec.Start_Date__c.month() == 6){
                                rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1, 7, 31);
                            }
                            else{
                                rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void OnAfterInsert( List<NFR__c> newNFRList){
        List<NFR__c> NFRList = [Select Id
                                ,Approval_Status__c
                                ,Account_Name__r.Id
                                ,Account_Name__r.Account_Manager__r.Id
                                ,ZIA_NFR__c
                                ,ZPA_NFR__c
                                ,SIP__c
                                ,Additional_Organisation_Domain__c
                                ,NFR_SE_Email__c
                                ,Number_of_Users__c
                                ,Organisation_Domain__c
                                ,Partner_Contact__r.Id
                                ,Preferred_Cloud__c
                                ,NFR_Sales_Engineer__c
                                ,Send_Initial_Credentials_To__c
                                ,Expiry_Date_FromStartDate__c
                                ,User_Authentication_Domains__c
                                ,Is_Customer_Using_ZIA__c
                                ,Is_Zapp_used__c
                                ,Comments__c
                                ,Start_Date__c
                                ,RecordTypeId
                                From NFR__c Where id IN: newNFRList];
        List<Provisioning_Request__c> provisonRequestList = new List<Provisioning_Request__c>();
        Set<Id> NFRIds = new Set<Id>();
        for(NFR__c rec : NFRList){
            Provisioning_Request__c provRequest = new Provisioning_Request__c();
            if(rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec, 'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(rec.Approval_Status__c == 'Approved' && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec, 'SIP');
                provisonRequestList.add(provRequest);
            }
            if(rec.Approval_Status__c == 'Approved' && rec.ZPA_NFR__c == true){
                provRequest = provisionRequestCreate(rec, 'ZPA');
                provisonRequestList.add(provRequest);
            }
            if(rec.Start_Date__c != null && recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
            }
            if(rec.Expiry_Date_FromStartDate__c != null){
                NFRIds.add(rec.Id);
            }
        }
        //NFR Approved then Create PR_split_v6 (After insert)
        if(provisonRequestList.size() > 0){ 
            insert provisonRequestList;
            // if PR is 'SIP' then creating POC Product. 
            List<POC_Product__c> POCProductList = preparePOCProductList(provisonRequestList);
            if(POCProductList.size() > 0){
                insert POCProductList;
            }
        }
        //Query the Provisioning Request record related to NFR
        List<Provisioning_Request__c> Provision_RequestList = [Select Id, Provisioning_Status__c From Provisioning_Request__c Where NFR_Form_Link__c IN: NFRIds];
        for(Provisioning_Request__c provRec : Provision_RequestList){
            provRec.Provisioning_Status__c = 'Request Decommission';
        }
        //NFR Expired update PR status
		if(Provision_RequestList.size()>0){
            update Provision_RequestList;
        }
    }
    
    public static void OnAfterUpdate(List<NFR__c> newNFRList, Map<ID, NFR__c> oldNFRMap){
        List<NFR__c> NFRList = [Select Id
                                ,Approval_Status__c
                                ,Account_Name__r.Id
                                ,Account_Name__r.Account_Manager__r.Id
                                ,Account_Name__r.ownerId
                                ,ZIA_NFR__c
                                ,ZPA_NFR__c
                                ,SIP__c
                                ,Additional_Organisation_Domain__c
                                ,NFR_SE_Email__c
                                ,Partner_Email__c
                                ,Number_of_Users__c
                                ,Organisation_Domain__c
                                ,Partner_Contact__r.Id
                                ,Preferred_Cloud__c
                                ,NFR_Sales_Engineer__c
                                ,Send_Initial_Credentials_To__c
                                ,Expiry_Date_FromStartDate__c
                                ,NFR_Licence_Status__c
                                ,User_Authentication_Domains__c
                                ,Is_Customer_Using_ZIA__c
                                ,Is_Zapp_used__c
                                ,Comments__c
                                ,RecordTypeId
                                From NFR__c Where id IN: newNFRList];
        
        List<Provisioning_Request__c> provisonRequestList = new List<Provisioning_Request__c>();
        Set<Id> statusChangedNFRIds = new Set<Id>();
        Set<Id> statusExpairedNFRIds = new Set<Id>();
        
        for(NFR__c rec : NFRList){
            Provisioning_Request__c provRequest = new Provisioning_Request__c();
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec,'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved' && rec.ZIA_NFR__c == true){
                provRequest = provisionRequestCreate(rec,'ZIA');
                provisonRequestList.add(provRequest);
            }
            else if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved' && rec.SIP__c == true){
                provRequest = provisionRequestCreate(rec,'SIP');
                provisonRequestList.add(provRequest);
            }
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved' && rec.ZPA_NFR__c == true){
                provRequest = provisionRequestCreate(rec,'ZPA');
                provisonRequestList.add(provRequest);
            }
            //getting NFR id's if licence status equal to Expired
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'Expired'){
                statusExpairedNFRIds.add(rec.Id);
            }
            //NFR Extension: Checking licence status if is changed to 'In-Progress' then collecting the NFR Id's and Send Email extension.
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'In-Progress'){
                statusChangedNFRIds.add(rec.Id);
            }
        }
        //NFR Approved then Create PR_split_v6 (After update)
        if(provisonRequestList.size() > 0){
            insert provisonRequestList;
            // if PR is 'SIP' then creating POC Product. 
            List<POC_Product__c> POCProductList = NFRLicenceTriggerHelper.preparePOCProductList(provisonRequestList);
            if(POCProductList.size() > 0){
                insert POCProductList;
            }
        }
        /***Query the Provisioning Request record related to NFR**/
        //NFR Expired update PR status
        //updateProvisioningStatus(NFRIds, 'Request Decommission');
        //NFR Extension: Checking licence status if is changed to 'In-Progress' then update the Provisioning status.
        updateProvisioningStatus(statusChangedNFRIds, 'Extended');
        //NFR licence status equal to Expired update PR status
        updateProvisioningStatus(statusExpairedNFRIds, 'Request Decommission');
        //Send mails
        //messaging.sendEmail(mails);
    }
    
    public static void OnBeforeUpdate(List<NFR__c> newNFRList,Map<ID, NFR__c> oldNFRMap){
        
        Set<Id> statusChangedNFRIds = new Set<Id>();
        
        for(NFR__c rec : newNFRList){
            if(oldNFRMap.get(rec.Id).Start_Date__c != rec.Start_Date__c && rec.Start_Date__c != null){
                if(rec.Start_Date__c != null && recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                    rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
                }
                else if(rec.Start_Date__c != null){
                    if(rec.Start_Date__c.month() == 7 || rec.Start_Date__c.month() == 8 || rec.Start_Date__c.month() == 9 || rec.Start_Date__c.month() == 10){
                        rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1,10,31);
                    }
                    else{
                        if(rec.Start_Date__c.month() == 11 || rec.Start_Date__c.month() == 12){
                            rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+2, 2, 28);
                        }
                        else{
                            if(rec.Start_Date__c.month() == 1 || rec.Start_Date__c.month() == 2 || rec.Start_Date__c.month() == 3){
                                rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1, 4, 30);
                            }
                            else{
                                if(rec.Start_Date__c.month() == 4 || rec.Start_Date__c.month() == 5 || rec.Start_Date__c.month() == 6){
                                    rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Start_Date__c.year()+1, 7, 31);
                                }
                                else{
                                    rec.Expiry_Date_FromStartDate__c = rec.Start_Date__c.addMonths(12);
                                }
                            }
                        }
                    }
                }
            }
            
            //NFR Extension: Checking licence status if is changed to 'In-Progress' then update the Expiry date,licence status and Number of Extension.
            if(oldNFRMap.get(rec.Id).NFR_Licence_Status__c != rec.NFR_Licence_Status__c && rec.NFR_Licence_Status__c == 'In-Progress'){
                
                statusChangedNFRIds.add(rec.Id);
                rec.Send_Extension_Email__c	= true;
                //rec.NFR_Licence_Status__c = 'Active';
                rec.NFR_Licence_Status__c = 'Acive';
                if(rec.Number_of_Extensions__c != null){
                    rec.Number_of_Extensions__c = rec.Number_of_Extensions__c + 1;
                }
                else{
                    rec.Number_of_Extensions__c = 1;
                }
                if(rec.Expiry_Date_FromStartDate__c != null){
                    
                    if(recordTyepMap.get(rec.RecordTypeId).Name != 'Technology Partners'){
                    
                        if(rec.Expiry_Date_FromStartDate__c.month() == 7 || rec.Expiry_Date_FromStartDate__c.month() == 8 || rec.Expiry_Date_FromStartDate__c.month() == 9 || rec.Expiry_Date_FromStartDate__c.month() == 10){
                            rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Expiry_Date_FromStartDate__c.year()+1,10,31);
                        }
                        else{
                            if(rec.Expiry_Date_FromStartDate__c.month() == 11 || rec.Expiry_Date_FromStartDate__c.month() == 12){
                                rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Expiry_Date_FromStartDate__c.year()+2, 2, 28);
                            }
                            else{
                                if(rec.Expiry_Date_FromStartDate__c.month() == 1 || rec.Expiry_Date_FromStartDate__c.month() == 2 || rec.Expiry_Date_FromStartDate__c.month() == 3){
                                    rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Expiry_Date_FromStartDate__c.year()+1, 4, 30);
                                }
                                else{
                                    if(rec.Expiry_Date_FromStartDate__c.month() == 4 || rec.Expiry_Date_FromStartDate__c.month() == 5 || rec.Expiry_Date_FromStartDate__c.month() == 6){
                                        rec.Expiry_Date_FromStartDate__c = Date.newInstance(rec.Expiry_Date_FromStartDate__c.year()+1, 7, 31);
                                    }
                                    else{
                                        rec.Expiry_Date_FromStartDate__c = rec.Expiry_Date_FromStartDate__c.addMonths(12);
                                    }
                                }
                            }
                        }
                    }
                    else{
                        rec.Expiry_Date_FromStartDate__c = rec.Expiry_Date_FromStartDate__c.addMonths(12);
                    }
                }
            }
            
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Approved'){
                if(recordTyepMap.get(rec.RecordTypeId).Name == 'Technology Partners'){
                    rec.Expiry_Date_FromStartDate__c = system.today().addMonths(12);
                }
            }
            
            if(oldNFRMap.get(rec.Id).Approval_Status__c != rec.Approval_Status__c && rec.Approval_Status__c == 'Submitted'){
                rec.Submitted_by__c = UserInfo.getUserId();
            }
            updateProvisioningStatus(statusChangedNFRIds, 'Extended');
        }
    } 
    
    public static Provisioning_Request__c provisionRequestCreate(NFR__c rec, String NFRType){
        
        Id NFRRecordTypeId = Schema.SObjectType.Provisioning_Request__c.getRecordTypeInfosByName().get('NFR Licence').getRecordTypeId();
        Provisioning_Request__c provRequest = new Provisioning_Request__c();
        provRequest.Account_Manager__c = rec.Account_Name__r.Account_Manager__r.Id;
        provRequest.Account__c = rec.Account_Name__r.Id;
        provRequest.Additional_Organization_domains__c = rec.Additional_Organisation_Domain__c;
        provRequest.NFR_Form_Link__c = rec.Id;
        provRequest.NFR_SE_Email_PR__c = rec.NFR_SE_Email__c;
        provRequest.Number_of_Users__c = rec.Number_of_Users__c;
        provRequest.Organization_Domain__c = rec.Organisation_Domain__c;
        provRequest.Partner_Contact__c = rec.Partner_Contact__r.Id;
        provRequest.Preferred_Cloud__c = rec.Preferred_Cloud__c;
        provRequest.Provisioning_Status__c = 'Requested';
        provRequest.RecordTypeId = NFRRecordTypeId;
        provRequest.SE__c = rec.NFR_Sales_Engineer__c;
        provRequest.Eval_Comments__c = rec.Comments__c;
        
        if(NFRType == 'SIP'){
            provRequest.SIP_NFR__c = TRUE;
        }
        else{
            if(NFRType == 'ZIA'){
                provRequest.ZIA_NFR__c = TRUE;
            }
            if(NFRType == 'ZPA'){
                provRequest.ZPA_NFR__c = TRUE;
            }
            provRequest.User_Authentication_Domains__c = rec.User_Authentication_Domains__c;
            provRequest.Is_Customer_Using_ZIA__c = rec.Is_Customer_Using_ZIA__c;
            provRequest.Is_Zapp_used__c = rec.Is_Zapp_used__c;
        }
        provRequest.Send_Initial_l__c = rec.Send_Initial_Credentials_To__c;
        return provRequest;
    }
    
    public static void updateProvisioningStatus(set<id> NFRIds, String status){
        List<Provisioning_Request__c> Provision_RequestList = [Select Id, Provisioning_Status__c From Provisioning_Request__c Where NFR_Form_Link__c IN: NFRIds];
        for(Provisioning_Request__c provRec : Provision_RequestList){
            provRec.Provisioning_Status__c = status;
        }
        update Provision_RequestList;
    }
    public static list<POC_Product__c> preparePOCProductList(List<Provisioning_Request__c> prList){
        List<POC_Product__c> pocProductList = new List<POC_Product__c>();
        List<product2> productList = [Select Id, Product_SKU_External_ID__c From product2 Where Product_SKU_External_ID__c = 'ZSC-SIP'];
        if(productList.size() > 0){
            product2 productRecord = productList[0];
            for(Provisioning_Request__c PRrec : prList){
                if(PRrec.SIP_NFR__c == true){
                    POC_Product__c POCRecord = new POC_Product__c();
                    POCRecord.Product__c = productRecord.Id;
                    POCRecord.Provisioning_Request__c = PRrec.Id;
                    pocProductList.add(POCRecord);
                }
            }
        }
        return pocProductList;
    }
}