public class APTS_FinalizeandReturn{
    
     public static Id cfgId = ApexPages.currentPage().getParameters().get('Id');
    
     public static PageReference returntoquote(){
       
        List<Apttus_Config2__ProductConfiguration__c> prodconfig =[SELECT Id,Apttus_QPConfig__Proposald__c
                                                                    from Apttus_Config2__ProductConfiguration__c 
                                                                    where Id=:cfgId ];
        
        Apttus_CpqApi.CPQ.FinalizeCartRequestDO request = new Apttus_CpqApi.CPQ.FinalizeCartRequestDO();
        request.CartId = cfgId;
        Apttus_CpqApi.CPQ.FinalizeCartResponseDO response = Apttus_CpqApi.CPQWebService.finalizeCart(request);



        PageReference pageRef = new PageReference('/'+prodconfig[0].Apttus_QPConfig__Proposald__c);
        
        return pageRef;
        
    }
}