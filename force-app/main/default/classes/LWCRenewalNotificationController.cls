public class LWCRenewalNotificationController {
    
    public static List<User> myUser = null;
    public static List<Id> allUserIds = null;
    
    public static Date StartDate = null;
    public static Date EndDate = null;  
    
    public static String searchString = null;  
    
    
	//Get Adition Email Template
    @AuraEnabled(cacheable=true)   
    public Static String additionalemailtoTerminate(){
        return Label.Order_Ops_Email_Id+ ';';
    }
    
    
    //Get Email Template -- terminate Subscription
    @AuraEnabled(cacheable=true)   
    public Static String getTerminationTemplateId(){
        list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Subscription_Termination'];
        if(!etlst.isEmpty()){
            return etlst[0].Id;
        }
        return '';
    }
    
    //Get Email Template -- Past Due
    @AuraEnabled(cacheable=true)   
    public Static String getPastdueTemplateId(){
        list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Past Due Reminder Notifications'];
        if(!etlst.isEmpty()){
            return etlst[0].Id;
        }
        return '';
    }
    
    //Get Email Template -- Upcoming Reminder
    @AuraEnabled(cacheable=true)
    public Static String getFuturenotificationTemplateId(){
        list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Upcoming Reminder Notification'];
        if(!etlst.isEmpty()){
            return etlst[0].Id;
        }
        return '';
    }
    
    @AuraEnabled(cacheable=true)   
    public Static String getGeoAndRepPicklistValues() {
        List<User> myuserdetails = [Select Id, Level__c, GEO__c, Profile.Name,  Show_Rep_Filter_on_Renewal_Console__c  from user where Id = :UserInfo.getUserId()];
        Map<String, Set<String>> mapGeoAndRegionValues = new Map<String, Set<String>>();
        mapGeoAndRegionValues.put('All',new Set<String>());
        String query = 'SELECT Id, GEO__c, name from User where Department like \'%Renewal%\' and Upsell_Placeholder__c = false and isactive = true ';
        if(!myuserdetails.isEmpty() && myuserdetails[0].GEO__c != null && myuserdetails[0].GEO__c != 'WW'){
            String geo = myuserdetails[0].GEO__c;
            query += ' and GEO__c = :geo';
        }
        for (User u : database.query(query)) {
            if (!mapGeoAndRegionValues.containsKey(u.GEO__c)) {
                mapGeoAndRegionValues.put(u.GEO__c, new Set<String> { u.Name });
            } else {
                mapGeoAndRegionValues.get(u.GEO__c).add(u.Name);
            }
            
            mapGeoAndRegionValues.get('All').add(u.Name);
        }
        return JSON.serialize(mapGeoAndRegionValues);
    }
      
    
    
    //Get Opportunity records
    @AuraEnabled
    public static RecordListWrapper getOpportunityRecordsUnCached(String filterStr, Integer offset, String selectedTab) {
        return fillOpportunityListWrapper(filterStr,offset,selectedTab);
    }
    
    
    
    //Get Opportunity records
    @AuraEnabled(cacheable=true)   
    public static RecordListWrapper getOpportunityRecords(String filterStr, Integer offset, String selectedTab) {
        return fillOpportunityListWrapper(filterStr,offset,selectedTab);
    }
    
    
       
    private Static RecordListWrapper fillOpportunityListWrapper(String filterStr, Integer offset, String selectedTab) {
        
        System.debug('fillOpportunityListWrapper :: called');
        System.debug('filterStr ::'+filterStr);
        System.debug('offset ::'+offset);
        System.debug('selectedTab ::'+selectedTab);
        
        myUser  = [Select Id, Level__c, GEO__c, Profile.Name,  Show_Rep_Filter_on_Renewal_Console__c  from user where Id = :UserInfo.getUserId()];
        if(myUser[0].GEO__c != 'WW' && myUser[0].Profile.Name != 'System Administrator'){
            allUserIds = new List<Id>();
            allUserIds.add(UserInfo.getUserId());
            allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(UserInfo.getUserId()));
        }
        
        RecordListWrapper rlw = new RecordListWrapper();
        Boolean hasError = false;
        String errorMsg = null;
        
        
        try{
            List<String> DaysdueValuetocompare = new List<String>();
            Map<Id, OppWrapper> oppmap = new Map<Id,OppWrapper>();
            Set<String> DaysPastDueArray = new Set<String>();
            Set<String> NumberofExtensionsArray = new Set<String>();
            String DaysPastDueSet = '';
            String NumberofExtensionsSet = '';
            String whereClause = null;
            String uLevel = String.valueOf(myUser[0].Level__c);
            
            boolean hasOwnerFilter = false;
            String repValue = '';
            String geoValue = '';
            
            List<String> filterList = new List<String>();
            FilterWrapper contrcatEndDateFilter = null;
            
            if(filterStr != null && !String.isEmpty(filterStr)){
                List<FilterWrapper> filtWrapList = (List<LWCRenewalNotificationController.FilterWrapper>)JSON.deserialize(filterStr, List<LWCRenewalNotificationController.FilterWrapper>.class);
                System.debug('filtWrapList ::'+filtWrapList);
                
                for(FilterWrapper fw : filtWrapList){    
                    System.debug('FilterWrapper fw ::'+fw);
                    if(fw.isRange != null && fw.isRange){
                        if(fw.valFrom != null || fw.valTo != null){    
                            if(fw.fieldName == 'Contract_End_Date_New__c'){
                                contrcatEndDateFilter  = fw;
                            }else{
                                filterList.add(rangeFilterValueFromField(fw));
                            }
                        }
                    }else{
                        if(fw.isMulti != null && fw.isMulti){
                            //get ALL Multi value
                            List<String> valueList = new List<String>();
                            for(String str: fw.fieldValue.split(',')){
                                if(str!= null && !String.isEmpty(str.trim())){
                                    valueList.add(str.trim());
                                }
                            }
                            System.debug('valueList ::'+valueList);
                            if(fw.fieldName == 'DB'){
                                filterList.add(getFilterValueForDealvalue(valueList));
                            }else if(fw.fieldName == 'FC'){
                                filterList.add(getFilterValueForFC(uLevel, valueList));
                            }else if(fw.fieldName == 'DAYSDUE'){
                                DaysdueValuetocompare = getDaysDueList(valueList);
                            }else if(fw.fieldName == 'NOE'){
                                filterList.add(getFilterValueForNOE(valueList));
                            }else if(fw.fieldName == 'GEO'){
                                geoValue = fw.fieldValue;
                            }else if(fw.fieldName == 'REP'){
                                hasOwnerFilter = true;
                                repValue = fw.fieldValue;
                            }else{
                                filterList.add(getFilterValueForFieldWithMultiValue(fw.fieldType, fw.fieldName, valueList));
                            }
                        }else{
                            if(fw.fieldName == 'Name_Search'){
                                String searchStr = '%'+fw.fieldValue+'%';
                                searchString = searchStr;
                                filterList.add('Name like :searchString');
                            }else{
                                filterList.add(getFiltervalueForFieldvalue(fw.fieldType, fw.fieldName, fw.fieldValue));
                            }
                            
                        }
                    }
                    System.debug('filterList ::'+filterList);
                }
            }
            
            
            if(selectedTab == 'Upcoming Renewals'){
                
                System.debug('contrcatEndDateFilter ::'+contrcatEndDateFilter);
                //Contract_End_Date_New__c            
                if(contrcatEndDateFilter != null){
                    if(contrcatEndDateFilter.valFrom != null){
                        StartDate = parseDate(contrcatEndDateFilter.valFrom);
                        if(contrcatEndDateFilter.valTo != null){
                            EndDate = parseDate(contrcatEndDateFilter.valTo);
                        }else{
                            EndDate = Date.Today().addDays(100);
                        }
                    }else if(contrcatEndDateFilter.valTo != null){
                        EndDate = parseDate(contrcatEndDateFilter.valTo);
                        if(contrcatEndDateFilter.valFrom != null){
                            StartDate = parseDate(contrcatEndDateFilter.valFrom);
                        }else{
                            StartDate = Date.Today();
                        }
                    }
                }else{
                    StartDate = Date.Today();
                    EndDate = Date.Today().addDays(100);
                }
                
            }
            else{
                System.debug('searchString ::'+searchString);
                if(searchString != null && String.isNotEmpty(searchString)){
                    StartDate = null;
                    EndDate = null;
                }else{
                    StartDate = Date.Today().addDays(-40);
                    EndDate = Date.Today().adddays(-1);
                }
            }
            
            if(StartDate != null){
                filterList.add('Contract_End_Date_New__c >= :StartDate');
            }
            if(EndDate != null){
                filterList.add('Contract_End_Date_New__c <= :EndDate');
            }
            
            whereClause = String.join(filterList, ' AND ');
            
            //Add reprenstative Filter
            String repFilter = null;
            if(hasOwnerFilter){
                List<String> valueList = new List<String>();
                for(String str: repValue.split(',')){
                    if(str!= null && !String.isEmpty(str.trim())){
                        valueList.add(str.trim());
                    }
                }
                repFilter = ' AND ' + getFilterValueForFieldWithMultiValue('Text', 'Owner.Name', valueList);
            }else{
                if(myUser != null && (myUser[0].GEO__c == 'WW' || myUser[0].Profile.Name == 'System Administrator')){
                    repFilter = ' AND (Owner.Department like \'%Renewal%\' and Owner.Upsell_Placeholder__c = false and Owner.isactive = true )';
                }else{
                    repFilter = ' AND (OwnerId in :allUserIds )';
                }
            }
            
            whereClause += repFilter;
            
            System.debug('--offset :'+offset);
            System.debug('--whereClause :'+whereClause);
            
            //List<Opportunity> opplst = getOpportunityList(whereClause, offset);
            
            MAP<String,Object> oppListMAP =  getOpportunityList(whereClause, offset);
            System.debug('oppListMAP ::'+oppListMAP);
            List<Opportunity> opplst = (List<Opportunity>)oppListMAP.get('OpportunityList');
            
            Set<Id> accIds = new Set<Id>();
            for(Opportunity opp: opplst){
                accIds.add(opp.AccountId);
            }
            
            Map<Id, String> acctoNamemap = new Map<Id, String>();
            Map<Id, String> acctoEmailmap = new Map<Id, String>();
            for(Contact con: [Select Id, name, email, AccountId from Contact where AccountId in :accIds and Renewal_Notification_Recipient__c = true and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified - Incorrect Company','Disqualified - Incorrect Contact','Disqualified - Bad Data')]){
                if(!acctoNamemap.containsKey(con.AccountId)){
                    acctoNamemap.put(con.AccountId, '\''+con.Name + '\';');
                }else{
                    String conname = acctoNamemap.get(con.AccountId);
                    conname += '\''+ con.Name + '\';';
                    acctoNamemap.put(con.AccountId, conname);
                }
                if(!acctoEmailmap.containsKey(con.AccountId)){
                    acctoEmailmap.put(con.AccountId, con.Email + ';');
                }else{
                    String conname = acctoEmailmap.get(con.AccountId);
                    conname += con.Email + ';';
                    acctoEmailmap.put(con.AccountId, conname);
                }
            }
            
            System.debug('DaysdueValuetocompare ::'+DaysdueValuetocompare);
            
            for(Opportunity opp: opplst){
                if(DaysdueValuetocompare == null || DaysdueValuetocompare.isEmpty() ||
                   DaysdueValuetocompare.contains(String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())))) || 
                   (DaysdueValuetocompare.contains('30+') && Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())) > 30))
                {
                    
                    if(opp.Contract_End_Date_New__c != null){
                       
                        opp.Renewal_Notification_Status__c = opp.Renewal_Notification_Status_Formula__c != null ? opp.Renewal_Notification_Status_Formula__c : opp.Renewal_Notification_Status__c;
                        opp.Past_Due_Notification_Status__c = opp.Past_Due_Notification_Status_Formula__c != null ? opp.Past_Due_Notification_Status_Formula__c : opp.Past_Due_Notification_Status__c;
                        
                        OppWrapper opWrap = new OppWrapper(opp, 
                                                           Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())),
                                                           false, 
                                                           acctoNamemap.get(opp.AccountId), 
                                                           acctoEmailmap.get(opp.AccountId), opp.Partner_Account_Contact_Name__c,opp.Partner_Account_Contact_Email__c);
                        
                      
                        
                        DaysPastDueArray.add(String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today()))));
                        DaysPastDueSet += String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today()))) + '--';
                        
                        
                        
                        if(opp.Number_of_Extension_Requests__c != null){
                            NumberofExtensionsArray.add(String.valueOf(opp.Number_of_Extension_Requests__c));
                            NumberofExtensionsSet += String.valueOf(opp.Number_of_Extension_Requests__c) + '--';
                        }
                       
                            
                        oppmap.put(opp.Id, opWrap);
                    }
                }
            }
            
            System.debug('--DaysPastDueArray--'+DaysPastDueArray);
            
            rlw.pageNumber = Integer.valueOf(oppListMAP.get('PageNumber'));
            rlw.totalRecords = Integer.valueOf(oppListMAP.get('ResultSize'));
            
            rlw.oppWrapList = oppmap.values();
            rlw.hasError = hasError;
            rlw.errorMessage = errorMsg;
            
            rlw.NumberofExtensionsArray = new List<String>(NumberofExtensionsArray);
            rlw.DaysPastDueArray = new List<String>(DaysPastDueArray);
            rlw.showGEOfilter = myUser[0].Show_Rep_Filter_on_Renewal_Console__c;
       
            
        }catch(Exception ex){
            rlw.hasError = true;
            rlw.errorMessage = 'Unexpected Error Occured : Error ['+ ex.getMessage()+'] Line Number['+ex.getLineNumber()+']';
            System.debug('Exeption :: Cause ::'+ex.getCause());
            System.debug('Exeption :: Message ::'+ex.getMessage()); 
            System.debug('Exeption :: Line Number ::'+ex.getLineNumber());   
        }
        System.debug('fillOpportunityListWrapper :: rlw ::'+rlw);
        return rlw;
    }
    
   
    //Input Formate --YYYY-MM-DD
    private Static Date parseDate(String inpDate){
        if(inpDate.contains('-')){
            List<String> dateParts = inpDate.split('-');
            return Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
        }else{
            return Date.parse(inpDate);
        }
    }
    
    
    //Update opportunity Record
    @AuraEnabled
    public static CustomSaveResult updateOpportunityRecord(String recorId, String field, String value ){
        System.debug('updateOpportunityRecord called');
        System.debug('--recorId--'+recorId);
        System.debug('--field--'+field);
        System.debug('--value--'+value);
        CustomSaveResult csr = new CustomSaveResult();
        try{
            // OppWrapper oppwrp = oppmap.get(oppIdtoSave);
            Opportunity opp = new Opportunity();
            opp.put('Id',recorId);
            opp.put(field, value);
            Database.SaveResult sr = Database.update(opp, false);
            if(sr.isSuccess()){
                csr.isException = false;
                csr.isSuccess = true;
                csr.successMsg = 'Record has been updated sucessfully.' ;
            }else{
                System.debug('sr Errors::'+JSON.serialize(sr.getErrors()));
                csr.isSuccess = false;
                csr.errorMessage = 'Error occured,';
            }
            return csr;
        }catch(Exception ex){
            csr.isException = true;
            csr.errorMessage = 'Error occured, Kindly contact Administartor.';
            csr.exceptionMessage = 'Exception :: Message['+ex.getMessage()+'] LineNumber::['+ex.getLineNumber()+']';
            
        }
        return csr;
    }
    
    
    //cacheable due to wire
    @AuraEnabled(cacheable=true)   
    public static String getFieldSetMember(String objectName , String fieldSetName){
        
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        
        for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
            FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
            wrapper.isDBRequired = fieldMember.getDbRequired();
            wrapper.isRequired = fieldMember.getRequired();
            wrapper.fieldType = String.valueOf(fieldMember.getType());
            wrapper.fieldLabel = fieldMember.getLabel();
            wrapper.fieldAPIName = fieldMember.getFieldPath();
            if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || 
               String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                   wrapper.pickListValues = sObj.getDescribe().fields.getMap().get(fieldMember.getFieldPath())
                       .getDescribe().getPicklistValues();
               }
            wrapperList.add(wrapper);
        }
        return JSON.serialize(wrapperList);
    }
    
    
    @AuraEnabled
    public static AddContactWrraper getcontactlist(opportunity opp, Id ContactAddtionaccId, String ispartorcust){
        
        System.debug('AddContactWrraper :: opp--'+opp);
        System.debug('AddContactWrraper :: ContactAddtionaccId--'+ContactAddtionaccId);
        System.debug('AddContactWrraper :: ispartorcust--'+ispartorcust);
        
        AddContactWrraper adwrap = new AddContactWrraper();
        List<ConWrapper> RenewalRecipientList =new  List<ConWrapper>();
        List<ConWrapper> NonRenewalRecipientList =new  List<ConWrapper>();
        
        Set<String> emailset = new Set<String>();
        if(opp.Partner_Account_Contact_Email__c != null && opp.Partner_Account_Contact_Email__c != ''){
            emailset.addAll(opp.Partner_Account_Contact_Email__c.split(';'));
        }
        
        for(Contact con: [SELECT Id, Name, Email, Renewal_Notification_Recipient__c FROM Contact 
                          WHERE AccountId = :ContactAddtionaccId and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified - Incorrect Company','Disqualified - Incorrect Contact','Disqualified - Bad Data')]){
            if(ispartorcust != 'Partner')
            {
                if(con.Renewal_Notification_Recipient__c == false){
                    NonRenewalRecipientList.add(new ConWrapper(con));
                }else{
                    RenewalRecipientList.add(new ConWrapper(con));
                }
            }else{
                if(emailset.contains(con.Email)){
                    RenewalRecipientList.add(new ConWrapper(con, true));
                }else{
                    NonRenewalRecipientList.add(new ConWrapper(con, false));
                }
            }
        }
        adwrap.RenewalRecipientList = RenewalRecipientList;
        adwrap.NonRenewalRecipientList = NonRenewalRecipientList;
        
        
        System.debug('AddContactWrraper :: adwrap.RenewalRecipientList Size--'+adwrap.RenewalRecipientList.size());
        System.debug('AddContactWrraper :: adwrap.RenewalRecipientList--'+JSON.serialize(adwrap.RenewalRecipientList));
        System.debug('AddContactWrraper :: adwrap.NonRenewalRecipientList Size--'+adwrap.NonRenewalRecipientList.size());
        System.debug('AddContactWrraper :: adwrap.NonRenewalRecipientList--'+JSON.serialize(adwrap.NonRenewalRecipientList));
        
        return adwrap;
    }
    
    
    
    @AuraEnabled
    public static CustomSaveResult savecontacts(AddContactWrraper acw, Opportunity opp, String ispartorcust){
        
        
        System.debug('savecontacts ::AddContactWrraper::acw::'+acw);
        System.debug('savecontacts ::AddContactWrraper::opp::'+opp);
        System.debug('savecontacts ::AddContactWrraper::ispartorcust::'+ispartorcust);
        
        CustomSaveResult csr = new CustomSaveResult();
        
        try{
            
            List<Contact> conlsttoupdate = new List<Contact>();
            if(ispartorcust == 'Partner'){
                opp.Partner_Account_Contact_Email__c = '';
                opp.Partner_Account_Contact_Name__c = '';
            }
            for(ConWrapper wrp: acw.RenewalRecipientList){
                if(wrp.checked){
                    if(ispartorcust == 'Partner'){
                        opp.Partner_Account_Contact_Name__c += '\''+wrp.con.Name + '\';';
                        opp.Partner_Account_Contact_Email__c += wrp.con.Email + ';';
                    }else{
                        wrp.con.Renewal_Notification_Recipient__c = true;
                        conlsttoupdate.add(wrp.con);
                    }
                }else if(ispartorcust != 'Partner'){
                    if(wrp.con.Renewal_Notification_Recipient__c){
                        wrp.con.Renewal_Notification_Recipient__c = false;
                        conlsttoupdate.add(wrp.con);
                    }
                }
            }
            
            for(ConWrapper wrp: acw.NonRenewalRecipientList){
                if(wrp.checked){
                    if(ispartorcust == 'Partner'){
                        opp.Partner_Account_Contact_Name__c += '\''+wrp.con.Name + '\';';
                        opp.Partner_Account_Contact_Email__c += wrp.con.Email + ';';
                    }else{
                        wrp.con.Renewal_Notification_Recipient__c = true;
                        conlsttoupdate.add(wrp.con);
                    }
                }else if(ispartorcust != 'Partner'){
                    if(wrp.con.Renewal_Notification_Recipient__c){
                        wrp.con.Renewal_Notification_Recipient__c = false;
                        conlsttoupdate.add(wrp.con);
                    }
                }
            }
            
            System.debug('savecontacts ::conlsttoupdate::'+conlsttoupdate);
            System.debug('savecontacts ::opp::'+opp);
            
            update conlsttoupdate;   
            update opp;
            csr.isException = false;
            csr.isSuccess = true;
            csr.successMsg = 'Record has been updated sucessfully.';
            
        }catch(Exception ex){
            csr.isException = true;
            csr.errorMessage = 'Error occured, Kindly contact Administartor.';
            csr.exceptionMessage = 'Exception :: Message['+ex.getMessage()+'] LineNumber::['+ex.getLineNumber()+']';
        }
        return csr;
    }
    
    
    
    @AuraEnabled
    public Static CustomSaveResult createAndAddExtension(Opportunity opp, Contract_Extension_Request__c newExtension) {
        System.debug('--createAndAddExtension--newExtension--'+newExtension);
        System.debug('--createAndAddExtension--opp--'+opp);
        System.debug('--createAndAddExtension--newExtension--'+newExtension);
        
        CustomSaveResult csr = new CustomSaveResult();
        
        SavePoint sp = Database.setSavepoint();
        if(newExtension.Contract_Extension_Date__c < Date.today()){
            csr.isSuccess = false;
            csr.errorMessage = 'Extended Contract End date should not be less than today';
            System.debug('--createAndAddExtension--csr--'+csr);
            return csr;
        }
        
        try {
            newExtension.Extension_Request_Date__c = Date.today();
            newExtension.Previous_Extension_Date__c = opp.New_Extended_Contract_Date__c;
            newExtension.Extension_Request_No__c = opp.Number_of_Extension_Requests__c + 1;
            newExtension.GEO_SE_Director__c = opp.Geo_Account__c != null && GEO_SE_Director_Mapping__c.getAll().containsKey(opp.Geo_Account__c) ? GEO_SE_Director_Mapping__c.getValues(opp.Geo_Account__c).SE_Director_Id__c : null;
            newExtension.GEO_VP__c = opp.Opportunity_Sales_Territory__r.GEO_VP__c;
            newExtension.Renewal_Director__c = opp.Opportunity_Sales_Territory__r.Renewal_Director__c;
            newExtension.Sales_Ops_Director__c = opp.Geo_Account__c != null && GEO_Sales_Ops_Director_Mapping__c.getAll().containsKey(opp.Geo_Account__c) ? GEO_Sales_Ops_Director_Mapping__c.getValues(opp.Geo_Account__c).Sales_Ops_Director__c : null;
            insert newExtension;
            
            if(newExtension.Reason_for_Extension__c != '' &&  newExtension.Reason_for_Extension__c != null){
                opp.Extension_Approval_Status__c = 'Pending Approval';
                opp.New_Extended_Contract_Date__c = null;
                List<Approval.ProcessSubmitRequest> approvalProcessRequestList = new List<Approval.ProcessSubmitRequest>();
                List<Approval.ProcessResult> approvalProcessResultList = new List<Approval.ProcessResult>();
                Approval.ProcessSubmitRequest newApprovalRequest = new Approval.ProcessSubmitRequest();
                newApprovalRequest.setComments('Submit for Contract Extension Request Approval');
                newApprovalRequest.setObjectId(newExtension.Id);
                newApprovalRequest.setSubmitterId(UserInfo.getUserId());
                
                approvalProcessRequestList.add(newApprovalRequest);
                if (approvalProcessRequestList.size() > 0) {
                    for (Approval.ProcessSubmitRequest processRequest : approvalProcessRequestList) {
                        Approval.ProcessResult result = Approval.process(processRequest);
                    }
                }
            }else{
                opp.Extension_Approval_Status__c = 'Approved';
                opp.New_Extended_Contract_Date__c = newExtension.Contract_Extension_Date__c;
            }
            
            update opp;
            
            csr.isSuccess = true;
            csr.successMsg = 'Success';
            
            System.debug('--createAndAddExtension--csr--'+csr);
            return csr;
            
        } catch (Exception ex) {
            csr.isSuccess = false;
            csr.errorMessage = 'Error occurred while adding new Extension Request';
            csr.exceptionMessage = ex.getMessage();
            Database.rollback(sp);
            System.debug('--createAndAddExtension--csr--'+csr);
            return csr;
        }
    }
    
    
    
    //Get Sobject Records
    private Static 	MAP<String, object> getOpportunityList(String whereClause, Integer pageNumber){
        
        MAP<String, object> retMAP = new MAP<String, object>();
        
        System.debug('getOpportunityList called ::');
        System.debug('StartDate ::'+StartDate);
        System.debug('EndDate ::'+EndDate);
        System.debug('searchString ::'+searchString);
        
        List<String> stageList = new List<String>(); 
        StageList.add(label.Stage_5_Contracts_Complete);
        StageList.add(label.Stage_7_Closed_Lost);
        StageList.add(label.Stage_6_Closed_Won);
        
        List<Opportunity> sobjList = null;
        List<String> queryBuilder = new List<String>();
        queryBuilder.add('SELECT');
        queryBuilder.add('Id, Name, AccountId, Account.Name, Owner.Email, Past_Due_Notification_Status_Formula__c, Renewal_Notification_Status_Formula__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status__c, Past_Due_Notification_Status__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Opportunity_Sales_Territory__r.GEO_VP__c, Opportunity_Sales_Territory__r.Renewal_Director__c, APTS_Primary_Proposal_Lookup__r.APTS_ACV__c, Partner_Account_Contact_Name__c, Partner_Account_Contact_Email__c ');
        queryBuilder.add('FROM');
        queryBuilder.add('Opportunity');
        queryBuilder.add('WHERE');
        queryBuilder.add('Recordtype.name = \'Renewal Opportunity\' and StageName NOT IN:stageList');
        
        System.debug('--whereClause ::'+whereClause);
        if(whereClause != null  && String.isNotBlank(whereClause.trim())){
            queryBuilder.add('AND');
            queryBuilder.add(whereClause);
        }
        String query = String.join(queryBuilder, ' ');
        System.debug('getOpportunityDetail :: query ::'+query);
        
        ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
        oppController.setPageSize(20);
        oppController.setPageNumber(pageNumber);
        retMAP.put('OpportunityList',(List<Opportunity>)oppController.getRecords());
        retMAP.put('ResultSize',oppController.getResultSize());
        retMAP.put('PageNumber',oppController.getPageNumber());
        
        return retMAP;
    } 
    
    
    
    private static String rangeFilterValueFromField(FilterWrapper fw){
        List<String> rangeFilterbuilder = new List<String>();
        rangeFilterbuilder.add('(');
        
        List<String> rangeFilterComponents = new List<String>();
        if(fw.valFrom != null){
            rangeFilterComponents.add(getFiltervalueForRangeFieldvalue(fw.fieldType,fw.fieldName, fw.valFrom,'>='));
        }
        if(fw.valTo != null){
            rangeFilterComponents.add(getFiltervalueForRangeFieldvalue(fw.fieldType,fw.fieldName, fw.valTo,'<='));
        }
        rangeFilterbuilder.add(String.join(rangeFilterComponents,' AND '));
        rangeFilterbuilder.add(')');
        return String.join(rangeFilterbuilder,' ');
    }
    
    
    private static List<String> getDaysDueList(List<String> selectedValues){
        List<String> DaysdueValuetocompare = new List<String>();
        for(String s: selectedValues){
            if(s=='1-10'){
                for(Integer i = 1; i<=10; i++){
                    DaysdueValuetocompare.add(String.valueOf(i));
                }
            }else if( s=='11-20'){
                for(Integer i = 11; i<=20; i++){
                    DaysdueValuetocompare.add(String.valueOf(i));
                }
            }else if( s=='21-30'){
                for(Integer i = 21; i<=30; i++){
                    DaysdueValuetocompare.add(String.valueOf(i));
                }
            }else if(s=='30+'){
                DaysdueValuetocompare.add(s);
            }
        }
        return DaysdueValuetocompare;
        
    }
    
    
    
    //Filter For No of Extention
    private Static String getFilterValueForNOE(List<String> valueList){
        String filter = 'Number_of_Extension_Requests__c in ';
        String dealValue = '(';
        dealValue += String.join(valueList, ',');
        dealValue += ')';
        filter = filter + dealValue;        
        return filter;
    }
    
    
    //Filter For Deal Band
    private static string getFilterValueForDealvalue(List<String> valueList){
        String dealValue = '(';
        List<String> dbFilterBuilder = new List<String>();
        
        if (valueList.contains('< $25K')) {
            dbFilterBuilder.add('(Amount <= 25000)');
        }
        if (valueList.contains('$25K - $50K')) {
            dbFilterBuilder.add('(Amount > 25000 AND Amount <= 50000)');
        }
        if (valueList.contains('$50K - $100K')) {
            dbFilterBuilder.add('(Amount > 50000 AND Amount <= 100000)');
        }
        if (valueList.contains('$100K - $250K')) {
            dbFilterBuilder.add('(Amount > 100000 AND Amount <= 250000)');
        }
        if (valueList.contains('$250K - $1M')) {
            dbFilterBuilder.add('(Amount > 250000 AND Amount <= 1000000)');
        }
        if (valueList.contains('> $1M')) {
            dbFilterBuilder.add('(Amount > 1000000) ');
        }
        dealValue += String.join(dbFilterBuilder, ' OR ');
        dealValue += ')';
        return dealValue;
    }
    
    
    private static string getFilterValueForFC(string uLevel, List<String> selvalues){
        String finalVal= null;
        String myUserlevel = uLevel;
        String forecastCategoryField = 'Forecast_Category__c';
        if (myUserlevel != '' && myUserlevel != 'Rep') {
            if (myUserlevel == 'Manager') {
                forecastCategoryField = 'Forecast_Category__c';
            } else if (myUserlevel == 'Director') {
                forecastCategoryField = 'DM_Forecast_Category__c';
            } else if (myUserlevel == 'RVP') {
                forecastCategoryField = 'AD_Forecast_Category__c';
            } else if (myUserlevel == 'VP') {
                forecastCategoryField = 'RVP_Forecast_Category__c';
            } else if (myUserlevel == 'Exec') {
                forecastCategoryField = 'VP_Forecast_Category__c';
            }
        } else {
            forecastCategoryField = 'Forecast_Category__c';
        }
        
        List<String> fcValueBuilder = new List<String>();
        fcValueBuilder.add('(');
        string innerStr = '';
        for(string str : selvalues){
            innerStr += '\'' + str.trim() + '\',';
        }
        innerStr = innerStr.Substring(0,innerStr.length()-1); 
        fcValueBuilder.add(innerStr);
        fcValueBuilder.add(')');
        finalVal = String.join(fcValueBuilder,' ');
        
        return  forecastCategoryField + ' in '+finalVal;
    }
    
    
    
    private static string getFiltervalueForFieldvalue(String fieldType,String fieldName, String fldValue){
        String retval = '';
        switch on fieldType{
            when 'Number','Date','DateTime' {    
                retval = fieldName + ' = '+  fldValue.trim();
            }
            when else {      
                retval = fieldName + ' = '+ '\'' + fldValue.trim() + '\',';
            }
        }
        return  retval;
    }
    
    
    
    private static string getFiltervalueForRangeFieldvalue(String fieldType,String fieldName, String fldValue, String fldOperator){
        String retval = '';
        switch on fieldType{
            when 'Number','Date','DateTime' {    
                retval = fieldName + ' '+fldOperator+' '+  fldValue.trim();
            }
            when else {      
                retval = fieldName + ' = '+ '\'' + fldValue.trim() + '\',';
            }
        }
        return  retval;
    }
    
    
    
    
    private static string getFilterValueForFieldWithMultiValue(String fieldType,String fieldName, List<String> fldValue){
        String retval = '';
        List<String> fcValueBuilder = new List<String>();
        fcValueBuilder.add('(');
        string innerStr = '';
        switch on fieldType{
            when 'Number','Date','DateTime' {
                for(string str : fldValue){
                    innerStr += str.trim();
                }
            }
            when else {      
                for(string str : fldValue){
                    innerStr += '\'' + str.trim() + '\',';
                }
            }
        }
        innerStr = innerStr.Substring(0,innerStr.length()-1); 
        fcValueBuilder.add(innerStr);
        fcValueBuilder.add(')');
        retval = String.join(fcValueBuilder, ' ');
        return  fieldName + ' in '+retval;
    }
    
    
  
    
    
    
    //Wrapper class for parsing the filter string
    public class FilterWrapper{
        public string fieldName 	{get; set;}
        public string fieldType 	{get; set;}
        public string fieldValue 	{get; set;}
        
        public boolean isRange 		{get; set;}
        public boolean isMulti 		{get; set;}
        
        public string valFrom 		{get; set;}
        public string valTo 		{get; set;}
    }
    
    
    //wrapper class for realed List
    public class RecordListWrapper {
        @AuraEnabled
        public Integer  pageNumber;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public List<Oppwrapper>  oppWrapList;
        //Error handling
        @AuraEnabled
        public Boolean hasError;
        @AuraEnabled
        public String errorMessage;   
        
        @AuraEnabled
        public List<String> NumberofExtensionsArray;
        @AuraEnabled
        public List<String> DaysPastDueArray;
        @AuraEnabled
        public boolean showGEOfilter;
        //myuserdetails[0].Show_Rep_Filter_on_Renewal_Console__c;
        
    }
    
    
    
    
    
    public class OppWrapper{
        @AuraEnabled
        public Opportunity opp					{get; set;}
        @AuraEnabled
        public Integer daystocontractdate		{get; set;}
        @AuraEnabled
        public Boolean editMode					{get; set;}
        @AuraEnabled
        public String customercontactname		{get; set;}
        @AuraEnabled
        public String partnercontactname		{get; set;}
        @AuraEnabled
        public String customercontactemail		{get; set;}
        @AuraEnabled
        public String partnercontactemail		{get; set;}
        @AuraEnabled
        public boolean isupcoming				{get;set;}
        @AuraEnabled
        public boolean hasaccount				{get;set;}
        @AuraEnabled
        public boolean haspartner				{get;set;}
        @AuraEnabled
        public boolean showredpartner			{get;set;}
        @AuraEnabled
        public boolean showordinarypartner		{get;set;}
        @AuraEnabled
        public boolean showredcustomer			{get;set;}
        @AuraEnabled
        public boolean showordinarycustomer		{get;set;}
        @AuraEnabled
        public String notificationstatus;
       
   
        
        public OppWrapper(Opportunity o, Integer dayscontractdate, Boolean isedit, String cutomername, String customeremail, String partnername, String partneremail){
            opp = o;
            daystocontractdate = dayscontractdate;
            editMode = isedit;
            customercontactname = cutomername;
            customercontactemail = customeremail;
            partnercontactname = partnername;
            partnercontactemail = partneremail;
            isupcoming = o.Contract_End_Date_New__c >= Date.Today();
            hasaccount = o.AccountId != null;
            haspartner = o.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null;
            notificationstatus = isupcoming ? o.Renewal_Notification_Status__c : o.Past_Due_Notification_Status__c;
            showredpartner = notificationstatus == 'Yes' && (o.Partner_Account_Contact_Name__c == null || o.Partner_Account_Contact_Name__c == '');
            showordinarypartner = notificationstatus != 'Yes' || (o.Partner_Account_Contact_Name__c != null && o.Partner_Account_Contact_Name__c != '');
            showredcustomer = notificationstatus == 'Yes' && (customercontactname == null || customercontactname == '');
            showordinarycustomer = notificationstatus != 'Yes' || (customercontactname != null && customercontactname != '');
        }
    }
    
    
    public class CustomSaveResult{
        @AuraEnabled
        public boolean isSuccess			{get;set;}
        @AuraEnabled
        public String successMsg			{get;set;}
        @AuraEnabled
        public boolean isException			{get;set;}
        @AuraEnabled
        public String errorMessage			{get;set;}
        @AuraEnabled
        public String exceptionMessage		{get;set;}
    }
    
    /*
* @Description : Wrapper class contains the information about all the fields of a FieldSet
*/ 
    public class FieldSetMemberWrapperClass{
        @AuraEnabled
        public Boolean isDBRequired 					 { get; set; }
        @AuraEnabled
        public Boolean isRequired 						 { get; set; }
        @AuraEnabled
        public String fieldType 						 { get; set; }
        @AuraEnabled
        public String fieldLabel 						 { get; set; }
        @AuraEnabled
        public String fieldAPIName 					     { get; set; }
        @AuraEnabled
        public String fieldValue 					     { get; set; }
        @AuraEnabled 
        public List<Schema.PicklistEntry> pickListValues { get; set; }
        
    }
    
    
    
    public class AddContactWrraper{
        @AuraEnabled
        public List<ConWrapper> RenewalRecipientList { get; set; }
        
        @AuraEnabled
        public List<ConWrapper> NonRenewalRecipientList { get; set; }
    }
    
    
    public class ConWrapper{
        @AuraEnabled
        public Boolean checked{get; set;}
        @AuraEnabled
        public Contact con{get; set;}
        public ConWrapper(){}
        public ConWrapper(Contact c){
            con = c;
            checked = c.Renewal_Notification_Recipient__c;
        }
        public ConWrapper(Contact c, Boolean chk){
            con = c;
            checked = chk;
        }
    }
}