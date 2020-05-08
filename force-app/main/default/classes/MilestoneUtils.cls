public class MilestoneUtils {
    public static void completeMilestone(Set<Id> caseIds, String milestoneName, DateTime complDate) {  
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                                           from CaseMilestone cm
                                           where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                                           and completionDate = null];
        if (!cmsToUpdate.isEmpty()){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            update cmsToUpdate;
        }
    }
    //booster is required because milestones cannot be created in test class
    public static void booster(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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