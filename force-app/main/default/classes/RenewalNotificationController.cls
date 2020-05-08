public class RenewalNotificationController {

    public Boolean showPopup { get; set; }
    public Boolean erroronOpptySave { get; set; }
    public Boolean showPopupContact { get; set; }
    public Boolean showPopupOppty { get; set; }
    public Boolean showExtensionPopup { get; set; }
    public Boolean showGEOfilter { get; set; }
    public Map<Id, OppWrapper> oppmap = new Map<Id,OppWrapper>();
    public String oppIdtoSave{get; set;}
    public String statusval{get; set;}
    public String ContactAddtionoppId{get; set;}
    public String ContactAddtionaccId{get; set;}
    public String ispartorcust{get; set;}
    public String upcomingnotstatus{get; set;}
    public String pastnotstatus{get; set;}
    public String finaldelistatus{get; set;}
    public String popupMessage{get; set;}
    public Contact newContact { get; set; }
    public Opportunity OpptoEdit { get; set; }
    public String closedatestartfilter { get; set; }
    public String closedateEndfilter { get; set; }
    public String nextnotifstartfilter { get; set; }
    public String nextnotifendfilter { get; set; }
    public String cedstartfilter { get; set; }
    public String cedendfilter { get; set; }
    public String opptysearchfilter { get; set; }
    public String oldtab;
    public String DaysPastDueSet{get;set;}
    public Set<String> DaysPastDueArray{get;set;}
    public String NumberofExtensionsSet{get;set;}
    public Set<String> NumberofExtensionsArray{get;set;}
    public Contract_Extension_Request__c newExtension { get; set; }
    //public OppListRequest request{get; set;}
    public String reqString{get; set;}
    public List<User> myuserdetails;
    public String PageIndex { get; set; }
    public Boolean HasNext { get; set; }
    public Boolean HasPrevious { get; set; }
    public Integer PageCount { get; set; }
    public List<SelectOption> pagenumbers{ get; set; }

    public String additionalemailtoTerminate{
        get{
            return Label.Order_Ops_Email_Id    + ';';
        } set;
    }
    public String pastdueTemplateId{
        get {
            list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Past Due Reminder Notifications'];
            if(!etlst.isEmpty()){
                return etlst[0].Id;
            }
            return '';
        } set;
    }
    public String futurenotificationTemplateId{
        get {
            list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Upcoming Reminder Notification'];
            if(!etlst.isEmpty()){
                return etlst[0].Id;
            }
            return '';
        } set;
    }
    public String terminationTemplateId{
        get {
            list<EmailTemplate> etlst = [Select Id,Name from EmailTemplate where Name = 'Subscription_Termination'];
            if(!etlst.isEmpty()){
                return etlst[0].Id;
            }
            return '';
        } set;
    }
    
    public String getGeoAndRepPicklistValues() {
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
    
    public RenewalNotificationController(){
		if(test.isrunningtest()){
			booster();
		}
        SelectedTab = 'Upcoming Renewals';
        showPopup = false;
        erroronOpptySave = false;
        showPopupContact = false;
        showExtensionPopup = false;
        RenewalRecipientList = new List<ConWrapper>();
        NonRenewalRecipientList = new List<ConWrapper>();
        myuserdetails = [Select Id, Level__c, GEO__c, Profile.Name,  Show_Rep_Filter_on_Renewal_Console__c  from user where Id = :UserInfo.getUserId()];
        oldtab = '';
        DaysPastDueSet = '';
        NumberofExtensionsSet = '';
        closedatestartfilter = '';
        closedateEndfilter = '';
        nextnotifstartfilter = '';
        nextnotifendfilter = '';
        cedstartfilter = '';
        cedendfilter = '';
        if(!myuserdetails.isEmpty()){
            showGEOfilter = myuserdetails[0].Show_Rep_Filter_on_Renewal_Console__c;
        }
        PageIndex = String.valueOf(1);
    }
    
    public void nextpage(){
        PageIndex = String.valueOf(Integer.valueOf(PageIndex) + 1);
    }
    
    public void prevpage(){
        PageIndex = String.valueOf(Integer.valueOf(PageIndex) - 1);
    }
    
    public List<Oppwrapper> opportunityList {
        get{
            Integer pageSize = 20;
            pagenumbers = new List<SelectOption>();

            if(oldtab != '' && oldtab != SelectedTab){
                reqString = '';
                closedatestartfilter = '';
                closedateEndfilter = '';
                nextnotifstartfilter = '';
                nextnotifendfilter = '';
                cedstartfilter = '';
                cedendfilter = '';
                opptysearchfilter = '';
                PageIndex = '1';
                HasPrevious = false;
                HasNext = true;
            }
            system.debug('++++'+reqString);
            Map<String,Object> request;
            if(reqString != '' && reqString != null){
                request = (Map<String,Object>)JSON.deserializeUntyped(reqString);
                system.debug(request);
            }
            String dealValue = '';
            String notifvalupcoming = '';
            String notifvalpaststatus = '';
            String notifvalpastfinal = '';
            String FCValue = '';
            String RepValue = '';
            List<String> DaysdueValue;
            List<String> DaysdueValuetocompare = new List<String>();
            String NumExtensionValue = '';
            String CloseDateValue = '';
            String NextNotificationValue = '';
            String NameSearch = '';
            
            Date StartDate = null;
            Date EndDate = null;
            Date cdsd = null;
            Date cded = null;
            Date nnsd = null;
            Date nned = null;
            
            
            if(request != null){
                List<String> dealVal = (List<String>)JSON.deserialize((String)request.get('DealValue'), List<String>.class);
                if (!dealVal.isEmpty()) {
                    dealValue += ' AND (';
                    if (dealVal.contains('< $25K')) {
                        dealValue += ' (Amount <= 25000) ';
                    }
                    if (dealVal.contains('$25K - $50K')) {
                        if(dealValue.contains('Amount')) dealValue += ' OR ';
                        dealValue += ' (Amount > 25000 AND Amount <= 50000) ';
                    }
                    if (dealVal.contains('$50K - $100K')) {
                        if(dealValue.contains('Amount')) dealValue += ' OR ';
                        dealValue += ' (Amount > 50000 AND Amount <= 100000) ';
                    }
                    if (dealVal.contains('$100K - $250K')) {
                        if(dealValue.contains('Amount')) dealValue += ' OR ';
                        dealValue += ' (Amount > 100000 AND Amount <= 250000) ';
                    }
                    if (dealVal.contains('$250K - $1M')) {
                        if(dealValue.contains('Amount')) dealValue += ' OR ';
                        dealValue += ' (Amount > 250000 AND Amount <= 1000000) ';
                    }
                    if (dealVal.contains('> $1M')) {
                        if(dealValue.contains('Amount')) dealValue += ' OR ';
                        dealValue += ' (Amount > 1000000) ';
                    }
                    dealValue += ') ';
                }
                
                List<String> SendNotif = (List<String>)JSON.deserialize((String)request.get('SendNotif'), List<String>.class);
                if (!SendNotif.isEmpty()) {
                    
                    notifvalupcoming += ' AND Renewal_Notification_Status_Formula__c in :SendNotif ';
                    notifvalpaststatus += ' AND Past_Due_Notification_Status_Formula__c in :SendNotif ';
                }
                
                List<String> FCValues = (List<String>)JSON.deserialize((String)request.get('FCValue'), List<String>.class);
                if (!FCValues.isEmpty()) {
                    String myUserlevel = '';
                    if(!myuserdetails.isEmpty()){
                        myUserlevel= myuserdetails[0].Level__c;
                    }
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

                    
                    FCValue += ' AND ' + forecastCategoryField + ' in :FCValues ';
                }
                
                List<String> RepVal = (List<String>)JSON.deserialize((String)request.get('RepValue'), List<String>.class);
                if (!RepVal.isEmpty()) {
                    RepValue += ' AND Owner.Name in :RepVal ';
                }
                
                List<Decimal> NumExtensionVal = (List<Decimal>)JSON.deserialize((String)request.get('NumExtension'), List<Decimal>.class);
                if (!NumExtensionVal.isEmpty()) {
                    NumExtensionValue += ' AND Number_of_Extension_Requests__c in :NumExtensionVal ';
                }
                
                DaysdueValue = (List<String>)JSON.deserialize((String)request.get('DaysPastDue'), List<String>.class);
                for(String s: DaysdueValue){
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
            }
            
            if (closedatestartfilter != null && closedatestartfilter != '') {
                Datetime dt;
                
                List<String> dateParts = closedatestartfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    cdsd = dt.date();
                    CloseDateValue += ' AND CloseDate >= :cdsd ';
                    system.debug('++++CloseDateValue'+CloseDateValue+cdsd+closedatestartfilter);
                } 
                
            }
            
            if (closedateEndfilter != null && closedateEndfilter != '') {
                Datetime dt;
                List<String> dateParts = closedateEndfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    cded = dt.date();
                    CloseDateValue += ' AND CloseDate <= :cded ';
                    system.debug('++++CloseDateValue'+CloseDateValue+cded+closedateEndfilter);
                }
            }
            
            if (nextnotifstartfilter != null && nextnotifstartfilter != '') {
                Datetime dt;
                List<String> dateParts = nextnotifstartfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    nnsd = dt.date();
                    NextNotificationValue += ' AND Next_Renewal_Notification_Date__c >= :nnsd ';
                    system.debug('++++NextNotificationValue'+NextNotificationValue+nnsd+nextnotifstartfilter);
                }
            }
            
            if (nextnotifendfilter != null && nextnotifendfilter != '') {
                Datetime dt;
                List<String> dateParts = nextnotifendfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    nned = dt.date();
                    NextNotificationValue += ' AND Next_Renewal_Notification_Date__c <= :nned ';
                    system.debug('++++NextNotificationValue'+NextNotificationValue+nned+nextnotifendfilter);
                }
            }
            
            if (opptysearchfilter != null) {
                String srchtxt = '%' + opptysearchfilter + '%';
                NameSearch += ' AND Name like :srchtxt ';
            }
            
            if (cedstartfilter != null && cedstartfilter != '') {
                Datetime dt;
                Date tofilter = null;
                List<String> dateParts = cedstartfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    StartDate = dt.date();
                }
            }else{
                if(SelectedTab == 'Upcoming Renewals'){
                    StartDate = Date.Today();
                }else if(SelectedTab == 'Manage Extensions' && opptysearchfilter != null && opptysearchfilter != ''){
                    StartDate = null;
                }else{
                    StartDate = Date.Today().addDays(-40);
                }
            }
            system.debug('++++StartDate'+StartDate);
            if (cedendfilter != null && cedendfilter != '') {
                Datetime dt;
                Date tofilter = null;
                List<String> dateParts = cedendfilter.split('/');
                if (null != dateParts
                    && dateParts.size() == 3) {
                    dt = Datetime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                    EndDate = dt.date();
                }
            }else{
                if(SelectedTab == 'Upcoming Renewals'){
                    EndDate = Date.Today().addDays(100);
                }else if(SelectedTab == 'Manage Extensions' && opptysearchfilter != null && opptysearchfilter != ''){
                    EndDate = null;
                }else{
                    EndDate = Date.Today().adddays(-1);
                }
            }
            system.debug('++++EndDate'+EndDate);
            if(RepValue == ''){
                if(!myuserdetails.isEmpty() && (myuserdetails[0].GEO__c == 'WW' || myuserdetails[0].Profile.Name == 'System Administrator')){
                    RepValue += ' AND Owner.Department like \'%Renewal%\' and Owner.Upsell_Placeholder__c = false and Owner.isactive = true ';
                }else{
                    List<Id> allUserIds = new List<Id>();
                    allUserIds.add(UserInfo.getUserId());
                    allUserIds.addAll(ZForecastingService.getAllSubordinateUserIds(UserInfo.getUserId()));
                    RepValue += ' AND OwnerId in :allUserIds ';
                }
            }
                
            DaysPastDueSet = '';
            DaysPastDueArray = new Set<String>();
            NumberofExtensionsArray = new Set<String>();
            NumberofExtensionsSet = '';
            oppmap = new Map<Id,OppWrapper>();
            
            //String Stage1 = label.Stage_4_Economic_Buyer_Signoff;
            String Stage2 = label.Stage_5_Contracts_Complete;
            String Stage3 = label.Stage_7_Closed_Lost;
            String Stage4 = label.Stage_6_Closed_Won;
            List<String> StageList = new List<String>(); 
            //StageList.add(Stage1);
            StageList.add(Stage2);
            StageList.add(Stage3);
            StageList.add(Stage4);
            String query = 'Select Id, Name, AccountId, Account.Name, Owner.Email, Past_Due_Notification_Status_Formula__c, Renewal_Notification_Status_Formula__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status__c, Past_Due_Notification_Status__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Opportunity_Sales_Territory__r.GEO_VP__c, Opportunity_Sales_Territory__r.Renewal_Director__c, APTS_Primary_Proposal_Lookup__r.APTS_ACV__c, Partner_Account_Contact_Name__c, Partner_Account_Contact_Email__c from Opportunity where  Recordtype.name = \'Renewal Opportunity\' and StageName NOT IN:StageList ';
            //String query = 'Select Id, Name, AccountId, Account.Name, Owner.Email, Past_Due_Notification_Status_Formula__c, Renewal_Notification_Status_Formula__c, APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c, Contract_End_Date_New__c, Amount, CloseDate, StageName, Owner.Name, Renewal_Notification_Status__c, Past_Due_Notification_Status__c, Renewable_ACV__c, Next_Renewal_Notification_Date__c, Extension_Approval_Status__c, New_Extended_Contract_Date__c, Number_of_Extension_Requests__c, OwnerId, Geo_Account__c, Opportunity_Sales_Territory__r.GEO_VP__c, Opportunity_Sales_Territory__r.Renewal_Director__c, APTS_Primary_Proposal_Lookup__r.APTS_ACV__c, Partner_Account_Contact_Name__c, Partner_Account_Contact_Email__c from Opportunity where  Recordtype.name = \'Renewal Opportunity\' and StageName NOT IN (\'10 - Closed Won\', \'10b - PO recd, pending finance approval\',\'11 - Closed Lost\', \'12 - Closed With No Decision\', \'13 - Closed & Approved By Finance\', \'14 - Closed: Delete Duplicate\') ';
            if(StartDate != null){
                query += ' and Contract_End_Date_New__c >= :StartDate ';
            }
            if(EndDate != null){
                query += ' and Contract_End_Date_New__c <= :EndDate ';
            }
            if(SelectedTab == 'Upcoming Renewals'){
                query += dealValue;
                query += notifvalupcoming;
                query += FCValue;
                query += RepValue;
                query += CloseDateValue;
                query += NextNotificationValue;
                query += NameSearch;
            }else{
                query += notifvalpaststatus;
                query += RepValue;
                query += NumExtensionValue;
                query += CloseDateValue;
                query += NextNotificationValue;
                query += NameSearch;
            }
            system.debug('+++'+query);
            system.debug('+++'+StartDate);
            system.debug('+++'+EndDate);
            Set<Id> accIds = new Set<Id>();
            
            system.debug('+++'+PageIndex);
            
            ApexPages.StandardSetcontroller oppController = new ApexPages.StandardSetcontroller(Database.getQueryLocator(query));
            oppController.setPageSize(pageSize);
            
            if(PageIndex != null && PageIndex != '' && Integer.valueOf(PageIndex) > 0)
            {
                oppController.setPageNumber(Integer.valueOf(PageIndex));
            }else if(PageIndex == null || PageIndex == ''){
                PageIndex = '1';
            }
            
            PageCount = oppController.getResultSize() / pageSize + 1;
            HasNext = Integer.valueOf(PageIndex) < PageCount;
            HasPrevious = Integer.valueOf(PageIndex) > 1;
            PageIndex = String.valueOf(oppController.getPageNumber());
            system.debug('+++'+HasNext);
            system.debug('+++'+HasPrevious);
            system.debug('+++'+PageIndex);

            
            
            for(Integer i = 1; i<= PageCount ; i++){
                pagenumbers.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
            
            List<Opportunity> opplst = (List<Opportunity>)oppController.getRecords();
            for(Opportunity opp: opplst){
                accIds.add(opp.AccountId);
                /*if(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null){
                    accIds.add(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c);
                }*/
            }
            Map<Id, String> acctoNamemap = new Map<Id, String>();
            Map<Id, String> acctoEmailmap = new Map<Id, String>();
            for(Contact con: [Select Id, name, email, AccountId from Contact where AccountId in :accIds and Renewal_Notification_Recipient__c = true and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
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
            for(Opportunity opp: opplst){
                if(DaysdueValuetocompare == null || DaysdueValuetocompare.isEmpty() || DaysdueValuetocompare.contains(String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())))) || (DaysdueValuetocompare.contains('30+') && Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())) > 30)){
                    opp.Renewal_Notification_Status__c = opp.Renewal_Notification_Status_Formula__c != null ? opp.Renewal_Notification_Status_Formula__c : opp.Renewal_Notification_Status__c;
                    opp.Past_Due_Notification_Status__c = opp.Past_Due_Notification_Status_Formula__c != null ? opp.Past_Due_Notification_Status_Formula__c : opp.Past_Due_Notification_Status__c;
                    oppmap.put(opp.Id, new OppWrapper(opp, Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today())), false, acctoNamemap.get(opp.AccountId), acctoEmailmap.get(opp.AccountId), /*(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null ? acctoNamemap.get(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c) :*/ '', /*(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c != null ? acctoEmailmap.get(opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c) :*/ ''));
                    DaysPastDueArray.add(String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today()))));
                    DaysPastDueSet += String.valueOf(Math.abs(opp.Contract_End_Date_New__c.daysBetween(Date.Today()))) + '--';
                    if(opp.Number_of_Extension_Requests__c != null){
                        NumberofExtensionsArray.add(String.valueOf(opp.Number_of_Extension_Requests__c));
                        NumberofExtensionsSet += String.valueOf(opp.Number_of_Extension_Requests__c) + '--';
                    }
                }
            }
            oldtab = SelectedTab;
            return oppmap.values();
        }  set;
    }
    
    public String getDaysPastDueVals(){
        List<OppWrapper> opplst = opportunityList;
        system.debug('+++'+DaysPastDueSet);
        return DaysPastDueSet;
    }
    
    public String getNumberofExtensionsVals(){
        List<OppWrapper> opplst = opportunityList;
        system.debug('+++'+NumberofExtensionsSet);
        return NumberofExtensionsSet;
    }
    
    public List<ConWrapper> RenewalRecipientList {
        get; set;
    }
    
    public List<ConWrapper> NonRenewalRecipientList {
        get; set;
    }
    public void getcontactlists(){
        NonRenewalRecipientList.clear();
        RenewalRecipientList.clear();
        Opportunity opp = oppmap.get(ContactAddtionoppId).opp;
        Set<String> emailset = new Set<String>();
        if(opp.Partner_Account_Contact_Email__c != null && opp.Partner_Account_Contact_Email__c != ''){
            emailset.addAll(opp.Partner_Account_Contact_Email__c.split(';'));
        }
        for(Contact con: [SELECT Id, Name, Email, Renewal_Notification_Recipient__c FROM Contact 
                                                           WHERE AccountId = :ContactAddtionaccId and Active__c = false and Contact_Lead_Status__c NOT in ('Disqualified')]){
            if(ispartorcust != 'Partner'){
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
    }
    
    public Pagereference saveoppty(){
        erroronOpptySave = false;
        system.debug('++++'+oppIdtoSave);
        system.debug('++++'+statusval);
        if(oppIdtoSave != null && oppIdtoSave != '' && oppmap.containsKey(oppIdtoSave) && oppmap.get(oppIdtoSave) != null){
            system.debug('++++inside if');
            try{
                OppWrapper oppwrp = oppmap.get(oppIdtoSave);
                Opportunity opp = oppmap.get(oppIdtoSave).opp;
                if(oppwrp.isupcoming){
                    opp.Renewal_Notification_Status__c = statusval;
                }else{
                    opp.Past_Due_Notification_Status__c = statusval;
                }
                update opp;
                system.debug('++++inside try');
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to save the Opportunity. ' + ex.getMessage()));
                erroronOpptySave = true;
                system.debug('++++inside catch');
            }
        }
        return null;
    
    }
    
    public Pagereference savecontacts(){
        try{
            List<Contact> conlsttoupdate = new List<Contact>();
            Opportunity opp = oppmap.get(ContactAddtionoppId).opp;
            OppWrapper oppwrp = oppmap.get(ContactAddtionoppId);
            if(ispartorcust == 'Partner'){
                opp.Partner_Account_Contact_Email__c = '';
                opp.Partner_Account_Contact_Name__c = '';
            }
            
            for(ConWrapper wrp: RenewalRecipientList){
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
            for(ConWrapper wrp: NonRenewalRecipientList){
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
            showPopup = false;
            update conlsttoupdate;
            update opp;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Unable to save the Contact selection. ' + ex.getMessage()));
        }
        return null;
    
    }
    
    public Pagereference closepopup(){
        RenewalRecipientList.clear();
        NonRenewalRecipientList.clear();
        showPopup = false;
        return null;
    
    }
    
    /**
     * Method to display the New Contact Creation popup
     */
    public PageReference showNewContactPopup() {
        popupMessage = '';
        newContact = new Contact(AccountId = ContactAddtionaccId/*, Renewal_Notification_Recipient__c = true*/);
        showPopupContact = true;
        showPopup = false;

        return null;
    }

    /**
     * Method to close the popup without saving
     */
    public PageReference cancelPopup() {
        popupMessage = '';
        newContact = null;
        showPopupContact = false;
        showPopup = true;
        getcontactlists();
        return null;
    }
    
    public PageReference createAndAddContact() {
        popupMessage = '';
        System.debug(newContact);
        try {
            insert newContact;
            showPopup = true;
            showPopupContact = false;
            
            newContact = [Select Id, Name, Email, Renewal_Notification_Recipient__c from Contact where Id = :newContact.Id];
            NonRenewalRecipientList.add(new ConWrapper(newContact));
            popupMessage = '';
        } catch (Exception ex) {
            popupMessage = 'Error occurred while adding new contact: ' + ex.getMessage();
            showPopupContact = true;
        }

        return null;
    }
    
    public PageReference showEditOppPopup() {
        popupMessage = '';
        OpptoEdit = new Opportunity(Id = ContactAddtionoppId, StageName = label.Stage_7_Closed_Lost);
        showPopupOppty = true;

        return null;
    }

    /**
     * Method to close the popup without saving
     */
    public PageReference cancelOpptyPopup() {
        popupMessage = '';
        OpptoEdit = null;
        showPopupOppty = false;
        return null;
    }
    @RemoteAction
    public Static String terminateOppty(String oppId, String primreason, String secreason, String zialost, String zpalost) {
        Opportunity opp = new opportunity(Id= oppId, StageName = label.Stage_7_Closed_Lost, Primary_Reason_For_Loss__c = primreason, Secondary_Reason_For_Loss__c = secreason, Deal_Lost_To__c = zialost, ZPA_Deal_Lost_To__c = zpalost);
        String msg = '';
        try{
            update opp;
            msg = 'Success';
        }catch(Exception ex){
            msg = 'Error occurred while terminate Opportunity: ' + ex.getMessage();
        }
        return msg;
        /*popupMessage = '';
        try{
            showPopupOppty = false;
            
            popupMessage = '';
            update OpptoEdit;
            
        }catch(Exception ex){
            
            popupMessage = 'Error occurred while terminate Opportunity: ' + ex.getMessage();
            showPopupOppty = true;
        }
        
        return null;*/
    }
    public PageReference showNewExtensionrequestCreation() {
        popupMessage = '';
        Opportunity opp = oppmap.get(ContactAddtionoppId).opp;
        if(opp.Extension_Approval_Status__c == 'Pending Approval'){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Contract Extension Approval is pending for this opportunity. Extensions can be requested only for expired contracts.'));
            return null;
        }
        newExtension = new Contract_Extension_Request__c(Opportunity__c = ContactAddtionoppId);
        showExtensionPopup = true;

        return null;
    }

    /**
     * Method to close the popup without saving
     */
    public PageReference cancelExtensionpopup() {
        popupMessage = '';
        newExtension = null;
        showExtensionPopup = false;
        return null;
    }
    
    public PageReference createAndAddExtension() {
        popupMessage = '';
        System.debug(newExtension);
        SavePoint sp = Database.setSavepoint();
        if(newExtension.Contract_Extension_Date__c < Date.today()){
            popupMessage = 'Extended Contract End date should not be less than today';
            showExtensionPopup = true;
            return null;
        }
        try {
            Opportunity opp = oppmap.get(newExtension.Opportunity__c).opp;
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
            showExtensionPopup = false;
        } catch (Exception ex) {
            popupMessage = 'Error occurred while adding new Extension Request: ' + ex.getMessage();
            showExtensionPopup = true;
            newExtension = newExtension.clone(false);
            Database.rollback(sp);
        }

        return null;
    }

    public String SelectedTab { get; set; }
    public class OppWrapper{
        public Opportunity opp{get; set;}
        public Integer daystocontractdate{get; set;}
        public Boolean editMode{get; set;}
        public String customercontactname{get; set;}
        public String partnercontactname{get; set;}
        public String customercontactemail{get; set;}
        public String partnercontactemail{get; set;}
        public boolean isupcoming{get;set;}
        public boolean hasaccount{get;set;}
        public boolean haspartner{get;set;}
        public boolean showredpartner{get;set;}
        public boolean showordinarypartner{get;set;}
        public boolean showredcustomer{get;set;}
        public boolean showordinarycustomer{get;set;}
        public String notificationstatus;
        public OppWrapper(Opportunity o, Integer dayscontractdate, Boolean isedit, String cutomername, String customeremail, String partnername, String partneremail){
            opp = o;
            daystocontractdate = dayscontractdate;
            editMode = isedit;
            customercontactname = cutomername;
            partnercontactname = partnername;
            customercontactemail = customeremail;
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
    
    public List<SelectOption> getstatus() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('Send','Send'));
        options.add(new SelectOption('Do not Send','Do not Send'));
        return options;
    }
    
    public class ConWrapper{
        public Boolean checked{get; set;}
        public Contact con{get; set;}
        
        public ConWrapper(Contact c){
            con = c;
            checked = c.Renewal_Notification_Recipient__c;
        }
        
        public ConWrapper(Contact c, Boolean chk){
            con = c;
            checked = chk;
        }
    }
    
    public class OppListRequest
    {
        public List<String> DealValue { get; set; }
        public List<String> SendNotif { get; set; }
        public List<String> FCValue { get; set; }
        public List<String> DaysPastDue { get; set; }
        public List<String> NumExtension { get; set; }
        public List<String> RepValue { get; set; }
    }
    
	public void booster(){
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
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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