global class DealRegPushToFedRAMP{
    webservice static Boolean saveDealReg(Id dealRegId){
        Deal_Reg__c dr = new Deal_Reg__c(Id=dealRegId, Federal_Change__c = system.now(), Send_to_FedRAMP__c = 'Requested');
        try{
            update dr;
            return true;
        }catch(Exception ex){
            return false;
        }
    }
}