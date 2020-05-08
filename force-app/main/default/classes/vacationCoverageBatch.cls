global class vacationCoverageBatch implements Database.Batchable<sObject> {
    
    public Set<Id> accountIdsForVacationCoverage = new Set<Id>();
    public string selectedVacationManager = '';
    public string coverageActionType = '';
    public Set<Id> vacationCoveringUsers = new Set<Id>();
    
    global vacationCoverageBatch(Set<Id> accountIds, String selectedUser, Set<Id> coveringUsers, string actionType){
        accountIdsForVacationCoverage = accountIds;
        selectedVacationManager = selectedUser;
        coverageActionType = actionType;
        vacationCoveringUsers = coveringUsers;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id from Account where Id IN: accountIdsForVacationCoverage';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, list<Account> scope){
        
        Set<Id> accountIds = new Set<Id>();
        for(Account accRec : scope){
            accountIds.add(accRec.Id);
        }
        if(!accountIds.isEmpty()){
            if(coverageActionType == 'Create Vacation Coverage'){
                AccountAccess_Utility.insertAccountTeam(accountIds, selectedVacationManager);
                AccountAccess_Utility.InsertOpportunityTeam(accountIds, selectedVacationManager);
            }
            else if(coverageActionType == 'Delete Vacation Coverage'){
                AccountAccess_Utility.deleteAccountVacationCoverage(accountIds, vacationCoveringUsers);
                AccountAccess_Utility.deleteOpportunityVacationCoverage(accountIds, vacationCoveringUsers);
            }
        }
        // process each batch of records
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}