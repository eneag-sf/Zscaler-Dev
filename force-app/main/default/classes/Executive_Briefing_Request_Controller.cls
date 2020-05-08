public class Executive_Briefing_Request_Controller {
    
    @AuraEnabled
    public static DataWrapper getData(String oppId, String ebId,string AccountId){
        DataWrapper wrp = new DataWrapper();
        String OppAccountId = '';
        List<Opportunity> opplst = new list<Opportunity>();
        if(oppId != null && oppId != ''){
            opplst= [Select Id, AccountId,Account.Name, StageName, TCV__c, Type, Amount, Owner.name, closedate,Why_Buy_Anything__c,Why_Buy_Now__c,Why_Buy_Zscaler__c, (Select Id, Product2.Name, ProductCode from OpportunityLineItems), (Select Id, Role, ContactId from OpportunityContactRoles) from Opportunity where id=:oppId];
        }
         
        if(!opplst.isEmpty()){
            wrp.opp = opplst[0];
            wrp.prodvals = '';
            for(OpportunityLineItem op: opplst[0].OpportunityLineItems){
                if(wrp.prodvals != ''){
                    if(!String.valueOf(wrp.prodvals).Contains(String.valueOf(op.Product2.Name))){
                        wrp.prodvals += ', ';
                    }
                }
                if(!String.valueOf(wrp.prodvals).Contains(String.valueOf(op.Product2.Name))){
                    wrp.prodvals += op.Product2.Name;
                }
            }
            ZForecastingDataModel.FiscalQuarterInfo closedateqtr = new ZForecastingDataModel.FiscalQuarterInfo(opplst[0].Closedate);
            ZForecastingDataModel.FiscalQuarterInfo todayqtr = new ZForecastingDataModel.FiscalQuarterInfo();
            wrp.currQtr = closedateqtr.FormattedString == todayqtr.FormattedString ? 'Yes': 'No';
            
            for(OpportunityContactRole ocr: opplst[0].OpportunityContactRoles){
                if(ocr.Role == 'Champion (Business)'/* || ocr.Role == 'Champion (Technical)'*/){
                    wrp.Champion = ocr.ContactId;
                }else if(ocr.Role == 'Champion (Technical)'){
                    wrp.Champion = ocr.ContactId;
                }
                if(ocr.Role == 'Economic Buyer'){
                    wrp.econBuyer = ocr.ContactId;
                }
            }
            if(opplst[0].AccountId != null){
                wrp.AccountRec = [select Id,Name,Current_ARR__c,No_of_Employees_Users__c,Customer_Sentiment__c,Success_Stage__c,Zscaler_Customer_Summary__c from Account Where Id=:opplst[0].AccountId];
            }
            
            OppAccountId = opplst[0].AccountId;
            
        }
        
        if((AccountId != null && AccountId != '') || OppAccountId != ''){
            List<Contract_Detail__c> ContractDetails = new List<Contract_Detail__c>();
            
            //Added by Viral
            System.debug('AccountId ::'+AccountId);
            if(AccountId != null && String.isNotEmpty(AccountId)){
            	wrp.AccountRec = [select Id,Name,Current_ARR__c,No_of_Employees_Users__c,Customer_Sentiment__c,Success_Stage__c,Zscaler_Customer_Summary__c from Account Where Id=:AccountId];
            }
            
            if(AccountId != null && AccountId != ''){
                ContractDetails = [select Id,Product_Name__c,Product_Name__r.Name from Contract_Detail__c Where Account_Name__c = :AccountId];
            }else if(OppAccountId != ''){
                ContractDetails = [select Id,Product_Name__c,Product_Name__r.Name from Contract_Detail__c Where Account_Name__c = :OppAccountId];
            }
            
            if(ContractDetails.size()>0){
                wrp.InstallBase = '';
                for(Contract_Detail__c ConDetail:ContractDetails){
                    
                    if(wrp.InstallBase != '' && ConDetail.Product_Name__c != null){
                        if(!String.valueOf(wrp.InstallBase).Contains(String.valueOf(ConDetail.Product_Name__r.Name))){
                            wrp.InstallBase += ', ';
                        }
                    }
                    
                    if(ConDetail.Product_Name__c != null){
                        system.debug(wrp.InstallBase+'Install-----Product'+ConDetail.Product_Name__r.Name+'---contains---'+String.valueOf(wrp.InstallBase).Contains(String.valueOf(ConDetail.Product_Name__r.Name)));
                        if(!String.valueOf(wrp.InstallBase).Contains(String.valueOf(ConDetail.Product_Name__r.Name))){
                            wrp.InstallBase += ConDetail.Product_Name__r.Name;
                        }
                    }   
                }
            }
        }
        
        if(ebId != null && ebId != ''){
            wrp.intAttlst = [Select Id, user__c, user__r.Name, user__r.email, user__r.title from Executive_Briefing_Internal_Attendees__c where Executive_Briefing_Request__c = :ebId];
            wrp.extAttlst = [Select Id, Attendee__c, Attendee__r.Name, Attendee__r.email, Attendee__r.Head_of_IT__c, Attendee__r.Head_of_Networking__c, Attendee__r.Head_of_Security__c from Executive_Briefing_External_Attendees__c where Executive_Briefing_Request__c = :ebId];
            wrp.EventBriefingReq = [select Id,Is_Meeting_Confirmed__c,Start_Time__c,End_Time__c,Date_of_Meeting__c,Approval_Status__c from Executive_Briefing_Request__c where Id=:ebId];
        }
        return wrp;
    }
    
    @AuraEnabled
    public static void saveintattendees(String userList, String ebId){
        Set<Id> usridstoExclude = new Set<Id>();
        String internalatt = '';
        List<InternalAttendee> wrapperList = (List<InternalAttendee>) JSON.deserialize(userList, List<InternalAttendee>.class);
        List<Executive_Briefing_Internal_Attendees__c> ebilst = new List<Executive_Briefing_Internal_Attendees__c>();
        for(InternalAttendee ia: wrapperList){
            Executive_Briefing_Internal_Attendees__c rec = new Executive_Briefing_Internal_Attendees__c();
            rec.user__c = ia.id;
            rec.Executive_Briefing_Request__c = ebId;
            ebilst.add(rec);
            usridstoExclude.add(ia.id);
            internalatt += ia.name +  ';';
        } 
        delete [Select Id from Executive_Briefing_Internal_Attendees__c  where Executive_Briefing_Request__c = :ebId];
        insert ebilst ;

        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(id=ebId);
        eb.Internal_Attendees__c = internalatt;
        update eb;

    }
    @AuraEnabled
    public static void saveextattendees(String conlst, String ebId){
        Set<Id> idstoExclude = new Set<Id>();
        List<ExternalAttendee> wrapperList = (List<ExternalAttendee>) JSON.deserialize(conlst, List<ExternalAttendee>.class);
        List<Executive_Briefing_External_Attendees__c> ebilst = new List<Executive_Briefing_External_Attendees__c>();
        for(ExternalAttendee ia: wrapperList){
            Executive_Briefing_External_Attendees__c rec = new Executive_Briefing_External_Attendees__c();
            rec.Attendee__c = ia.id;
            rec.Executive_Briefing_Request__c = ebId;
            ebilst.add(rec);
            idstoExclude.add(ia.id);
        } 
        delete [Select Id from Executive_Briefing_External_Attendees__c  where Executive_Briefing_Request__c = :ebId];
        insert ebilst;
        
        List<Contact> cLevelContacts = [Select Id from Contact Where Id IN: idstoExclude and Job_Level__c = 'C-Level']; 
        
        User userRecord = [Select Id, ManagerId from User Where Id =: userinfo.getUserId()];
        
        Executive_Briefing_Request__c eb = new Executive_Briefing_Request__c(id=ebId);
        if(userRecord.ManagerId != null){
            eb.Owner_Manager__c = userRecord.ManagerId;
        }
        if(!cLevelContacts.isEmpty()){
            eb.Has_C_Level_Attendees__c = true;
        }
        eb.Allow_Approval__c = true;
        update eb;
    }
    
    public class DataWrapper {
        @AuraEnabled
        public Opportunity opp;
        @AuraEnabled
        public string prodvals;
        @AuraEnabled
        public Id Champion;
        @AuraEnabled
        public Id econBuyer;
        @AuraEnabled
        public String currQtr;
        @AuraEnabled
        public List<Executive_Briefing_Internal_Attendees__c> intAttlst;
        @AuraEnabled
        public List<Executive_Briefing_External_Attendees__c> extAttlst;
        @AuraEnabled
        public Executive_Briefing_Request__c EventBriefingReq {get;set;}
        @AuraEnabled
        public Account AccountRec{get;set;}
        @AuraEnabled
        public string InstallBase{get;set;}
    }
    public class InternalAttendee {
        
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string email;
        @AuraEnabled
        public string type;
    }
    public class ExternalAttendee {
        
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string email;
        @AuraEnabled
        public string type;
    }
}