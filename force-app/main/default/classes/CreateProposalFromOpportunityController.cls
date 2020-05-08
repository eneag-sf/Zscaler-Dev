/**
 * @Description        : 
 * @Author             : Minkesh Patel
 
**/
public class CreateProposalFromOpportunityController {

    public string errorMessage      {get;set;}
    public boolean hasError         {get;set;}
    public string selectedModelType {get;set;}
    public Opportunity oppRecord    {get;set;}
     
    /*
        Constructor
    */
    public CreateProposalFromOpportunityController(ApexPages.StandardController stdController){
        List<String> fields = new List<String>();
        fields.add('Type');
        fields.add('Recordtype.Name');
        if(!test.isrunningTest())
            stdController.addfields(fields);

        oppRecord = (Opportunity) stdController.getRecord();
        hasError = false;
        selectedModelType = '';
    }


    
    /*
        Check Model
    */
    public PageReference checkOpportunityReseller(){
      
        String message = CreateProposalModelUtilClass.checkOpportunityReseller(selectedModelType,oppRecord);
        if(message == 'error'){
            hasError = true;
            errorMessage = 'Primary Reseller Partner is required to create Proposal';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage ));
            return null;
        }else if(message == 'Show Model'){
            hasError = false;
            return null;
        }else{
            return new PageReference(message);

        }
    }
    
    /*
        Check Opportunity Reseller From opportunity Partner
    */
    
    public PageReference createNewQuote() {
        return new PageReference(CreateProposalModelUtilClass.createNewQuote(selectedModelType,oppRecord));
    }

    
    /**
     * Performs the cancel action
     * @return the next page reference 
     */
    public PageReference doCancel() {
        // navigate to the opportunity 
        return new PageReference('/' + oppRecord.Id);
    }
    
    /*
        Model Type For Proposal
    */
    public List<SelectOption> getModelTypeItems() {
        return CreateProposalModelUtilClass.getModelTypeItems();  
    }
}