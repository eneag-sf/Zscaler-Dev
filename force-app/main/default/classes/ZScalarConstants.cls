public class ZScalarConstants {
    
    public static string Opp_RecType_Name_New_Business_Close = 'New Business Close';
    public static string Opp_RecType_Name_Upsell_Opportunity_Closed = 'Upsell Opportunity Closed';
    public static string Opp_RecType_Name_New_Business = 'New Business';
    public static string Opp_RecType_Name_Upsell_Opportunity = 'Upsell Opportunity';
    public static string Opp_RecType_Name_Renewal_Opportunity = 'Renewal Opportunity';
       
    public static string Opp_RecType_Id_New_Business_Close = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_New_Business_Close).getRecordTypeId();
    public static string Opp_RecType_Id_Upsell_Opportunity_Closed = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Upsell_Opportunity_Closed).getRecordTypeId();
    public static string Opp_RecType_Id_New_Business = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_New_Business).getRecordTypeId();
    public static string Opp_RecType_Id_Upsell_Opportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Upsell_Opportunity).getRecordTypeId();
    public static string Opp_RecType_Id_Renewal_Opportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Opp_RecType_Name_Renewal_Opportunity).getRecordTypeId();
    
    public static string Opp_Type_New_Business = 'New Business';
    public static string Opp_Type_Existing_Customer_Add_On = 'Existing Customer (Add On)';
    public static string Opp_Type_Existing_Customer_Renewal = 'Existing Customer (Renewal)';
    
    public static string Opp_LeadSource_Advertisement = 'Advertisement';
    public static string Opp_LeadSource_Webinars = 'Webinars';
    public static string Opp_LeadSource_Events = 'Events';
    public static string Opp_LeadSource_External_DM = 'External DM';
    public static string Opp_LeadSource_List_Import = 'List Import';
    public static string Opp_LeadSource_Search = 'Search';
    public static string Opp_LeadSource_Paid_Search = 'Paid Search';
    public static string Opp_LeadSource_Website_Direct = 'Website Direct';
    public static string Opp_LeadSource_Website_Referral = 'Website Referral';
    public static string Opp_LeadSource_Social_Media = 'Social Media';
    public static string Opp_LeadSource_Content_Syndication = 'Content Syndication';
    public static string Opp_LeadSource_Publisher = 'Publisher';
    public static string Opp_LeadSource_Telemarketing = 'Telemarketing';
    public static string Opp_LeadSource_Marketing_Campaign = 'Marketing Campaign';
    public static string Opp_LeadSource_Deal_Registration = 'Deal Registration';
    public static string Opp_LeadSource_Partners = 'Partners';
    public static string Opp_LeadSource_Service_Provider = 'Service Provider';
    public static string Opp_LeadSource_Sales_Generated = 'Sales Generated';
    
    public static string Opp_Validation_Stage_6_Technical_Win = '6 - Technical Win';
    public static string Opp_Validation_Stage_7_Technical_Loss = '7 - Technical Loss';
    public static string Opp_Validation_Stage_1_Establishing_Plan_sucess_criteria = '1 - Establishing Plan & success criteria';
    public static string Opp_Validation_Stage_2_Configuration_in_Progress = '2 - Configuration in Progress';
    public static string Opp_Validation_Stage_3_Detailed_validation_in_progress = '3 - Detailed validation in progress';
    public static string Opp_Validation_Stage_4_Delivering_validation_findings_report = '4 - Delivering validation findings report';
    
    public static string Value_Creation_Stage_Qualified = 'Qualified';
    public static string Value_Creation_Stage_Interview_Scheduled = 'Interview Scheduled';
    public static string Value_Creation_Stage_Interview_Completed = 'Interview Completed';
    public static string Value_Creation_Stage_Model_Completed = 'Model Completed';
    public static string Value_Creation_Stage_Output_Presented = 'Output Presented';
    public static string Value_Creation_Stage_Stalled = 'Stalled';
    public static string Value_Creation_Stage_Customer_declined_presentation = 'Customer declined presentation';
    public static string Value_Creation_Stage_RSM_Withdrew_Post_Qualified = 'RSM Withdrew Post-Qualified';
    
    
    /*public ZScalarConstants(){
        Opp_RecType_Id_New_Business_Close = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_New_Business_Close].Id;
        Opp_RecType_Id_Upsell_Opportunity_Closed = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Upsell_Opportunity_Closed].Id;
        Opp_RecType_Id_New_Business = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_New_Business].Id;
        Opp_RecType_Id_Upsell_Opportunity = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Upsell_Opportunity].Id;
        Opp_RecType_Id_Renewal_Opportunity = [Select Id,Name From RecordType where sobjecttype = 'Opportunity' And Name = :Opp_RecType_Name_Renewal_Opportunity].Id;
    }*/
    
}