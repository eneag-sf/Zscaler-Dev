/*****************************************************************************************
Name: manageAttendeesControllerExt
Copyright © Zscaler
==========================================================================================
==========================================================================================
Purpose:
--------
Extension controller for manageAttendees page, It is used to add/delete SCI Attendees and 
also to create new contact.
==========================================================================================
==========================================================================================
History
-------
VERSION        AUTHOR                  DATE              DETAIL              
1.0            Kunal Raj            4-Sep-2015    Initial Development
******************************************************************************************/ 


public class manageAttendeesControllerExt {
    
    public list<accContactWrapper> accContctWrapList {get; set;}
    public list<accContactWrapper> conSearchWrapList{get; set;}
    public list<accContactWrapper> newContactWrapList{get; set;}
    public string srchString {get; set;}
    public contact con {get;set;}
    public string accName{get; set;}
    public list<SCI_External_Attendee__c> SCIAttendeeList {get;set;}
    public Significant_Customer_Interaction__c sc {get; set;}
    public id conId {get; set;}
    public id attendeeId {get; set;}
    public string attendeeType{get; set;}
    
    public boolean noContactsFound {get; set;}
    
    public set<id> sciAttendeeSet {get; set;}
    
    public SCI_External_Attendee__c sciAttendee {get; set;}

    public manageAttendeesControllerExt(){}
    public boolean displayPopup {get; set;} 
   
