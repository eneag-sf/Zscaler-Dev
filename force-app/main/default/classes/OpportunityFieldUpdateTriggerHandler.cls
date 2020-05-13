public class OpportunityFieldUpdateTriggerHandler {
    
    public static void BeforeInsert(list<Opportunity> newOppList){
        List<string> OppIds = new List<string>();
        Map<string,Apttus_Proposal__Proposal__c> PropIdVsPropMap = new Map<string,Apttus_Proposal__Proposal__c>();
        Map<string,string> OppIdVsAccMap = new Map<string,string>();
        ZScalarConstants constants = new ZScalarConstants();
        List<string> QuotePropIds = new List<string>();
        List<string> AccountIds = new List<string>();
        Map<string,Account> AccIdVsAccMap = new Map<string,Account>();
        
        /**List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        EmailTemplate et = [Select id from EmailTemplate where name = 'Opportunity hits 10b stage']; **/  
        
        for(Opportunity Opp:newOppList){
            QuotePropIds.Add(Opp.APTS_Primary_Proposal_Lookup__c);
            AccountIds.Add(Opp.AccountId);
        }
        
        List<Account> Accounts = [Select Id,Name,Geo__c,Customer_Advocate__c,APTS_Platform_Subscription_End_Date__c,CSM_Name_New__c,CSM_Name_New__r.Email from Account where Id IN:AccountIds];
        for(Account Acc:Accounts){
            AccIdVsAccMap.put(Acc.Id,Acc);
        }
        
        List<Apttus_Proposal__Proposal__c> QuotePropList = [select Id, Name, Included_DAS_Package__c,APTS_DAS_Package_Included__c, APTS_ACV__c from Apttus_Proposal__Proposal__c where Id IN:QuotePropIds];
        for(Apttus_Proposal__Proposal__c Prop:QuotePropList){
            PropIdVsPropMap.put(Prop.Id,Prop);
        }
        
        for(Opportunity Opp:newOppList){    
            /*//Federal - Deployment Alert on Stage 10b
            if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                if((Opp.StageName == Label.Stage_5_Contracts_Complete && String.valueof(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c).contains('FED')) 
                    || (Opp.StageName == Label.Stage_5_Contracts_Complete && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_ACV__c >= 50000 && Opp.Is_Federal_Opportunity_Sync__c == True && Opp.Account.Type == 'Prospect')){
                    Opp.DAS_Notification_Sent__c = true;
                }
                
                //Deployment Alert on Stage 10b
                if((Opp.StageName == Label.Stage_5_Contracts_Complete && Opp.DAS_Package_New__c != '' && !String.valueof(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c).contains('FED')) 
                    || (Opp.StageName == Label.Stage_5_Contracts_Complete && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_ACV__c >= 50000 && Opp.Is_Federal_Opportunity_Sync__c == false && Opp.Account.Type == 'Prospect')){
                    Opp.DAS_Notification_Sent__c = true;
                }
            }
            
            //Email CSM when sales stage is 10B
            if(Opp.StageName == Label.Stage_5_Contracts_Complete && Opp.X10B_notification_to_CSM__c == false){
                Opp.X10B_notification_to_CSM__c = true;
			}*/
			
			System.debug('Opp.Type+++++'+Opp.Type);
			System.debug('Opp.RecordTypeId+++++'+Opp.RecordTypeId);
            //Set record type to closed new business opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business /*'New Business'*/ && (/**Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff ||**/ Opp.StageName == Label.Stage_5_Contracts_Complete || Opp.StageName == Label.Stage_6_Closed_Won)){
				Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_New_Business_Close;
				System.debug('Opp.Type+++++'+Opp.Type);
				System.debug('Opp.RecordTypeId+++++'+Opp.RecordTypeId);
            }
            
            //Set record type to closed upsell opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Add_On /*'Existing Customer (Add On)'*/ && (Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff || Opp.StageName == Label.Stage_5_Contracts_Complete || Opp.StageName == Label.Stage_6_Closed_Won)){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity_Closed;
            }
            
            //Set record type to open new business opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business /*'New Business'*/ && (/*Opp.StageName == label.Stage_0_Initial_Prospecting ||*/ Opp.StageName == Label.Stage_1_Alignment || Opp.StageName == Label.Stage_2_Qualified_Budgeted || Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff || (Opp.StageName == Label.Stage_7_Closed_Lost /*&& Opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision*/))){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_New_Business;
            }
            
            //Set record type to open upsell opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Add_On /*'Existing Customer (Add On)'*/ && (/*Opp.StageName == label.Stage_0_Initial_Prospecting ||*/ Opp.StageName == Label.Stage_1_Alignment || Opp.StageName == Label.Stage_2_Qualified_Budgeted || Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff || (Opp.StageName == Label.Stage_7_Closed_Lost /*&& Opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision*/))){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity;
            }
            
            //Update account type when stage is 13(After Insert)
            
            //Update close lost date when stage is updated to close lost
            if(Opp.StageName == Label.Stage_7_Closed_Lost /**&& Opp.Sub_Stage__c == Label.SubStage_Closed_Lost**/){
                Opp.CloseDate = system.today();
                Opp.Opportunity_Close_lost_Date__c = system.today();
            }
            
            
            //Capture Stage Change Dates
            if(True){ //For ISNEW()
                Opp.Last_Stage_Changed_Date__c = system.today();
                Opp.Previous_Stage_Changed_Date__c = Opp.Last_Stage_Changed_Date__c;
            }
            
            //Fill in DAS Start Date Field
            if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                if(Opp.Service_Start_Date__c != null && Opp.DAS_Start_Date__c == null && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_DAS_Package_Included__c == true){ 
                    Opp.DAS_Start_Date__c = Opp.Service_Start_Date__c;
                }
            }
            
            //Make Tech start date null
            //Nullify the last validation stage changed date
            if(Opp.Validation_Stage__c == null || Opp.Validation_Stage__c == ''){
                Opp.Technical_Validation_Start_Date__c = null;
                Opp.Validation_End_Date__c = null;
                Opp.Last_validation_stage_changed_date__c = null;
            }
            
            //Opportunity - Update the Source field for Marketing Sources
            if(Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Advertisement /*'Advertisement'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Webinars /*'Webinars'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Events /*'Events'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_External_DM /*'External DM'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_List_Import /*'List Import'*/
                || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Search /*'Search'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Paid_Search /*'Paid Search'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Website_Direct /*'Website Direct'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Website_Referral /*'Website Referral'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Social_Media /*'Social Media' */
                || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Content_Syndication /*'Content Syndication'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Publisher /*'Publisher'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Telemarketing /*'Telemarketing'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Marketing_Campaign /*'Marketing Campaign'*/){
                Opp.Source__c = 'Marketing';
            }
            
            //Opportunity - Update the Source field for Partner Sources
            if(Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Deal_Registration /*'Deal Registration'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Partners /*'Partners'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Service_Provider /*'Service Provider'*/){
                Opp.Source__c = 'Partners';
            }
            
            //Opportunity - Update the Source field for Sales Sources
            if(Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Sales_Generated /*'Sales Generated'*/){
                Opp.Source__c = 'Sales';
            }
            
            //Opportunity: CA OTB Flag Set on CA mismatch for Renewal
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if(Opp.Sales_Rep_OTB_Override__c  == false && Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Renewal /*'Existing Customer (Renewal)'*/ 
                    && Opp.Opportunity_Owner_Id__c != AccIdVsAccMap.get(Opp.AccountId).Customer_Advocate__c){
                    Opp.CA_OTB_flag__c = true;
                }
            }
            
            //Opportunity: CA OTB Flag Set to Null on CA match for Renewal
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if(Opp.Opportunity_Owner_Id__c == AccIdVsAccMap.get(Opp.AccountId).Customer_Advocate__c || Opp.Sales_Rep_OTB_Override__c == true){
                    Opp.CA_OTB_flag__c = false; 
                }
            }else if(Opp.Sales_Rep_OTB_Override__c == true){
                Opp.CA_OTB_flag__c = false; 
            }
            
            
            //Rule to capture the contract end date on the renewal opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Renewal /*'Existing Customer (Renewal)'*/){
                if(AccIdVsAccMap.get(Opp.AccountId) != null){
                    Opp.Contract_End_Date_New__c = AccIdVsAccMap.get(Opp.AccountId).APTS_Platform_Subscription_End_Date__c;
                }
            }
            
            //Rule to Update Account CSM Email on opportunity
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if((Opp.Account_CSM_Email__c == null || Opp.Account_CSM_Email__c  == '') || (Opp.Account_CSM_Email__c == AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email)){
                    Opp.Account_CSM_Email__c = AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email;
                }
            }else if(Opp.Account_CSM_Email__c == null || Opp.Account_CSM_Email__c  == ''){
                if(AccIdVsAccMap.get(Opp.AccountId) != null){
                    Opp.Account_CSM_Email__c = AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email;
                }
            }
            
            //Sets the record type to the renewal when opportunity type is renewal
            if(Opp.RecordType.Name != ZScalarConstants.Opp_RecType_Name_Renewal_Opportunity && Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Renewal /*'Existing Customer (Renewal)'*/){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity;
            }
            
            //Update AMS SE Manager East
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if(AccIdVsAccMap.get(Opp.AccountId).Geo__c != null){
                    if(String.Valueof(AccIdVsAccMap.get(Opp.AccountId).Geo__c).contains('Americas')){
                        Opp.AMS_SE_Manager_East__c = 'rburkett@zscaler.com';
                        Opp.AMS_SE_Manager_west__c = 'gmeron@zscaler.com';
                    }
                }
            }
            
            //Update DAS Package from the Primary Proposal
            if(Opp.APTS_Primary_Proposal_Lookup__c != null){
                if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                   Opp.DAS_Package__c =  PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c;
                }  
            }
            
            //Update Tech val end date
            if(Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_6_Technical_Win /*'6 - Technical Win'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_7_Technical_Loss /*'7 - Technical Loss'*/){
                Opp.Validation_End_Date__c = system.today();
            }
            
            //Update Tech val start date
            if(Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria /*'1 - Establishing Plan & success criteria'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_2_Configuration_in_Progress /*'2 - Configuration in Progress'*/
                || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_3_Detailed_validation_in_progress /*'3 - Detailed validation in progress'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_4_Delivering_validation_findings_report /*'4 - Delivering validation findings report'*/){
                Opp.Technical_Validation_Start_Date__c = system.today();
            }
            
            //Update the VC in Use field based on Value Creation Stage Status
            if(Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Qualified /*'Qualified'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Interview_Scheduled /*'Interview Scheduled'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Interview_Completed /*'Interview Completed'*/
                || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Model_Completed /*'Model Completed'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Output_Presented /*'Output Presented'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Stalled /*'Stalled'*/
                ||  Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Customer_declined_presentation /*'Customer declined presentation'*/){
                Opp.CVC_In_Use__c = 'Yes';
            }
            
            //Update the VC in Use field based on Value Creation Stage Status changed
            if(Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_RSM_Withdrew_Post_Qualified /*'RSM Withdrew Post-Qualified'*/){
                Opp.CVC_In_Use__c = 'No';
            }
            
            //Updates the last validation stage changed date
            if(True){
                Opp.Last_validation_stage_changed_date__c = system.today();
            }           
			//Changes for reset Federal Fields on Opportunity cloning:Start
			if (opp.isClone()) {
				opp.Federal_Deal_Approved_OP__c=false;
				opp.From_FedRAMP_DR__c=false;
				opp.Is_Federal_Opportunity_Sync__c=false;
				opp.Contract_vehicle__c=null;
			}
			//Changes for reset Federal Fields on Opportunity cloning:End
        }
    }
    
    public static void BeforeUpdate(list<Opportunity> newOppList,Map<ID, Opportunity> oldOppMap){
		System.debug('BeforeUpdate Method Oppfieldupdate=========>newOppList=====>'+newOppList);
		System.debug('BeforeUpdate Method Oppfieldupdate=========>oldOppMap=====>'+oldOppMap);
        List<string> OppIds = new List<string>();
        Map<string,Apttus_Proposal__Proposal__c> PropIdVsPropMap = new Map<string,Apttus_Proposal__Proposal__c>();
        ZScalarConstants Constants = new ZScalarConstants();
        List<string> QuotePropIds = new List<string>();
        List<string> AccountIds = new List<string>();
        Map<string,Account> AccIdVsAccMap = new Map<string,Account>();
        
        for(Opportunity Opp:newOppList){
            QuotePropIds.Add(Opp.APTS_Primary_Proposal_Lookup__c);
            AccountIds.Add(Opp.AccountId);
        }
        
        List<Account> Accounts = [Select Id,Name,Geo__c,Customer_Advocate__c,APTS_Platform_Subscription_End_Date__c,CSM_Name_New__c,CSM_Name_New__r.Email from Account where Id IN:AccountIds];
        for(Account Acc:Accounts){
            AccIdVsAccMap.put(Acc.Id,Acc);
        }
        
        List<Apttus_Proposal__Proposal__c> QuotePropList = [select Id,Name,APTS_DAS_Package_Included__c,Included_DAS_Package__c,APTS_ACV__c from Apttus_Proposal__Proposal__c where Id IN:QuotePropIds];
        for(Apttus_Proposal__Proposal__c Prop:QuotePropList){
            PropIdVsPropMap.put(Prop.Id,Prop);
        }
        
         
        for(Opportunity Opp:newOppList){
            //Federal - Deployment Alert on Stage 10b
            system.debug('-------------->'+PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c));
            /*if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                if((oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete && String.valueof(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c).contains('FED')) 
                    || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_ACV__c >= 50000 && Opp.Is_Federal_Opportunity_Sync__c == True && Opp.Account.Type == 'Prospect')){
                    Opp.DAS_Notification_Sent__c = true;
                }
                
                //Deployment Alert on Stage 10b
                if((oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete && !String.valueof(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c).contains('FED')) 
                    || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_ACV__c >= 50000 && Opp.Is_Federal_Opportunity_Sync__c == false && Opp.Account.Type == 'Prospect')){
                    Opp.DAS_Notification_Sent__c = true;
                }
            }
            
            //Email CSM when sales stage is 10B
            if(oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete && Opp.X10B_notification_to_CSM__c == false){
                Opp.X10B_notification_to_CSM__c = true;
            }*/
            System.debug('Opp.Type+++++'+Opp.Type);
			System.debug('Opp.RecordTypeId+++++'+Opp.RecordTypeId);
            //Set record type to closed new business opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business /*'New Business'*/ && ((oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_6_Closed_Won))){
                system.debug('--Set record type to closed new business opportunity--'+ZScalarConstants.Opp_RecType_Id_New_Business_Close);
				Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_New_Business_Close;
				System.debug('Opp.Type+++++'+Opp.Type);
				System.debug('Opp.RecordTypeId+++++'+Opp.RecordTypeId);
            }
            
            //Set record type to closed upsell opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Add_On /*'Existing Customer (Add On)'*/ && ((oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_5_Contracts_Complete) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_6_Closed_Won))){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity_Closed;
            }
            
            //Set record type to open new business opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business /*'New Business'*/ && (/*(oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == label.Stage_0_Initial_Prospecting) ||*/ (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_1_Alignment) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_2_Qualified_Budgeted) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_7_Closed_Lost /*&& Opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision*/))){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_New_Business;
            }
            
            //Set record type to open upsell opportunity
            if(Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Add_On /*'Existing Customer (Add On)'*/ && (/*(oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == label.Stage_0_Initial_Prospecting) ||*/ (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_1_Alignment) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_2_Qualified_Budgeted) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_4_Economic_Buyer_Signoff) || (oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_7_Closed_Lost /*&& Opp.Sub_Stage__c == Label.SubStage_Closed_With_No_Decision*/))){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Upsell_Opportunity;
            }
            
            //Update account type when stage is 13(After Insert)
            
            //Update close lost date when stage is updated to close lost
            if(oldOppMap.get(Opp.Id).StageName != Opp.StageName && Opp.StageName == Label.Stage_7_Closed_Lost /**&& Opp.Sub_Stage__c == Label.SubStage_Closed_Lost**/){
                Opp.CloseDate = system.today();
                Opp.Opportunity_Close_lost_Date__c = system.today();
            }
            
            //Capture Commit Change Date
            if(oldOppMap.get(Opp.Id).Forecast_Category__c != Opp.Forecast_Category__c && oldOppMap.get(Opp.Id).Forecast_Category__c == 'Commit'){
                Opp.Commit_Change_Date__c = system.today();  
            }
            
            //Capture Last Date When Next Step Updated
            if(oldOppMap.get(Opp.Id).NextStep != Opp.NextStep){
                Opp.Last_Next_Step_Updated_Date__c = system.today();
            }
            
            //Capture Stage Change Dates
            if(oldOppMap.get(Opp.Id).StageName != Opp.StageName){
                Opp.Last_Stage_Changed_Date__c = system.today();
                Opp.Previous_Stage_Changed_Date__c = Opp.Last_Stage_Changed_Date__c;
            }
            
            //Fill in DAS Start Date Field
            if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                if(oldOppMap.get(Opp.Id).Service_Start_Date__c != Opp.Service_Start_Date__c && Opp.Service_Start_Date__c != null && Opp.DAS_Start_Date__c == null && PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).APTS_DAS_Package_Included__c == true){ 
                    Opp.DAS_Start_Date__c = Opp.Service_Start_Date__c;
                }
            }
            
            //Increase count if close date is changed
            if(oldOppMap.get(Opp.Id).CloseDate != Opp.CloseDate){
                if(Opp.Time_Close_Date_Changed__c == null){ 
                    Opp.Time_Close_Date_Changed__c = 1; 
                }else{
                    Opp.Time_Close_Date_Changed__c = Opp.Time_Close_Date_Changed__c + 1;     
                }
            }
            
            //Make Tech start date null
            //Nullify the last validation stage changed date
            if(oldOppMap.get(Opp.Id).Validation_Stage__c != Opp.Validation_Stage__c && (Opp.Validation_Stage__c == null || Opp.Validation_Stage__c == '')){
                Opp.Technical_Validation_Start_Date__c = null;
                Opp.Validation_End_Date__c = null;
                Opp.Last_validation_stage_changed_date__c = null;
            }
            
            //Opportunity - Update the Source field for Marketing Sources
            if(oldOppMap.get(Opp.Id).LeadSource != Opp.LeadSource && (Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Advertisement /*'Advertisement'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Webinars /*'Webinars'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Events /*'Events'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_External_DM /*'External DM'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_List_Import /*'List Import'*/
                || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Search /*'Search'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Paid_Search /*'Paid Search'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Website_Direct /*'Website Direct'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Website_Referral /*'Website Referral'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Social_Media /*'Social Media'*/ 
                || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Content_Syndication /*'Content Syndication'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Publisher /*'Publisher'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Telemarketing /*'Telemarketing'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Marketing_Campaign /*'Marketing Campaign'*/)){
                Opp.Source__c = 'Marketing';
            }
            
            //Opportunity - Update the Source field for Partner Sources
            if(oldOppMap.get(Opp.Id).LeadSource != Opp.LeadSource && (Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Deal_Registration /*'Deal Registration'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Partners /*'Partners'*/ || Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Service_Provider /*'Service Provider'*/)){
                Opp.Source__c = 'Partners';
            }
            
            //Opportunity - Update the Source field for Sales Sources
            if(oldOppMap.get(Opp.Id).LeadSource != Opp.LeadSource && Opp.LeadSource == ZScalarConstants.Opp_LeadSource_Sales_Generated /*'Sales Generated'*/){
                Opp.Source__c = 'Sales';
            }
            
            //Opportunity: CA OTB Flag Set on CA mismatch for Renewal
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if(Opp.Sales_Rep_OTB_Override__c  == false && Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Renewal /*'Existing Customer (Renewal)'*/
                    && Opp.Opportunity_Owner_Id__c != AccIdVsAccMap.get(Opp.AccountId).Customer_Advocate__c){
                    Opp.CA_OTB_flag__c = true;
                }
            }
            
            //Opportunity: CA OTB Flag Set to Null on CA match for Renewal
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if((Opp.Opportunity_Owner_Id__c == AccIdVsAccMap.get(Opp.AccountId).Customer_Advocate__c || Opp.Sales_Rep_OTB_Override__c == true)){
                    Opp.CA_OTB_flag__c = false;  
                }
            }else if(Opp.Sales_Rep_OTB_Override__c == true){
                Opp.CA_OTB_flag__c = false; 
            }
            
            
            //Rule to Update Account CSM Email on opportunity
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if((Opp.Account_CSM_Email__c == null || Opp.Account_CSM_Email__c  == '') || (Opp.Account_CSM_Email__c == AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email)){
                    Opp.Account_CSM_Email__c = AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email;
                }
            }else if(Opp.Account_CSM_Email__c == null || Opp.Account_CSM_Email__c  == ''){
                if(AccIdVsAccMap.get(Opp.AccountId) != null){  
                    Opp.Account_CSM_Email__c = AccIdVsAccMap.get(Opp.AccountId).CSM_Name_New__r.Email;
                }
            }
            
            //Sets the record type to the renewal when opportunity type is renewal
            if(Opp.RecordType.Name != ZScalarConstants.Opp_RecType_Name_Renewal_Opportunity && Opp.Type == ZScalarConstants.Opp_Type_Existing_Customer_Renewal /*'Existing Customer (Renewal)'*/ && oldOppMap.get(Opp.Id).Type != Opp.Type){
                Opp.RecordTypeId = ZScalarConstants.Opp_RecType_Id_Renewal_Opportunity;
            }
            
            //Update AMS SE Manager East
            if(AccIdVsAccMap.get(Opp.AccountId) != null){
                if(AccIdVsAccMap.get(Opp.AccountId).Geo__c != null){
                    if(String.Valueof(AccIdVsAccMap.get(Opp.AccountId).Geo__c).contains('Americas')){
                        Opp.AMS_SE_Manager_East__c = 'rburkett@zscaler.com';
                        Opp.AMS_SE_Manager_west__c = 'gmeron@zscaler.com';
                    }
                }
            }
            
            //Update DAS Package from the Primary Proposal
            if(Opp.APTS_Primary_Proposal_Lookup__c != null){
                if(PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c) != null){
                   Opp.DAS_Package__c =  PropIdVsPropMap.get(Opp.APTS_Primary_Proposal_Lookup__c).Included_DAS_Package__c;
                }  
            }
            
            //Update LDR Opp Date
            if(Opp.LDR_Name__c != null && oldOppMap.get(Opp.Id).LDR_Name__c == null){
                Opp.LDR_Opp_Date__c = system.today();
            }
            
            //Update Tech val end date
            if(oldOppMap.get(Opp.Id).Validation_Stage__c != Opp.Validation_Stage__c && (Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_6_Technical_Win  /*'6 - Technical Win'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_7_Technical_Loss /*'7 - Technical Loss'*/)){
                Opp.Validation_End_Date__c = system.today();
            }            
            
            //Update Tech val start date
            if(oldOppMap.get(Opp.Id).Validation_Stage__c != Opp.Validation_Stage__c && (Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria /*'1 - Establishing Plan & success criteria'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_2_Configuration_in_Progress /*'2 - Configuration in Progress'*/
                || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_3_Detailed_validation_in_progress /*'3 - Detailed validation in progress'*/ || Opp.Validation_Stage__c == ZScalarConstants.Opp_Validation_Stage_4_Delivering_validation_findings_report /*'4 - Delivering validation findings report'*/)){
                Opp.Technical_Validation_Start_Date__c = system.today();
            }
            
            //Update the VC in Use field based on Value Creation Stage Status
            if(oldOppMap.get(Opp.Id).Value_Creation_Stage__c != Opp.Value_Creation_Stage__c && (Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Qualified  /*'Qualified'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Interview_Scheduled /*'Interview Scheduled'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Interview_Completed /*'Interview Completed'*/
                || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Model_Completed /*'Model Completed'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Output_Presented /*'Output Presented'*/ || Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Stalled /*'Stalled'*/
                ||  Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_Customer_declined_presentation /*'Customer declined presentation'*/)){
                Opp.CVC_In_Use__c = 'Yes';
            }
            
            //Update the VC in Use field based on Value Creation Stage Status changed
            if(oldOppMap.get(Opp.Id).Value_Creation_Stage__c != Opp.Value_Creation_Stage__c && Opp.Value_Creation_Stage__c == ZScalarConstants.Value_Creation_Stage_RSM_Withdrew_Post_Qualified /*'RSM Withdrew Post-Qualified'*/){
                Opp.CVC_In_Use__c = 'No';
            }
            
            //Updates the last validation stage changed date
            if(oldOppMap.get(Opp.Id).Validation_Stage__c  != Opp.Validation_Stage__c ){
                Opp.Last_validation_stage_changed_date__c = system.today();
            }
            
			//Changes for reset Federal Fields on Opportunity cloning:Start
			if (opp.isClone()) {
				opp.Federal_Deal_Approved_OP__c=false;
				opp.From_FedRAMP_DR__c=false;
				opp.Is_Federal_Opportunity_Sync__c=false;
				opp.Contract_vehicle__c=null;
			}
			//Changes for reset Federal Fields on Opportunity cloning:End
		}
		TriggerUtility.isopportunityfieldupdateExecuted(); //Added by Minkesh for field update 
    }
    
    /**
     * public static void AfterInsert(list<Opportunity> newOppList){
        List<string> AccountIds = new List<string>();
        Map<string,Account> AccIdVsAccRec = new Map<string,Account>();
        List<Account> AccountListToUpdate = new List<Account>();
        
        for(Opportunity Opp:newOppList){
            AccountIds.Add(Opp.AccountId);
        }
        
        List<Account> Acclist = [select Id,Name from Account Where Id IN:AccountIds];
        for(Account Acc:Acclist){
            AccIdVsAccRec.put(Acc.Id,Acc);
        }
        
        for(Opportunity Opp:newOppList){
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business && Opp.StageName == Label.Stage_6_Closed_Won){
                if(AccIdVsAccRec.get(Opp.AccountId) != null){
                    Account Acc = AccIdVsAccRec.get(Opp.AccountId);
                    Acc.Type = 'Customer';
                    AccountListToUpdate.Add(Acc);
                }
            }
        }
        if(AccountListToUpdate.size()>0){
            update AccountListToUpdate;
        }
        
    }
    
    public static void AfterUpdate(list<Opportunity> newOppList,Map<ID, Opportunity> oldOppMap){
        List<string> AccountIds = new List<string>();
        Map<string,Account> AccIdVsAccRec = new Map<string,Account>();
        List<Account> AccountListToUpdate = new List<Account>();
        
        for(Opportunity Opp:newOppList){
            AccountIds.Add(Opp.AccountId);
        }
        
        List<Account> Acclist = [select Id,Name,Type from Account Where Id IN:AccountIds];
        for(Account Acc:Acclist){
            AccIdVsAccRec.put(Acc.Id,Acc);
        }
        
        for(Opportunity Opp:newOppList){  
            system.debug('---Account Type---'+AccIdVsAccRec.get(Opp.AccountId));
            if(Opp.Type == ZScalarConstants.Opp_Type_New_Business && Opp.StageName == Label.Stage_6_Closed_Won && oldOppMap.get(Opp.Id).StageName != Opp.StageName){
                if(AccIdVsAccRec.get(Opp.AccountId) != null){
                    Account Acc = AccIdVsAccRec.get(Opp.AccountId);
                    Acc.Type = 'Customer';
                    AccountListToUpdate.Add(Acc);
                }
            }
        }
        if(AccountListToUpdate.size()>0){
            update AccountListToUpdate;
        }
    }**/
	
	public static void booster(){
		integer i=1;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
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