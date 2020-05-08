public  class EmailComponentController {
     
   	public Id accountId {get;set;}
    public Boolean lingeringC {get;set;}
    public List<Case> getcases(){
        
        List<Case> caselst;
        DateTime rightNow = System.now();
        rightNow = rightNow.addDays(-14);
        if(lingeringC)  {
            caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE Accountid =: accountId and (not Status like 'Closed%') and createdDate <= :rightNow ];
        }else {
        	caselst = [SELECT CreatedDate,Subject,Type__c,Account.Name,Owner.Name,CaseNumber,Case_Type__c FROM Case WHERE Accountid =: accountId and (not Status like 'Closed%') and createdDate >= :rightNow ];
		}
        return caselst;
        
    }
}