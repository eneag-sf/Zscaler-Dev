public class ProposalWizardController {
    String proposalId;
    private ApexPages.StandardController currentController ;
    public Apttus_Proposal__Proposal__c proposal {get; set;}
    public Boolean addRemoveJourney{get; set;}
    public Boolean addRemoveTA{get; set;}
    public Boolean addRemoveAD{get; set;}
    public Boolean addVMOReport{get;set;}
    public Boolean ShowESNote{get;set;}
    public boolean runGenerateDocument{get;set;}
    public List<Apttus_Config2__PriceMatrixEntry__c> priceMatrix{get;set;}
    public Integer zpaNoOfUsers {get; set;} 
    
    public ProposalWizardController(ApexPages.StandardController stdController) {
        this.currentController = stdController;
        proposal = new Apttus_Proposal__Proposal__c();
        proposalId = ApexPages.currentPage().getParameters().get(EncodingUtil.urlEncode('id','UTF-8'));
        addRemoveJourney = false;
        addRemoveTA = false;
        addRemoveAD = false;
        ShowESNote = false;
        proposal = [Select Id, Name, 
                    // Apttus_Proposal__Opportunity__c,
                        Company_Business_Drivers__c,
                        Solution_Summary__c,
                        Benefit_Impact_Summary__c,
                        Problem_Identification__c,
                        Solution_Details__c,
                        Insert_Blank_Page_for_VMO_Business_Case__c,
                        Add_Remove_Additional_Date__c,
                        Add_Remove_Journey__c,
                        Customer_Current_environment__c,
                        VMO_Report_blank_placeholder__c,
                        Poc_Section_blank_placeholder__c,
                        Include_ZIA_Coffee_Proposal__c,
                        Include_ZPA_Coffee_Proposal__c,
                        Adding_Security_layers__c,
                        Decrypting_SSL_and_finding_hidden_threat__c,
                        Extending_protection_to_mobile_users__c,
                        Having_equal_security_for_all_branches__c,
                        Removing_latency_and_congestion__c,
                        Directly_connecting_user_to_internet__c,
                        Prioritizing_business_apps__c,
                        Avoiding_costly_appliance_purchase__c,
                        Better_utilization_of_network_infrastruc__c,
                        Reducing_ongoing_effort_of_configuration__c,
                        Reducing_MPLS_backhaul_expenses__c,
                        Simplifying_the_connectivity_and_trouble__c,
                        Easily_adding_new_functionality__c,
                        Delivering_elastic_scale_of_cloud__c,
                       // Apttus_Proposal__Opportunity__r.Proposed_Number_of_Users__c,
                        ZIA_PRO_BUNDLE__c,ZIA_BUS_BUNDLE__c,ZIA_TRANS_BUNDLE__c,
                        ZPA_PRO__c,
                        ZPA_BUS__c,
                        ZPA_ENT__c,
                        No_of_Users__c,
                        No_of_users_ZIA__c,
                        No_of_users_ZPA__c,
                        ZIA_No_Users_for_Exec_Proposal__c,  
                        ZPA_No_Users_for_Exec_Proposal__c
                        FROM Apttus_Proposal__Proposal__c WHERE Id =: proposalId];
                    
        if(proposal.ZIA_No_Users_for_Exec_Proposal__c == null){
            proposal.ZIA_No_Users_for_Exec_Proposal__c = proposal.No_of_users_ZIA__c;
        }
        if(proposal.ZPA_No_Users_for_Exec_Proposal__c == null){
            proposal.ZPA_No_Users_for_Exec_Proposal__c = proposal.No_of_users_ZPA__c;
        }
        if(proposal.Company_Business_Drivers__c == null || proposal.Company_Business_Drivers__c == ''){
            proposal.Company_Business_Drivers__c = '';
            ShowESNote = true;
           
        } 
        priceMatrix = [select id,Product_Code__c,Apttus_Config2__Dimension1Value__c,Apttus_Config2__AdjustmentAmount__c from Apttus_Config2__PriceMatrixEntry__c  where Product_Code__c in ('ZIA-PRO-BUNDLE','ZIA-BUS-BUNDLE','ZIA-TRANS-BUNDLE','ZPA-PRO','ZPA-BUS','ZPA-ENT') order by Product_Code__c,Apttus_Config2__Dimension1Value__c];
        updateprices();
        if(proposal.Solution_Summary__c == null){
            proposal.Solution_Summary__c = '';
        }
        if(proposal.Benefit_Impact_Summary__c == null){
            proposal.Benefit_Impact_Summary__c = '';
        }
        if(proposal.Problem_Identification__c == null){
            proposal.Problem_Identification__c = '';
        }
        if(proposal.Customer_Current_environment__c == null){
            proposal.Customer_Current_environment__c = '';
        }
        if(proposal.Solution_Details__c == null){
            proposal.Solution_Details__c = '';
        }
        zpaNoOfUsers = Integer.valueOf(proposal.ZIA_No_Users_for_Exec_Proposal__c   );        
    }
    
    public PageReference goToNextWizard(){
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        quote.id = proposal.id;
        quote.Executive_Flag__c = true;
        quote.Company_Business_Drivers__c= proposal.Company_Business_Drivers__c;
        quote.Solution_Summary__c = proposal.Solution_Summary__c;
        quote.Benefit_Impact_Summary__c = proposal.Benefit_Impact_Summary__c;
        quote.Customer_Current_environment__c = proposal.Customer_Current_environment__c;
        quote.Problem_Identification__c = proposal.Problem_Identification__c;
        quote.Solution_Details__c = proposal.Solution_Details__c;
        //quote.Create_Space_for_VMO_Report__c = proposal.Create_Space_for_VMO_Report__c;
        quote.Adding_Security_layers__c = proposal.Adding_Security_layers__c;
        quote.Decrypting_SSL_and_finding_hidden_threat__c = proposal.Decrypting_SSL_and_finding_hidden_threat__c;
        quote.Extending_protection_to_mobile_users__c = proposal.Extending_protection_to_mobile_users__c;
        quote.Having_equal_security_for_all_branches__c = proposal.Having_equal_security_for_all_branches__c;
        quote.Removing_latency_and_congestion__c = proposal.Removing_latency_and_congestion__c;
        quote.Directly_connecting_user_to_internet__c = proposal.Directly_connecting_user_to_internet__c;
        quote.Prioritizing_business_apps__c = proposal.Prioritizing_business_apps__c;
        quote.Avoiding_costly_appliance_purchase__c = proposal.Avoiding_costly_appliance_purchase__c;
        quote.Better_utilization_of_network_infrastruc__c = proposal.Better_utilization_of_network_infrastruc__c;
        quote.Reducing_ongoing_effort_of_configuration__c = proposal.Reducing_ongoing_effort_of_configuration__c;
        quote.Reducing_MPLS_backhaul_expenses__c = proposal.Reducing_MPLS_backhaul_expenses__c;
        quote.Simplifying_the_connectivity_and_trouble__c = proposal.Simplifying_the_connectivity_and_trouble__c;
        quote.Easily_adding_new_functionality__c = proposal.Easily_adding_new_functionality__c;
        quote.Delivering_elastic_scale_of_cloud__c = proposal.Delivering_elastic_scale_of_cloud__c;               
        system.debug('exe flag = '+quote.Problem_Statement_Summary__c);
        if(proposal.Company_Business_Drivers__c ==null || String.isEmpty(proposal.Company_Business_Drivers__c)){
            quote.Executive_Flag__c = false;
        }
        try{
            update quote;
        }
        catch(DMLException dmlEx){
            System.debug('dmlEx Error = '+dmlEx);
        } 
        return new PageReference('/apex/ProposalWizardTwo');
    }
    
    public PageReference generateFinalDocument(){ 
        String attachmentId = GenerateDocWebServiceDemo_New.generateDocument(proposalId ,proposalId, userInfo.getSessionId());       
        PageReference pr = new PageReference('/'+ proposalId+'#'+proposalId+'_RelatedNoteList_target');
        //pr.setRedirect(true);
        return pr;
    }

     public PageReference goToPreviousWizard(){  
        updateprices();
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        quote.id = proposal.id;
        quote.Add_Remove_Additional_Date__c = proposal.Add_Remove_Additional_Date__c;
        quote.Add_Remove_Journey__c = proposal.Add_Remove_Journey__c;
        quote.VMO_Report_blank_placeholder__c = proposal.VMO_Report_blank_placeholder__c;
        quote.Poc_Section_blank_placeholder__c = proposal.Poc_Section_blank_placeholder__c;
        quote.Include_ZIA_Coffee_Proposal__c = proposal.Include_ZIA_Coffee_Proposal__c;
        quote.Include_ZPA_Coffee_Proposal__c = proposal.Include_ZPA_Coffee_Proposal__c;   
        quote.ZIA_PRO_BUNDLE__c = proposal.ZIA_PRO_BUNDLE__c;
        quote.ZIA_BUS_BUNDLE__c = proposal.ZIA_BUS_BUNDLE__c;
        quote.ZIA_TRANS_BUNDLE__c = proposal.ZIA_TRANS_BUNDLE__c;
        quote.ZPA_PRO__c = proposal.ZPA_PRO__c;
        quote.ZPA_BUS__c = proposal.ZPA_BUS__c;
        quote.ZPA_ENT__c = proposal.ZPA_ENT__c;
        quote.ZIA_No_Users_for_Exec_Proposal__c  = proposal.ZIA_No_Users_for_Exec_Proposal__c   ;
        quote.ZPA_No_Users_for_Exec_Proposal__c = proposal.ZPA_No_Users_for_Exec_Proposal__c;
                update quote;        
        return new PageReference('/apex/ProposalWizardOne');
    } 
    
     public PageReference generateDocument(){//BudgetaryProposal
       //return updateWizardTwoElements('/apex/GenerateProposalDemo?id='+proposal.id);
       //if(attachmentId != null){
           //PageReference pr = new PageReference('/apex/Attachment_Preview?id='+attachmentId);
           //pr.setRedirect(true);
           //return pr;
       //}
       //return null;
        updateprices();
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        quote.id = proposal.id;
        quote.Add_Remove_Additional_Date__c = proposal.Add_Remove_Additional_Date__c;
        quote.Add_Remove_Journey__c = proposal.Add_Remove_Journey__c;
        quote.VMO_Report_blank_placeholder__c = proposal.VMO_Report_blank_placeholder__c;
        quote.Poc_Section_blank_placeholder__c = proposal.Poc_Section_blank_placeholder__c;
        quote.Include_ZIA_Coffee_Proposal__c = proposal.Include_ZIA_Coffee_Proposal__c;
        quote.Include_ZPA_Coffee_Proposal__c = proposal.Include_ZPA_Coffee_Proposal__c;
        quote.ZIA_No_Users_for_Exec_Proposal__c  = proposal.ZIA_No_Users_for_Exec_Proposal__c   ;
        quote.ZIA_PRO_BUNDLE__c = proposal.ZIA_PRO_BUNDLE__c;
        quote.ZIA_BUS_BUNDLE__c = proposal.ZIA_BUS_BUNDLE__c;
        quote.ZIA_TRANS_BUNDLE__c = proposal.ZIA_TRANS_BUNDLE__c;
        quote.ZPA_PRO__c = proposal.ZPA_PRO__c;
        quote.ZPA_BUS__c = proposal.ZPA_BUS__c;
        quote.ZPA_ENT__c = proposal.ZPA_ENT__c;
        quote.ZIA_No_Users_for_Exec_Proposal__c  = proposal.ZIA_No_Users_for_Exec_Proposal__c   ;
        quote.ZPA_No_Users_for_Exec_Proposal__c = proposal.ZPA_No_Users_for_Exec_Proposal__c;
        update quote;
        runGenerateDocument = true;
        system.debug('run generatre ' + runGenerateDocument);  
        //String attachmentId = GenerateDocWebServiceDemo_New.generateDocument(proposalId ,proposalId, userInfo.getSessionId());       
        //PageReference pr = new PageReference('/'+ proposalId+'#'+proposalId+'_RelatedNoteList_target');
        //pr.setRedirect(true);
        return null; 
    }
    
   // public PageReference closeWizard(){
       // return updateWizardTwoElements('/'+proposalId);
   // }
   
    public PageReference updateWizardTwoElements(){
        updateprices();  
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c();
        quote.id = proposal.id;
        quote.Add_Remove_Additional_Date__c = proposal.Add_Remove_Additional_Date__c;
        quote.Add_Remove_Journey__c = proposal.Add_Remove_Journey__c;
        quote.VMO_Report_blank_placeholder__c = proposal.VMO_Report_blank_placeholder__c;
        quote.Poc_Section_blank_placeholder__c = proposal.Poc_Section_blank_placeholder__c;
        quote.Include_ZIA_Coffee_Proposal__c = proposal.Include_ZIA_Coffee_Proposal__c;  
        quote.Include_ZPA_Coffee_Proposal__c = proposal.Include_ZPA_Coffee_Proposal__c;
        quote.ZIA_No_Users_for_Exec_Proposal__c = proposal.ZIA_No_Users_for_Exec_Proposal__c;
        quote.ZIA_PRO_BUNDLE__c = proposal.ZIA_PRO_BUNDLE__c;
        quote.ZIA_BUS_BUNDLE__c = proposal.ZIA_BUS_BUNDLE__c;
        quote.ZIA_TRANS_BUNDLE__c = proposal.ZIA_TRANS_BUNDLE__c;
        quote.ZPA_PRO__c = proposal.ZPA_PRO__c;
        quote.ZPA_BUS__c = proposal.ZPA_BUS__c;
        quote.ZPA_ENT__c = proposal.ZPA_ENT__c;
        quote.ZIA_No_Users_for_Exec_Proposal__c = proposal.ZIA_No_Users_for_Exec_Proposal__c;
        quote.ZPA_No_Users_for_Exec_Proposal__c = proposal.ZPA_No_Users_for_Exec_Proposal__c;
        try{ 
           update quote;

        }
        catch(DMLException dmlEx){
            System.debug('dmlEx Error = '+dmlEx);
        } 
        return new PageReference('/'+proposalId);
    }
    
    public Pagereference cancel(){
        return new PageReference('/'+proposalId);
    }
    public void togglenote(){
        if(proposal.Company_Business_Drivers__c == null || proposal.Company_Business_Drivers__c == ''){
            ShowESNote = true;
        }else{
            ShowESNote = false;
        }
    } 
    
    public void updateprices(){
        Decimal tempZPB=0, tempZBB=0, tempZTB=0, tempZP=0, tempZB=0, tempZE=0;
        //Product_Code__c in ('ZIA-PRO-BUNDLE','ZIA-BUS-BUNDLE','ZIA-TRANS-BUNDLE','ZPA-PRO','ZPA-BUS','ZPA-ENT')
        for(Apttus_Config2__PriceMatrixEntry__c pm : priceMatrix){
            if(pm.Product_Code__c == 'ZIA-PRO-BUNDLE'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZIA__c <= dec && (tempZPB > dec || tempZPB == 0)){
                    proposal.ZIA_PRO_BUNDLE__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZPB = dec;
                }
            }
            if(pm.Product_Code__c == 'ZIA-BUS-BUNDLE'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZIA__c <= dec && (tempZBB > dec || tempZBB == 0))
                {
                    proposal.ZIA_BUS_BUNDLE__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZBB = dec;
                }
            }
            if(pm.Product_Code__c == 'ZIA-TRANS-BUNDLE'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZIA__c <= dec && (tempZTB > dec || tempZTB == 0))
                {
                    proposal.ZIA_TRANS_BUNDLE__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZTB = dec;
                }
            }
            if(pm.Product_Code__c == 'ZPA-PRO'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZPA__c <= dec && (tempZP > dec || tempZP == 0))
                {
                    proposal.ZPA_PRO__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZP = dec;
                }
            }
            if(pm.Product_Code__c == 'ZPA-BUS'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZPA__c <= dec && (tempZB > dec || tempZB == 0))
                {
                    proposal.ZPA_BUS__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZB = dec;
                }
            }
            if(pm.Product_Code__c == 'ZPA-ENT'){
                Decimal dec = decimal.valueof(pm.Apttus_Config2__Dimension1Value__c);
                if(proposal.No_of_users_ZPA__c <= dec && (tempZE > dec || tempZE == 0))
                {
                    proposal.ZPA_ENT__c = pm.Apttus_Config2__AdjustmentAmount__c/12;
                    tempZE = dec;
                  }
            }
        }
    }
}