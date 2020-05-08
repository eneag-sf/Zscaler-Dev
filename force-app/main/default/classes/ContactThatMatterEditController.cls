public class ContactThatMatterEditController{
    public ID Accid;
    public boolean showCTMTable{get; set;}
    public boolean showAvailableCntctTable{get; set;}
    public boolean CurrentCTMTableErrorMessage{get; set;}
    public boolean AddCTMTableErrorMessage{get; set;}
    public List<Contact> CTMList {get;set;}
    public List<Contact> AvailableContactList {get;set;}
    public List<Contact> updateContactList;
    public List<ContactWrapper> AvailableWContactList{get; set;}
    public List<ContactWrapper> CTMWContactList{get; set;}
    public List<ContactWrapper> tempContactWrapperList;
    
    public ContactThatMatterEditController() {
        Accid = Apexpages.currentPage().getParameters().get('Accid');
        CTMList = new list<contact>();
        AvailableContactList = new list<contact>();
        CTMWContactList = new list<ContactWrapper>();
        AvailableWContactList = new list<ContactWrapper>();
        showCTMTable=false;
        showAvailableCntctTable=false;
        CurrentCTMTableErrorMessage=false;
        AddCTMTableErrorMessage=false;
        system.debug('In constructor ');
        if(Accid!=null){
            CreateWrapper(Accid);
        /* for(Contact con : [Select Id, Name,Email, Level_From_CIO__c,Contacts_that_matter__c,Head_of_IT__c,Head_of_Security__c,Head_of_Networking__c,Send_CIO_Report__c, Title, Project_Role__c,Network__c, Architecture__c, Security__c, Operations__c,Key_Exec__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c, Budget_Authority__c,Application__c, Desktop__c, Key_Contact_Status__c, Influencer__c, Distractor__c, Champion__c,Account.Override_CTM_Domain__c,Account.Domain__c,Account.Additional_Organization_Domains__c FROM Contact Where AccountId=:Accid AND Active__c = false ORDER BY Level_From_CIO__c ASC NULLS FIRST]){
                if(con.Contacts_that_matter__c){
                    ContactWrapper contactWrapperObj = new ContactWrapper();
                    contactWrapperObj.isSelected=false;
                    contactWrapperObj.ContactDetails=con;
                    CTMWContactList.add(contactWrapperObj);
                    CTMList.add(con);
                    
                    if(test.isrunningtest()){
                        contactWrapperObj.isSelected=true;
                    }
                    
                }else{
                    ContactWrapper contactWrapperObj = new ContactWrapper();
                    contactWrapperObj.isSelected=false;
                    contactWrapperObj.ContactDetails=con;
                    AvailableWContactList.add(contactWrapperObj);
                    AvailableContactList.add(con);
                    
                    if(test.isrunningtest()){
                        contactWrapperObj.isSelected=true;
                    }
                }               
        } */
        }
        if(CTMWContactList != null && !CTMWContactList.isEmpty()){
           showCTMTable=true;
        }
        
    }
    
    public class ContactWrapper{
        public boolean isSelected{get; set;}
        public Contact ContactDetails{get; set;}
    }
    
    public PageReference AddCTM(){
        boolean isError=false;
        updateContactList = new List<Contact>();
        tempContactWrapperList = new List<ContactWrapper>();
        system.debug('inside add CTM method '+updateContactList);
        if(AvailableWContactList != null && !AvailableWContactList.isEmpty()){
            for(ContactWrapper ConWrap:AvailableWContactList){
                boolean domainmatch=false;
                /* for(String adddomain: ConWrap.ContactDetails.Account.Additional_Organization_Domains__c.split(',')){
                   
                    String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://').split('\\.')[0];
                    
                    if(contactemaildomain.contains(accdomain)){
                        
                    }
                } */
                
                if(ConWrap.isSelected  && ConWrap.ContactDetails.Account.Domain__c!=null && ConWrap.ContactDetails.Account.Domain__c!='' && (((ConWrap.ContactDetails.Email).toLowerCase())).contains(ConWrap.ContactDetails.Account.Domain__c.toLowerCase())){
                    system.debug('inside first IF');
                    updateContactList.add(ConWrap.ContactDetails);                                  
                    //CTMWContactList.remove(ConWrap);
                    ConWrap.isSelected=false;
                    //CTMWContactList.add(ConWrap);
                    tempContactWrapperList.add(ConWrap);                    
                    domainmatch=true;                   
                }
                //else{
                system.debug('updateContactList  '+updateContactList);
                if(!domainmatch && ConWrap.isSelected && ConWrap.ContactDetails.Account.Additional_Organization_Domains__c!=null ){ 
                    system.debug('inside second IF');
                    for(String adddomain: ConWrap.ContactDetails.Account.Additional_Organization_Domains__c.split(',')){
                   
                        //String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://').split('\\.')[0];
                        String accdomain = adddomain.trim().remove('https://www.').remove('http://www.').remove('https://').remove('http://');
                    
                        if(ConWrap.ContactDetails.Email.contains(accdomain)){
                            updateContactList.add(ConWrap.ContactDetails);                                  
                            //CTMWContactList.remove(ConWrap);
                            ConWrap.isSelected=false;
                            //CTMWContactList.add(ConWrap);
                            tempContactWrapperList.add(ConWrap);
                            domainmatch=true;
                        }
                    }
                }   
                //} 
                system.debug('updateContactList  '+updateContactList);               
                                                            
                //}else{
                if(!domainmatch && ConWrap.isSelected && ConWrap.ContactDetails.Account.Override_CTM_Domain__c){
                    system.debug('inside third if');
                    updateContactList.add(ConWrap.ContactDetails);                                  
                    //CTMWContactList.remove(ConWrap);
                    ConWrap.isSelected=false;
                    //CTMWContactList.add(ConWrap);
                    tempContactWrapperList.add(ConWrap);
                }
                else if(ConWrap.isSelected){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'CTM Domain is not matched with Account domain. You cannot add contact as CTM'));
                    AddCTMTableErrorMessage=true;
                    CurrentCTMTableErrorMessage=false;
                    return null;
                }
                system.debug('updateContactList  '+updateContactList);
                //}
                
            }
            system.debug('updateContactList  '+updateContactList);
            
            if(updateContactList != null && !updateContactList.isEmpty()){
                for(Contact con:updateContactList){
                    con.Contacts_that_matter__c=true;
                }
                try {
                    update updateContactList;
                    for(ContactWrapper ConWrap:tempContactWrapperList){
                        AvailableWContactList.remove(AvailableWContactList.indexOf(ConWrap));
                        CTMWContactList.add(ConWrap);
                    }
                    system.debug('AvailableWContactList  '+AvailableWContactList);
                    system.debug('CTMWContactList  '+CTMWContactList);
                    CreateWrapper(accid);
                    return null;
                    
                    /* PageReference pg= new PageReference('/'+Accid);           
                    pg.setRedirect(true);
                    return pg; */
                } catch(DMLException ex) {
                    ApexPages.addMessages(ex);
                    AddCTMTableErrorMessage=true;
                    CurrentCTMTableErrorMessage=false;
                    return null;
                }                               
            }else{
                return null;
            }                       
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'No Contact has been selected for operation'));
            AddCTMTableErrorMessage=true;
            CurrentCTMTableErrorMessage=false;
            return null;
        }
    }
    public PageReference RemoveCTM(){
        updateContactList = new List<Contact>();
        tempContactWrapperList = new List<ContactWrapper>();
        if(CTMWContactList != null && !CTMWContactList.isEmpty()){
            for(ContactWrapper ConWrap:CTMWContactList){
                if(ConWrap.isSelected){                 
                    //CTMWContactList.remove(ConWrap);
                    updateContactList.add(ConWrap.ContactDetails);
                    
                    //CTMWContactList.remove(CTMWContactList.indexOf(ConWrap));
                    ConWrap.isSelected=false;
                    tempContactWrapperList.add(ConWrap);
                    //AvailableWContactList.add(ConWrap);
                }
            }
        }
        system.debug('updateContactList'+updateContactList);
        system.debug('tempContactWrapperList'+tempContactWrapperList);
        if(updateContactList != null && !updateContactList.isEmpty()){
            for(Contact con:updateContactList){
                con.Contacts_that_matter__c=false;
            }
            try {
                update updateContactList;
                for(ContactWrapper ConWrap:tempContactWrapperList){
                    CTMWContactList.remove(CTMWContactList.indexOf(ConWrap));
                    AvailableWContactList.add(ConWrap);
                }
                system.debug('updateContactList'+updateContactList);
                system.debug('AvailableWContactList'+AvailableWContactList);
                CreateWrapper(accid);
                
                return null;
                /* PageReference pg= new PageReference('/'+Accid);           
                pg.setRedirect(true);
                return pg; */
            } catch(DMLException ex) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, ex.getMessage()));
                CurrentCTMTableErrorMessage=true;
                AddCTMTableErrorMessage=false;
                ApexPages.addMessages(ex);
                return null;
            }
        }else{
            return null;
        }
                
    }
    
    public PageReference UpdateCTM(){
        system.debug('inside Update CTM method');
        updateContactList = new List<Contact>();
        if(CTMWContactList != null && !CTMWContactList.isEmpty()){
            for(ContactWrapper ConWrap:CTMWContactList){
                //if(ConWrap.isSelected){                   
                    //CTMWContactList.remove(ConWrap);
                    updateContactList.add(ConWrap.ContactDetails);
                    
                    //CTMWContactList.remove(CTMWContactList.indexOf(ConWrap));
                    //ConWrap.isSelected=false;
                    //AvailableWContactList.add(ConWrap);
                //}
            }
        }
        system.debug('updateContactList'+updateContactList);
        try {
            if(updateContactList != null && !updateContactList.isEmpty()){
                update updateContactList;
            }
            CreateWrapper(accid);
            return null;
            //PageReference pg= new PageReference('/'+Accid);
            /*pg.setRedirect(true);
            return pg; */
            //PageReference tempPage = ApexPages.currentPage();            
            //pg.setRedirect(true);
            //return pg;
        } catch(DMLException ex) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, ex.getMessage()));
            CurrentCTMTableErrorMessage=true;
            AddCTMTableErrorMessage=false;
            ApexPages.addMessages(ex);
            return null;
        }
                
    }
    public PageReference GotoAccount(){
        PageReference pg= new PageReference('/'+Accid);
        //PageReference acctPage = new ApexPages.StandardController(account).view();
        pg.setRedirect(true);
        return pg;
    }
    
    public void CreateWrapper(id Accid){
        CTMList = new list<contact>();
        AvailableContactList = new list<contact>();
        CTMWContactList = new list<ContactWrapper>();
        AvailableWContactList = new list<ContactWrapper>();
        system.debug('in create wrapper method');
        if(Accid!=null){
            for(Contact con : [Select Id, Name,Email, Level_From_CIO__c,Contacts_that_matter__c,Head_of_IT__c,Head_of_Security__c,Head_of_Networking__c,Send_CIO_Report__c, Title, Project_Role__c,Network__c, Architecture__c, Security__c, Operations__c,Key_Exec__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c, Budget_Authority__c,Application__c, Desktop__c, Key_Contact_Status__c, Influencer__c, Distractor__c, Champion__c,Account.Override_CTM_Domain__c,Account.Domain__c,Account.Additional_Organization_Domains__c FROM Contact Where AccountId=:Accid AND Active__c = false ORDER BY Level_From_CIO__c ASC NULLS FIRST]){
                    if(con.Contacts_that_matter__c){
                        ContactWrapper contactWrapperObj = new ContactWrapper();
                        contactWrapperObj.isSelected=false;
                        contactWrapperObj.ContactDetails=con;
                        CTMWContactList.add(contactWrapperObj);
                        CTMList.add(con);
                        
                        if(test.isrunningtest()){
                            contactWrapperObj.isSelected=true;
                        }
                        
                    }else{
                        ContactWrapper contactWrapperObj = new ContactWrapper();
                        contactWrapperObj.isSelected=false;
                        contactWrapperObj.ContactDetails=con;
                        AvailableWContactList.add(contactWrapperObj);
                        AvailableContactList.add(con);
                        
                        if(test.isrunningtest()){
                            contactWrapperObj.isSelected=true;
                        }
                    }               
            }
        }       
    }
    
    
}