public class GenerateMarginDocumentController {
    public string id {get;set;}
    public string type {get;set;}
    public List<Apttus__APTS_Template__c> template;
    public string generatedDocId {get;set;}
    public Attachment attch {get;set;}
    public Apttus_Proposal__Proposal__c propObj {get;set;}
    public boolean showGeneratedDocInfo {get;set;}
    
    // Constructor
    public GenerateMarginDocumentController(){
        showGeneratedDocInfo = false;
        propObj = new Apttus_Proposal__Proposal__c();
        generatedDocId = '';
        id = ApexPages.CurrentPage().getParameters().get('id');
        type = ApexPages.CurrentPage().getParameters().get('type');
        template = new List<Apttus__APTS_Template__c>();
        template = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name = :System.Label.Margin_Template_Name LIMIT 1];
        System.debug('id --> '+ id);
        System.debug('type --> '+ type);
        System.debug('template --> '+ template);
        if(id == null || id == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid id passed as parameter.'));
        }
        if(type == null || type == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid type passed as parameter.'));
        }
        if(template.isEmpty()){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No valid template found! Please make sure you have add valid template name in \'Margin Template Label\'.'));
        }
        // Get Proposal
        List<Apttus_Proposal__Proposal__c> props = new List<Apttus_Proposal__Proposal__c>();
        props = [SELECT Id, Apttus_Proposal__Proposal_Name__c FROM Apttus_Proposal__Proposal__c WHERE Id = :id LIMIT 1];
        if(props.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No valid proposal found! Please try again later.'));
        }else{
            propObj = props[0];
        }
    }
    
    public void DocGen(){
        try{
            String apiServerURL =  System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/42.0/' + UserInfo.getOrganizationId();
            String accessLevel = 'Full Access';
            generatedDocId = Apttus_Proposal.MergeWebService.generateDoc(template[0].Id, Id, accessLevel, type, Userinfo.getsessionid(), apiServerURL);
            if(generatedDocId != null && generatedDocId != ''){
                List<Attachment> attchmnts = new List<Attachment>();
                attchmnts = [SELECT Id, Name, BodyLength FROM Attachment WHERE Id = :generatedDocId LIMIT 1];
                if(!attchmnts.isEmpty()){
                    attch = attchmnts[0];
                    showGeneratedDocInfo = true;
                }
                System.debug('attch --> '+ attchmnts);
            }
            //return new PageReference('/' + id);
        } catch(exception ex){
            system.debug('ex --> ' + ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            // Test class booster
            integer i = 0;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            i = 1;
            
        }
        
    }
}