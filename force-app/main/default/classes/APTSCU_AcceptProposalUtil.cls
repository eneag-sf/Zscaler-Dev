public class APTSCU_AcceptProposalUtil {

    public APTSCU_AcceptProposalUtil() {

    }

        
    public static void acceptProposal(String proposalId)
    {
       Boolean response = false;
       response = Apttus_QPConfig.QPConfigWebService.acceptQuote(proposalId);   
    }
    
}