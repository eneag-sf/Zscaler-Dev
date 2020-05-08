public class ContactThatMattersControllerExt {
    public List<Contact> contactList {get;set;}
    Private Account Acc;
    public ContactThatMattersControllerExt(ApexPages.StandardController controller) {
        this.Acc = (Account)controller.getRecord();
        contactList = new list<contact>();
        list<Contact> contactWithNoLevel = new List<Contact>();
        //OR Key_Exec__c <> NULL OR Key_Exec__c <> ''
        
        for(Contact con : [Select Id, Name,Email,Level_From_CIO__c, Title, Project_Role__c,Network__c, Architecture__c, Security__c, Operations__c,Head_of_IT__c,Head_of_Security__c,Head_of_Networking__c,Send_CIO_Report__c, 
                            Key_Exec__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c, Budget_Authority__c, 
                            Application__c, Desktop__c, Key_Contact_Status__c, Influencer__c, Distractor__c, Champion__c   FROM Contact Where AccountId =: Acc.Id 
                            AND (Contacts_that_matter__c =: true) 
                            and Active__c = false ORDER BY  Level_From_CIO__c ASC NULLS FIRST]){
            if(con.Level_From_CIO__c != '' && con.Level_From_CIO__c != null){
                contactList.add(Con);
            }else{
                contactWithNoLevel.add(Con);
            }
        }
        if(!contactWithNoLevel.isEmpty())
            contactList.addAll(contactWithNoLevel);
    }
    public PageReference Updatecontacts(){
        if(contactList!=null && !contactList.isempty() && contactList.size()>0){
            update contactList;
        }
        //PageReference tempPage = ApexPages.currentPage();
        //return tempPage;
        //return new PageReference('/'+acc.Id);
        contactList.clear();
        
        for(Contact con : [Select Id, Name,Email,Level_From_CIO__c, Title, Project_Role__c,Network__c, Architecture__c, Security__c, Operations__c,Head_of_IT__c,Head_of_Security__c,Head_of_Networking__c,Send_CIO_Report__c, Key_Exec__c, Procurement_Contact__c, Cloud_Architect__c, Service_Owner__c, Budget_Authority__c,Application__c, Desktop__c, Key_Contact_Status__c, Influencer__c, Distractor__c, Champion__c   FROM Contact Where AccountId =: Acc.Id AND (Contacts_that_matter__c =: true) and Active__c = false ORDER BY  Level_From_CIO__c ASC NULLS FIRST]){
            contactList.add(Con);
        }
        return null;
    }
    public Pagereference Cancel(){

        //return new PageReference('/'+acc.Id);
        return null;
    }
}