/**
* Core trigger handler for Inspire Project object
* 
* @Date: 16.12.2019
* @Author: Pankaj
* 
* 
*/

public with sharing class ProjectTriggerHandler {

    @testVisible
	//Prevent duplicate execution
    private static Boolean bypassHandler = false;
   //declare class variables

    public List<Professional_Service_Project__c> Projects_toinsert = new List<Professional_Service_Project__c>();
    public Map<String,String> mapRelatedProjectIDInspireProjectID = new Map<String,String>();
	public List<Professional_Service_Project__c> Projects_toUpdate = new List<Professional_Service_Project__c>();
   

    public void afterUpdate(Map<Id, Inspire1__Project__c> newMap, Map<Id, Inspire1__Project__c> oldMap){
       if(bypassHandler) { return; }
       handleCloningofProjects(newMap, oldMap);
        
    }
    
    public void afterInsert(Map<Id, Inspire1__Project__c> newMap){
        if(bypassHandler) { return; }
        handleCloningofProjects(newMap);
    }
	
	 /**
    
     *
     * @param Map<Id, Inspire1__Project__c> newMap : Map of all Inspire Projects - Trigger.newMap
     *
     * @return void : No return value
     *
     * @Author: Pankaj
     * @Date: 16.12.2019
     */

    private void handleCloningofProjects(Map<Id, Inspire1__Project__c> newMap){    
                      
       for(Inspire1__Project__c Ip:[SELECT ID,ZIA_ACV__c,ZPA_ACV__c,inspire1__Complete__c,inspire1__Percent_Slippage__c,inspire1__Account__c,inspire1__Actual_Cost__c,inspire1__Actual_Duration__c,inspire1__Baseline_Duration__c,inspire1__Budget__c,inspire1__Budgeted_Cost__c,inspire1__Cost_Performance_Index_CPI__c,inspire1__Budget_Variance__c,inspire1__Budget_Variance_Percent__c,CSM__c,Customer_Collaboration_Notes__c,inspire1__Days_Overdue_Project__c,inspire1__Default_User_Project_Settings__c,Primary_Deployment_Consultant__c,Secondary_Deployment_Consultant__c,Deployment_Package_Cost__c,inspire1__Description__c,inspire1__Project_Duration__c,inspire1__Duration_Complete_Day_Unit_Tasks__c,inspire1__Duration_Complete_Hour_Unit_Tasks__c,inspire1__Earned_Value__c,inspire1__Editor__c,inspire1__Effort_Variance__c,inspire1__Effort_Variance_Percent__c,inspire1__End_Work_Day__c,inspire1__External_ID__c,inspire1__FeedItemsViewHistory__c,inspire1__Finish_Variance__c,inspire1__Issues__c,Logged_in_User__c,Management_Notes__c,Opportunity__c,Opportunity_Owner__c,inspire1__Overall_Project_Health__c,inspire1__Owner_Name__c,inspire1__Parent_Project__c,inspire1__Planned_Value__c,Project_Link__c,Project_Manager__c,inspire1__Project_Status__c,inspire1__Project_Template__c,Project_Type__c,Region__c,inspire1__Remaining_Budget__c,Requester_Time_Zone__c,inspire1__Resources__c,inspire1__Risks__c,inspire1__Schedule__c,inspire1__Scope__c,inspire1__Slippage__c,inspire1__Start_Variance__c,inspire1__Start_Work_Day__c,inspire1__sysBaselineFinishRollup__c,inspire1__sysBaselineStartRollup__c,TAM__c,inspire1__Tasks_Completed_Rollup__c,inspire1__Tasks_Deferred_Rollup__c,inspire1__Tasks_In_Progress_Rollup__c,inspire1__Tasks_Not_Started_Rollup__c,inspire1__Tasks_Overdue__c,inspire1__Tasks_Waiting_on_someone_else_Rollup__c,inspire1__Tasks_Without_Status_Rollup__c,inspire1__Total_Actual_Effort__c,inspire1__Total_Days_Overdue__c,inspire1__Total_Duration_Day_Unit_Tasks__c,inspire1__Total_Duration_Hour_Unit_Tasks__c,inspire1__Total_Hours_for_Workday__c,inspire1__Total_Planned_Effort__c,inspire1__Total_Tasks_Rollup__c,ZIA_Cloud_ID__c,ZIA_L31D__c,ZIA_L31D_Status__c,inspire1__Zoom__c,ZPA_Cloud_ID__c,ZPA_L31D__c,ZPA_L31D_Status__c FROM Inspire1__Project__c WHERE ID In:newMap.keySet() order by createddate desc LIMIT 50000 ])
	   {
 
		String json1 = JSON.serialize(Ip);
		System.debug(json1);
        
         json1=json1.replace('"inspire1__','"');
           Professional_Service_Project__c psp = (Professional_Service_Project__c)System.JSON.deserialize(json1,Professional_Service_Project__c.class); 
         
         
	    psp.Account__c=Ip.Inspire1__Account__c;
        psp.Related_Inspire_Project_ID__c=IP.ID;
        psp.Project_Status__c=Ip.inspire1__Project_Status__c;
        psp.id=null;
        Projects_toinsert.add(psp);
		System.debug(psp);
		
    }
    
   if(!Projects_toinsert.isEmpty()) {
            try { 
			insert Projects_toinsert; 
			}
			catch(Exception ex) { 
            List <Inspire1__Project__c> psplist = newmap.Values();
            psplist[0].addError('There was a problem inserting Professional Service Project: ' + ex.getMessage()); }
        }
       
       
     
     
    }
	
	
	 /**
    
     *
     * @param Map<Id, Inspire1__Project__c> newMap : Map of all Inspire Projects new values and old values - Trigger.newMap Trigger.oldMap
     *
     * @return void : No return value
     *
     * @Author: Pankaj
     * @Date: 16.12.2019
     */

    private void handleCloningofProjects(Map<Id, Inspire1__Project__c> newMap,Map<Id, Inspire1__Project__c> oldMap){   

		for(Professional_Service_Project__c p :[SELECT ID,Related_Inspire_Project_ID__c from Professional_Service_Project__c WHERE Related_Inspire_Project_ID__c IN: newMap.keySet() LIMIT 500000 ])
		{  
		    if(p.Related_Inspire_Project_ID__c!=null)
			mapRelatedProjectIDInspireProjectID.put(p.Related_Inspire_Project_ID__c,p.ID);
		}
       if(!mapRelatedProjectIDInspireProjectID.keySet().isEmpty())   
       {
       for(Inspire1__Project__c Ip:[SELECT ID,ZIA_ACV__c,ZPA_ACV__c,inspire1__Complete__c,inspire1__Percent_Slippage__c,inspire1__Account__c,inspire1__Actual_Cost__c,inspire1__Actual_Duration__c,inspire1__Baseline_Duration__c,inspire1__Budget__c,inspire1__Budgeted_Cost__c,inspire1__Cost_Performance_Index_CPI__c,inspire1__Budget_Variance__c,inspire1__Budget_Variance_Percent__c,CSM__c,Customer_Collaboration_Notes__c,inspire1__Days_Overdue_Project__c,inspire1__Default_User_Project_Settings__c,Primary_Deployment_Consultant__c,Secondary_Deployment_Consultant__c,Deployment_Package_Cost__c,inspire1__Description__c,inspire1__Project_Duration__c,inspire1__Duration_Complete_Day_Unit_Tasks__c,inspire1__Duration_Complete_Hour_Unit_Tasks__c,inspire1__Earned_Value__c,inspire1__Editor__c,inspire1__Effort_Variance__c,inspire1__Effort_Variance_Percent__c,inspire1__End_Work_Day__c,inspire1__External_ID__c,inspire1__FeedItemsViewHistory__c,inspire1__Finish_Variance__c,inspire1__Issues__c,Logged_in_User__c,Management_Notes__c,Opportunity__c,Opportunity_Owner__c,inspire1__Overall_Project_Health__c,inspire1__Owner_Name__c,inspire1__Parent_Project__c,inspire1__Planned_Value__c,Project_Link__c,Project_Manager__c,inspire1__Project_Status__c,inspire1__Project_Template__c,Project_Type__c,Region__c,inspire1__Remaining_Budget__c,Requester_Time_Zone__c,inspire1__Resources__c,inspire1__Risks__c,inspire1__Schedule__c,inspire1__Scope__c,inspire1__Slippage__c,inspire1__Start_Variance__c,inspire1__Start_Work_Day__c,inspire1__sysBaselineFinishRollup__c,inspire1__sysBaselineStartRollup__c,TAM__c,inspire1__Tasks_Completed_Rollup__c,inspire1__Tasks_Deferred_Rollup__c,inspire1__Tasks_In_Progress_Rollup__c,inspire1__Tasks_Not_Started_Rollup__c,inspire1__Tasks_Overdue__c,inspire1__Tasks_Waiting_on_someone_else_Rollup__c,inspire1__Tasks_Without_Status_Rollup__c,inspire1__Total_Actual_Effort__c,inspire1__Total_Days_Overdue__c,inspire1__Total_Duration_Day_Unit_Tasks__c,inspire1__Total_Duration_Hour_Unit_Tasks__c,inspire1__Total_Hours_for_Workday__c,inspire1__Total_Planned_Effort__c,inspire1__Total_Tasks_Rollup__c,ZIA_Cloud_ID__c,ZIA_L31D__c,ZIA_L31D_Status__c,inspire1__Zoom__c,ZPA_Cloud_ID__c,ZPA_L31D__c,ZPA_L31D_Status__c FROM Inspire1__Project__c WHERE ID In:newMap.keySet() order by createddate desc LIMIT 50000 ])
	   {
        
		String json1 = JSON.serialize(Ip);
            json1=json1.replace('"inspire1__','"');
              json1=json1.replace('"inspire1__','"');
		System.debug(json1);


		//json1=json1.replace('Inspire1__Project__c','Professional_Service_Project__c ');
      Professional_Service_Project__c psp = (Professional_Service_Project__c)System.JSON.deserialize(json1,Professional_Service_Project__c.class); 
           
		psp.id=mapRelatedProjectIDInspireProjectID.get(Ip.ID);
         
           Projects_toUpdate.add(psp);
         
		System.debug(psp);
		
    }
    }
    
   if(!Projects_toUpdate.isEmpty()) {
            try { 
			update Projects_toUpdate; 
			}
			catch(Exception ex) { 
            List <Inspire1__Project__c> psplist = newmap.Values();
            psplist[0].addError('There was a problem updating Professional Service Project: ' + ex.getMessage()); }
        }
        
        // bypassHandler=true;
	}
    
    
     
     
}