    public PageReference createAndAddAttendee() { 
        try{
            insert con;
            sciAttendee = new SCI_External_Attendee__c();
            sciAttendee.Significant_Customer_Interaction__c = sc.Id;
            sciAttendee.Attendee_Name__c = Con.Id;
            insert sciAttendee;
            SCIAttendeeList = querySCIAttendees();
            sciAttendeeSet = prepareSCIDSet(SCIAttendeeList);
            accContctWrapList = fetchMissingConAsSCI();
            displayPopup = false;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ''+e.getMessage()));
            displayPopup = true;
        }
        
        return null;    
    }     
    public void cancel(){
        displayPopup = false;
    }
    public void showPopup() {        
        displayPopup = true;    
    } 
    public manageAttendeesControllerExt(ApexPages.StandardController controller) {
        accContctWrapList = new list<accContactWrapper>();
        conSearchWrapList = new list<accContactWrapper>();
        newContactWrapList = new list<accContactWrapper>();
        string sciID  =  '';
        srchString = '';
        attendeeType = '';
        accName = 'Contacts From ';
        noContactsFound = false;
        sciAttendee = new SCI_External_Attendee__c();
        SCIAttendeeList = new list<SCI_External_Attendee__c>();
        sciAttendeeSet = new set<Id>();
        //this.con =  (contact)controller.getRecord();
        this.con = new contact();
        sciID  =  ApexPages.currentPage().getParameters().get('SCID');
        sc = new Significant_Customer_Interaction__c();
        sc = [Select Id, Account_Name__r.Name, Account_Name__c, Opportunity_Name__c, Opportunity_Name__r.AccountId, Opportunity_Name__r.Account.Name, Area_of_Influence__c from Significant_Customer_Interaction__c where Id =:sciID ];
        if(sc.Opportunity_Name__c != null){
            accName+= sc.Opportunity_Name__r.Account.Name;
        }else{
            accName+= sc.Account_Name__r.Name;
        }
        
        SCIAttendeeList = querySCIAttendees();
        sciAttendeeSet = prepareSCIDSet(SCIAttendeeList);
        accContctWrapList = fetchMissingConAsSCI(); 
        this.con.AccountId = sc.Account_Name__c;
        sciAttendee.Significant_Customer_Interaction__c = sciId ;
    }
    
    public list<accContactWrapper> fetchMissingConAsSCI(){
        list<accContactWrapper> tempWrapList = new  list<accContactWrapper>();
        id  accId;
        if(sc.Opportunity_Name__c != null){
            accId = sc.Opportunity_Name__r.AccountId;
        }else{
            accId = Sc.Account_Name__c;
        }
            for(contact  con : [Select FirstName, LastName, Account.name, Email, Phone, Accountid, Id, Name,Project_Role__c from Contact Where AccountId =: accId limit 900]){
                if(!sciAttendeeSet.contains(con.id))
                    tempWrapList.add(new accContactWrapper(con)); 
            }
        return tempWrapList;
    }

    public set<id> prepareSCIDSet(list<SCI_External_Attendee__c> SCIAttendeeList){
        set<id> tempIdSet = new set<Id>();
        for(SCI_External_Attendee__c sci : SCIAttendeeList){
            if(sci.Attendee_Name__c != null)
                tempIdSet.add(sci.Attendee_Name__c);
        }
        return tempIdSet;
    }
    
    public list<SCI_External_Attendee__c> querySCIAttendees(){
        list<SCI_External_Attendee__c> sciAttendeeList = new list<SCI_External_Attendee__c>();
        if(sc != null)
            sciAttendeeList = [Select id, Attendee_Name__r.Name, Attendee_Name__r.AccountId, Account__c, Type__c, Attendee_Name__r.Head_Of_It__c,Attendee_Name__r.Head_of_networking__c, Attendee_Name__r.Head_of_Security__c, Attendee_Name__r.Budget_Authority__c, Attendee_Name__r.Procurement_Contact__c from SCI_External_Attendee__c where Significant_Customer_Interaction__c =: sc.ID Order By CreatedDate];
        
        return sciAttendeeList;
    }
    
    public PageReference addAsSCI() {
        SCI_External_Attendee__c tempSCI = new SCI_External_Attendee__c();
        tempSCI.Attendee_Name__c = ConId;
        tempSCI.Significant_Customer_Interaction__c = sc.Id;
        integer i = -1;
        boolean confond = false;
        for(accContactWrapper temWrap : conSearchWrapList){
                i++;
            if(temWrap.con.Id == conId){
                confond = true;
                attendeeType = temWrap.selectedType;
                break;
            }
        }
        system.debug('# attendeeType : '+attendeeType);
        if(attendeeType != '')
            tempSCI.Type__c = attendeeType;
        else
            tempSCI.Type__c = 'Customer';
        insert tempSCI;
    
        if(confond)
            conSearchWrapList.remove(i);
        SCIAttendeeList = querySCIAttendees();
        set<String> attendeesTypeSet = new set<string>();
        string attendeesType = '';
        for(SCI_External_Attendee__c attendee : SCIAttendeeList){
            if(attendee.Attendee_Name__r.Head_Of_It__c)
                attendeesTypeSet.add('Head of IT;');
            if(attendee.Attendee_Name__r.Head_of_networking__c)
                attendeesTypeSet.add('Head of Networking;');    
            if(attendee.Attendee_Name__r.Head_of_Security__c)
                attendeesTypeSet.add('Head of Security;');
            if(attendee.Attendee_Name__r.Budget_Authority__c)
                attendeesTypeSet.add('Budget Authority;');
            if(attendee.Attendee_Name__r.Procurement_Contact__c)
                attendeesTypeSet.add('Procurement Contact;');
        }

        for(String str : attendeesTypeSet)
            attendeesType += str;
        
        sc.Area_of_Influence__c = attendeesType;
        database.Update(sc, false);
        sciAttendeeSet = prepareSCIDSet(SCIAttendeeList);
        accContctWrapList = fetchMissingConAsSCI();
        attendeeType = '';
        return null;
    }
    
    public PageReference deleteSCIAttendee(){
        
        list<SCI_External_Attendee__c> tempList = new list<SCI_External_Attendee__c>();
        tempList =  [select id from SCI_External_Attendee__c where Id =: attendeeId];
        database.delete(tempList, false);
        string attendeesType = '';
        SCIAttendeeList = querySCIAttendees();
        set<String> attendeesTypeSet = new set<string>();
        for(SCI_External_Attendee__c attendee : SCIAttendeeList){
            if(attendee.Attendee_Name__r.Head_Of_It__c)
                attendeesTypeSet.add('Head of IT;');
            if(attendee.Attendee_Name__r.Head_of_networking__c)
                attendeesTypeSet.add('Head of Networking;');    
            if(attendee.Attendee_Name__r.Head_of_Security__c)
                attendeesTypeSet.add('Head of Security;');
            if(attendee.Attendee_Name__r.Budget_Authority__c)
                attendeesTypeSet.add('Budget Authority;');
            if(attendee.Attendee_Name__r.Procurement_Contact__c)
                attendeesTypeSet.add('Procurement Contact;');
        }

        for(String str : attendeesTypeSet)
            attendeesType += str;
        sc.Area_of_Influence__c = attendeesType; 
        database.Update(sc, false);
        sciAttendeeSet = prepareSCIDSet(SCIAttendeeList);
        accContctWrapList = fetchMissingConAsSCI();
        return null;
    }

    public PageReference clearSearch() {
        noContactsFound = false;
        srchString = '';
        conSearchWrapList.clear();
        return null;
    }
    
    public PageReference addNewContact() {
        con = new contact(AccountId = sc.Account_Name__c);
        displayPopup = true;  
        return null;
    }
   
    public PageReference searchContacts() {
        if(srchString != null && srchString !=''){
            srchString = srchString.trim();
            conSearchWrapList.clear();
            list<contact> conList = new List<Contact>();
            conList = database.query('Select FirstName, LastName, Account.name, Email, Phone, Accountid, Id, Name, Project_Role__c From Contact WHERE Name LIKE \'%' + srchString + '%\'OR EMAIl=:srchString limit 20');
            for(contact con : conList){
                if(sciAttendeeSet != null && !sciAttendeeSet.Contains(con.id))
                    conSearchWrapList.add(new accContactWrapper(con));
            }
             if(conSearchWrapList == null || conSearchWrapList.isEmpty())
                noContactsFound = true;
            if(conSearchWrapList == null || !conSearchWrapList.isEmpty())   
                noContactsFound = false;
            
            srchString = '';            
        }
        return null;
    }


    public class accContactWrapper{
        public boolean isSelected{get; set;}
        public contact con{get; set;}
        public List<selectOption> attendeeType {get; set;} 
        public string selectedType {get; set;}
        public accContactWrapper(Contact cont){
            isSelected = false;
            con = cont;
            selectedType = '';
            attendeeType = new List<selectOption>();
            Schema.DescribeFieldResult field = Schema.sObjectType.SCI_External_Attendee__c.fields.Type__c;
            List<Schema.PicklistEntry> picklist = field.getPicklistValues();
            for(Schema.PicklistEntry p : picklist) {
                SelectOption so = new Selectoption(p.getLabel(), p.getLabel());
                attendeeType.add(so);
            } 
        }
        
    }


}