public class APTSCU_MakeProposalPrimary {
    public string proposalId{get;set;}
    
    public string opportunityId{get;set;}
    public Apttus_Proposal__Proposal__c prop;
    
    public APTSCU_MakeProposalPrimary() {
        proposalId = apexpages.currentpage().getparameters().get('id');
        prop = new Apttus_Proposal__Proposal__c();
        //prop = [select id,Apttus_Proposal__Opportunity__c,Apttus_Proposal__Primary__c,Apttus_Proposal__Opportunity__r.AccountId,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c  where id=:proposalId];
        prop = [select id, Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c, 
                            Apttus_Proposal__Opportunity__r.AccountId,Apttus_Proposal__Account__c,
                            Apttus_QPConfig__BillToAccountId__c,
                            Apttus_QPConfig__BillToAccountId__r.Name ,
                            Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c,
                            //Apttus_QPConfig__PartnerAccountId__c,
                            Distributor__c,
                            Distributor__r.Model_Type_Partner__c 
                            from 
                            Apttus_Proposal__Proposal__c  
                            where id =: proposalId];
        opportunityId = prop.Apttus_Proposal__Opportunity__c;
    }
    
     /**
        Updated BY : Sateesh U 
        This method is used To Make the reseller and distributor partners as primary with bill to and reseller on Quote.
     **/
     public PageReference init () {
        system.debug('-----Method Calling----'); 
        
        List<Opportunity_Partner__c> OppResellerPartners = new List<Opportunity_Partner__c>();
        List<Opportunity_Partner__c> OtherActiveResellerPartners = new List<Opportunity_Partner__c>();
        List<Opportunity_Partner__c> OppDistributorPartners = new List<Opportunity_Partner__c>();
        List<Opportunity_Partner__c> OtherActiveDistributorPartners = new List<Opportunity_Partner__c>();
        if(prop.Apttus_QPConfig__BillToAccountId__c != null && prop.Apttus_Proposal__Opportunity__c != null){
            
             OppResellerPartners = [Select   Id, 
                                                                            Partner_Type__c,
                                                                            Is_Primary__c,
                                                                            Opportunity__c,
                                                                            Account__c
                                                                            from 
                                                                            Opportunity_Partner__c
                                                                            Where 
                                                                            Partner_Type__c = 'Reseller'
                                                                            AND
                                                                            Account__c = :prop.Apttus_QPConfig__BillToAccountId__c
                                                                            AND
                                                                            Opportunity__c =:prop.Apttus_Proposal__Opportunity__c
                                                                            ];
                                                                        
             OtherActiveResellerPartners = [Select   Id, 
                                                                            Partner_Type__c,
                                                                            Is_Primary__c,
                                                                            Opportunity__c,
                                                                            Account__c
                                                                            from 
                                                                            Opportunity_Partner__c
                                                                            Where 
                                                                            Partner_Type__c = 'Reseller'
                                                                            AND
                                                                            Opportunity__c =: prop.Apttus_Proposal__Opportunity__c
                                                                            AND
                                                                            Is_Primary__c = true];
            
            
            
        }
        
        if(prop.Distributor__c != null && prop.Apttus_Proposal__Opportunity__c != null){
            
            OppDistributorPartners = [Select   Id, 
                                                                            Partner_Type__c,
                                                                            Is_Primary__c,
                                                                            Opportunity__c,
                                                                            Account__c
                                                                            from 
                                                                            Opportunity_Partner__c
                                                                            Where 
                                                                            Partner_Type__c = 'Distributor'
                                                                            AND
                                                                            Account__c =: prop.Distributor__c
                                                                            AND
                                                                            Opportunity__c =: prop.Apttus_Proposal__Opportunity__c
                                                                            ];
                                                                        
            OtherActiveDistributorPartners = [Select   Id, 
                                                                            Partner_Type__c,
                                                                            Is_Primary__c,
                                                                            Opportunity__c,
                                                                            Account__c
                                                                            from 
                                                                            Opportunity_Partner__c
                                                                            Where 
                                                                            Partner_Type__c = 'Distributor'
                                                                            AND
                                                                            Opportunity__c =: prop.Apttus_Proposal__Opportunity__c
                                                                            AND
                                                                            Is_Primary__c = true];
        }
        
        if(prop.Apttus_QPConfig__BillToAccountId__c == prop.Distributor__c){
            if(OppResellerPartners.size() == 0 && OppDistributorPartners.size() == 0){
                Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
                OppPartner.Opportunity__c = prop.Apttus_Proposal__Opportunity__c;
                OppPartner.Account__c = prop.Apttus_QPConfig__BillToAccountId__c;
                OppPartner.Partner_Program__c = prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == null ? 'Legacy' : prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == 'Both' ? 'Partner Summit' : prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c;
                OppPartner.Is_Primary__c = true;
                OppPartner.Partner_Type__c = 'Reseller';
                insert OppPartner;
                
                if(OtherActiveResellerPartners.size()>0){
                    for(Opportunity_Partner__c Partner : OtherActiveResellerPartners){
                        Partner.Is_Primary__c = false;
                    }
                    update OtherActiveResellerPartners;  
                }
            }
            
            else if(OppResellerPartners.size() > 0){
                for(Opportunity_Partner__c Partner : OppResellerPartners){
                    if(Partner.Is_Primary__c == false ){
                        Partner.Is_Primary__c = true;
                    }
                }
                update OppResellerPartners;
                
                for(Opportunity_Partner__c Partner : OtherActiveResellerPartners){
                    if(Partner.Account__c != prop.Apttus_QPConfig__BillToAccountId__c){
                        Partner.Is_Primary__c = false;
                    }
                }
                update OtherActiveResellerPartners;
            }
            
            if(OppDistributorPartners.size() == 0){
                for(Opportunity_Partner__c Partner:OtherActiveDistributorPartners){
                    if(Partner.Account__c != prop.Distributor__c){
                        Partner.Is_Primary__c = false;
                    }
                }
                update OtherActiveDistributorPartners;
            }
        }
        else if(prop.Apttus_QPConfig__BillToAccountId__c != prop.Distributor__c){
            if(OppResellerPartners.size() <= 0){
               
                Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
                OppPartner.Opportunity__c = prop.Apttus_Proposal__Opportunity__c;
                OppPartner.Partner_Program__c = prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == null ? 'Legacy' : prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c == 'Both' ? 'Partner Summit' : prop.Apttus_QPConfig__BillToAccountId__r.Model_Type_Partner__c;
                OppPartner.Account__c = prop.Apttus_QPConfig__BillToAccountId__c;
                OppPartner.Is_Primary__c = true;
                OppPartner.Partner_Type__c = 'Reseller';
                insert OppPartner;
                
                if(OtherActiveResellerPartners.size()>0){
                    for(Opportunity_Partner__c Partner : OtherActiveResellerPartners){
                        Partner.Is_Primary__c = false;
                    }
                    update OtherActiveResellerPartners;  
                }
            }
            else{
                for(Opportunity_Partner__c Partner : OppResellerPartners){
                    if(Partner.Is_Primary__c == false ){
                        Partner.Is_Primary__c = true;
                    }
                }
                update OppResellerPartners;
                
                for(Opportunity_Partner__c Partner : OtherActiveResellerPartners){
                    if(Partner.Account__c != prop.Apttus_QPConfig__BillToAccountId__c){
                        Partner.Is_Primary__c = false;
                    }
                }
                update OtherActiveResellerPartners;
            }
            
            if(OppDistributorPartners.size()<=0){
                Opportunity_Partner__c OppPartner = new Opportunity_Partner__c();
                OppPartner.Opportunity__c = prop.Apttus_Proposal__Opportunity__c;
                OppPartner.Partner_Program__c = prop.Distributor__r.Model_Type_Partner__c == null ? 'Legacy' : prop.Distributor__r.Model_Type_Partner__c == 'Both' ? 'Partner Summit' : prop.Distributor__r.Model_Type_Partner__c;
                OppPartner.Account__c = prop.Distributor__c;
                OppPartner.Is_Primary__c = true;
                OppPartner.Partner_Type__c = 'Distributor';
                insert OppPartner;
                
                if(OtherActiveDistributorPartners.size()>0){
                    for(Opportunity_Partner__c Partner:OtherActiveDistributorPartners){
                        Partner.Is_Primary__c = false;
                    }
                    update OtherActiveDistributorPartners;  
                }
            }else{
                for(Opportunity_Partner__c Partner:OppDistributorPartners){
                    if(Partner.Is_Primary__c == false){
                        Partner.Is_Primary__c = true;
                    }
                }
                update OppDistributorPartners;
                
                for(Opportunity_Partner__c Partner:OtherActiveDistributorPartners){
                    if(Partner.Account__c != prop.Distributor__c){
                        Partner.Is_Primary__c = false;
                    }
                }
                update OtherActiveDistributorPartners;
            }
        }
        
        List<OpportunityLineItem> oppLitemList = new List<OpportunityLineItem> ();
        oppLitemList = [select id from OpportunityLineItem where opportunityId =:opportunityId];
        if(oppLitemList.size() > 0) {
            delete oppLitemList;
        }
        
       /* Opportunity opp = [Select ID, APTS_Primary_Proposal__c, Start_Date__c, CloseDate, OwnerId From Opportunity Where ID =: opportunityId];
       opp.APTS_Primary_Proposal__c = prop.Id;
       
       update opp;*/
           
        APTSCU_CreateProposalUtility.createOpportunityProduct(proposalId, opportunityId);
        PageReference proposalPage = new PageReference('/apex/Apttus_Proposal__ProposalMakePrimary?id=' + proposalId);
        proposalPage.setRedirect(true);
        return proposalPage;
    }
}