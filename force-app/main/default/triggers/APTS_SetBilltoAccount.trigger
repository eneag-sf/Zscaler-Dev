trigger APTS_SetBilltoAccount on Apttus_Config2__ProductConfiguration__c (before insert,before update,after insert) {
    if(APTS_SetBilltoAccountHelper.beforeflag){
        APTS_SetBilltoAccountHelper.before(Trigger.New);
    }
    //added after insert event as a part of RBAC
    if(trigger.isInsert && trigger.isAfter){
        APTS_SetBilltoAccountHelper.afterInsert(Trigger.new);
    }
    /*List<Apttus_Config2__ProductConfiguration__c> configlist = Trigger.New;
    Map<id, List<Apttus_Config2__ProductConfiguration__c>> configMap = new  Map<id, List<Apttus_Config2__ProductConfiguration__c>> ();
    List<Apttus_Config2__ProductConfiguration__c> configlistNew;
    for(Apttus_Config2__ProductConfiguration__c  config : configlist) {
        
            configlistNew = new List<Apttus_Config2__ProductConfiguration__c> ();
            if(configMap.get(config.Apttus_QPConfig__Proposald__c) != null) {
                configlistNew = configMap.get(config.Apttus_QPConfig__Proposald__c);
            }
            configlistNew.add(config);
            configMap.put(config.Apttus_QPConfig__Proposald__c,configlistNew);
        
    }
   if(configMap.size () > 0) {
       List<Apttus_Proposal__Proposal__c> proposalList = [select id,Apttus_QPConfig__BillToAccountId__c from 
                                                               Apttus_Proposal__Proposal__c where id IN:configMap.keyset()];
       for(Apttus_Proposal__Proposal__c prop :proposalList) {
           for(Apttus_Config2__ProductConfiguration__c  config : configMap.get(prop.id)) {
               config.Apttus_Config2__BillToAccountId__c = prop.Apttus_QPConfig__BillToAccountId__c;
           }
       }                                                        
   }*/
}