//3 WHYs field values in Value Proposition section are not populated in the EBR created.
public class Executive_Briefing_Email_Controller {
    
    //Inputs
    public String ebId					{get; set;}
   	public String oppId					{get; set;}
    public String typeofTemplate		{get; set;}
    public String approverName			{get; set;}
    
    
    //Computed
    public String meetingDate			{get; private set;}
    public String meetingStartDate		{get; private set;}
    public String meetingEndDate		{get; private set;}
    
    public String meetingStartTime		{get; private set;}
    public String meetingEndTime		{get; private set;}
    
    public String timeZone				{get; private set;}
    
    public String closeDate				{get; private set;}
    public String parentName			{get; private set;}
    
    public boolean isMeetingConfirmed 	{get; private set;}
    public boolean isOpportunityExist	{get; private set;}
    
    public String executiveName			{get; private set;}
    public List<ExternalAttendee> attendeeList 			{get; private set;}
    
    // The most recent approval process comments
    // Could show in visualforce email template, for example
    public String comments {
        get {
            if ( comments == null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                comments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return comments;
        }
        private set;
    }
    
    
    
    public String yearVal {
        get{
            return String.valueOf(date.today().year());
        } set;
    }
    public string url{get{
        url = System.Url.getSalesforceBaseURL().toExternalForm();
        return url;
    } set;}
    
 
    
    public Executive_Briefing_Request__c EB{get {
        if(ebId != null){
            EB = [Select Id, Name,Close_Date__c, ACV__c,Opportunity__c,Owner.name,
                  Opportunity__r.Name,Opportunity__r.Type,Executive_Name__c,Executive_Name__r.name,
                  Is_Meeting_Confirmed__c,Time_Zone__c,End_Time__c,Start_Time__c,
                  F2F_Webex__c,Location_Address__c,Travel_Required__c,Start_Date__c,End_Date__c,
                  Customer__r.Type,Customer__r.PPU__c,
                  Customer__r.Name, Business_Strategies__c,
                  Champion__c, Competitive_Overview__c, Critical_Capabilities__c, Current_Quarter_Opportunity__c,
                  Customer__c, Date_of_Meeting__c, Decision_Criteria__c, Decision_Process__c, Desired_Meeting_Outcome__c,
                  Economic_Buyer__c, Event_Type__c, Identified_Pain__c, Internal_Attendees__c, Metrics__c, 
                  Opportunity_Quarter__c, Opportunity_Type__c, Products__c, Purpose_of_Meeting_and_Agenda__c, RSM_Name__c,
                  Sales_Stage__c, SD_WAN_O365_and_AWS_Azure_Usage__c, Strategic_Initiatives__c, 
                  TCV__c, Value_Summary__c,Customer_Sentiment__c,ARR__c,Warning__c,
                  Is_Request_Already_Approved__c,Reason_for_Request__c,Total_Number_of_users_at_Account__c,Conference_Room_Details__c,
                  Why_Anything__c, Why_Now__c, Why_Zscaler__c from Executive_Briefing_Request__c where Id = :ebId];
            
            if( EB != null){
                
                meetingStartDate = String.valueOf( EB.Start_Date__c);
                meetingEndDate = String.valueOf( EB.End_Date__c);
                
                oppId = EB.Opportunity__c;
                
                if(EB.Opportunity__c != null){
                    isOpportunityExist = true;
                    parentName = EB.Opportunity__r.Name;
                }else if(EB.Customer__c != null){
                    isOpportunityExist = false;
                    parentName = EB.Customer__r.name;
                }
                
                //Set Meeting Date
                if(EB.Is_Meeting_Confirmed__c != null && EB.Is_Meeting_Confirmed__c){
                    isMeetingConfirmed = true;
                    meetingDate = (EB.Date_of_Meeting__c != null  || String.isNotEmpty(String.valueOf(EB.Date_of_Meeting__c))) ? getFormattedDate(EB.Date_of_Meeting__c,true) : ''  ;
                    meetingStartTime = (EB.Start_Time__c != null  || String.isNotEmpty(String.valueOf(EB.Start_Time__c))) ? getFormattedTime(EB.Start_Time__c) : ''  ;
                    meetingEndTime = (EB.End_Time__c != null  || String.isNotEmpty(String.valueOf(EB.End_Time__c))) ? getFormattedTime(EB.End_Time__c) : ''  ;
                }else{
                    isMeetingConfirmed = false;
                    meetingStartDate = (EB.Start_Date__c != null  || String.isNotEmpty(String.valueOf(EB.Start_Date__c))) ? getFormattedDate(EB.Start_Date__c,true) : ''  ;
                    meetingEndDate = (EB.End_Date__c != null  || String.isNotEmpty(String.valueOf(EB.End_Date__c))) ? getFormattedDate(EB.End_Date__c,true) : ''  ;
                }
                
                
                //Set Close Date
                if(EB.Close_Date__c != null || String.isNotEmpty(String.valueOf(EB.Close_Date__c))){
                    closeDate = getFormattedDate(EB.Close_Date__c,true);
                }
                
                //set TimeZone
                if(EB.Time_Zone__c != null || String.isNotEmpty(EB.Time_Zone__c)){
                    String tmz =  EB.Time_Zone__c; 
                    Integer idx =  tmz.indexOf(')');
                    if(idx+1 < tmz.length()){
                        timeZone = tmz.substring(idx+1);
                    }else{
                        timeZone = tmz;
                    }
                }
                
                //set Executive Name
                if(EB.Executive_Name__c != null && EB.Executive_Name__r.Name != null){
                    executiveName = EB.Executive_Name__r.Name;
                }else{
                    executiveName = approverName;
                }
                
                //Attendee List
                attendeeList = new  List<ExternalAttendee>();
                boolean isFirst= true;
                for(Executive_Briefing_External_Attendees__c ebr : [Select id,name,Attendee__r.name,Attendee__r.Title from
                                                                    Executive_Briefing_External_Attendees__c where 
                                                                    Executive_Briefing_Request__c = :ebId])
                {
                    if(isFirst){
                        attendeeList.add(new ExternalAttendee(ebr.Attendee__r.name,ebr.Attendee__r.Title,true));
                        isFirst = false;   
                    }else{
                        attendeeList.add(new ExternalAttendee(ebr.Attendee__r.name,ebr.Attendee__r.Title,false));
                    }
                }   
            }
        }
        return EB;
    } set;}
    
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([SELECT ActorId,Actor.Name,StepStatus,Comments 
                                                                         FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId = :ebId ORDER BY SystemModStamp DESC LIMIT 1]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }
    
    
    //get formatted Date
    private String getFormattedDate(Date valueToFormat, Boolean definedFormat) {
        if (valueToFormat == null) {
            return ''; 
        } else { 
            //return the full date in DD-MMM-YYYY
            if (definedFormat) {
                Date dt =  valueToFormat;
                String DD = String.valueOf(dt.day()).leftPad(2, '0');
                String MM = getMonthVal(dt.month()); 
                String YEAR = String.valueOf(dt.year());
                return DD+'-'+MM+'-'+YEAR;
            } else { 
                //return the full date/time in user's locale and time zone
                return valueToFormat.format(); 
            }
        }
    }
    
    
    public string getFormattedTime(Time timeToFormat){
        String frmTime = '';
        integer hour = timeToFormat.hour();
        integer minutes = timeToFormat.minute();
        Boolean isAM = hour < 12 ? true : false;
        if(isAM){
            if(hour == 0){
                frmTime = string.valueOf(12)  + ':'+  string.valueOf(minutes).leftPad(2, '0')+ ' AM';
            }else{
                frmTime = string.valueOf(hour).leftPad(2, '0') +':'+  string.valueOf(minutes).leftPad(2, '0') + ' AM';
            }
        }elsE{
            if(hour == 12){
                frmTime = string.valueOf(12)  + ':'+  string.valueOf(minutes).leftPad(2, '0')+ ' PM';
            }else{
                frmTime = string.valueOf(hour - 12).leftPad(2, '0')  + ':'+  string.valueOf(minutes).leftPad(2, '0')+ ' PM';
            }
        }
        return frmTime;
    }
    
    public String getMonthVal(Integer month){
        String ret = '';
        switch on month {
            when 1 {		
                ret = 'Jan' ;
            }when 2 {		
                ret = 'Feb' ;
            }when 3 {		
                ret = 'Mar' ;
            }when 4 {		
                ret = 'Apr' ;                
            }when 5 {		
                ret = 'May' ;
            }when 6 {		
                ret = 'Jun' ;
            }when 7 {		
                ret = 'Jul' ;
            }when 8 {		
                ret = 'Aug' ;
            }when 9 {		
                ret = 'Sep' ;
            }when 10 {		
                ret = 'Oct' ;
            }when 11 {		
                ret = 'Nov' ;
            }when 12 {		
                ret = 'Dec' ;
            }when else {		  
                ret = String.valueOf(month).leftPad(2, '0');
            }
        }
        
        return ret;
    }    
    
    public class ExternalAttendee{
        public string name {get; set;}
        public string title {get; set;}
        public boolean isFirst {get; set;}
        public ExternalAttendee(String name, String title, Boolean isFirst){
            this.name = name;
            this.title = title;
            this.isFirst = isFirst;
        }
    }
    
}