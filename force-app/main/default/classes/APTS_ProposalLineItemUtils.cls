/* APTS_ProposalLineItemUtils
 * Bulkied methods which do the processing of Proposal Line Item(Apttus_Proposal__Proposal_Line_Item__c) dml's.
 *
 * Developer: Harish Emmadi, APTTUS - 11/08/2016
 * Business Owner:
 *
 * Scenario:
 *
 *
 *
 * History:
 */
public without sharing class APTS_ProposalLineItemUtils {

    private static final Set<String> BUNDLE_PRODUCTS = new Set<String>{'ZIA Professional Bundle' , 'ZIA Business Bundle', 'ZIA Secure Transformation Bundle', 'ZPA Professional Suite', 'ZPA Business Suite', 'ZPA Enterprise Suite'};

    private APTS_ProposalLineItemUtils() {

    }

    // Supports only before insert/update trigger.
    // Params: pliSOList - Trigger.new
    // Derivation 1. Populate user manager(APTS_User_Manager__c) - quote owner's manager - lookups cant be done using workflows.
    public static void doBeforeDerivations(List<Apttus_Proposal__Proposal_Line_Item__c> pliSOList){
        Set<Id> proposalIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Map<Id, Apttus_Proposal__Proposal__c> pIdtoProposalSOMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        Map<Id, User> uIdtouserSOMap = new Map<Id, User>();
        for(Apttus_Proposal__Proposal_Line_Item__c pliSO : pliSOList){
            if(pliSO.Apttus_Proposal__Proposal__c != null){
                proposalIdSet.add(pliSO.Apttus_Proposal__Proposal__c);
            }
        }
        // get all the proposal SO for the given lines.
        if(!proposalIdSet.isEmpty()){
            for(Apttus_Proposal__Proposal__c pSO : [Select Id,  OwnerId,Total_Net_to_Zscaler__c
                            From Apttus_Proposal__Proposal__c
                                Where Id IN :proposalIdSet]){
                pIdtoProposalSOMap.put(pSO.Id, pSO);
                userIdSet.add(pSO.OwnerId);
            }
            if(!userIdSet.isEmpty()){
                uIdtouserSOMap = new Map<Id, User>([Select Id, ManagerId
                                                         From User
                                                            Where Id IN :userIdSet]);
            }
        }

        // actual derivations in this loop.
        Decimal temptotal = 0 ; //added by minkesh patel
        Apttus_Proposal__Proposal__c tempPropObj ; //added by minkesh patel
        for(Apttus_Proposal__Proposal_Line_Item__c pliSO : pliSOList){
            Id proposalId = pliSO.Apttus_Proposal__Proposal__c;

            if(proposalId != null
                && pIdtoProposalSOMap.containsKey(proposalId))
            {    
                
                //system.debug('pliSO.Net_to_Zscaler__c==='+pliSO.Net_to_Zscaler__c);
                If(pliSO.Net_to_Zscaler__c == Null){
                   pliSO.Net_to_Zscaler__c = 0; 
                }
                temptotal += pliSO.Net_to_Zscaler__c; //added by minkesh patel 30/03/2020
                tempPropObj = pIdtoProposalSOMap.get(proposalId); //added by minkesh patel 30/03/2020
                tempPropObj.Total_Net_to_Zscaler__c = temptotal; //added by minkesh patel 30/03/2020
                //system.debug('calcu==temptotal'+temptotal);
                // Derivation 1: [APTS_User_Manager__c]
                Apttus_Proposal__Proposal__c pSO = pIdtoProposalSOMap.get(proposalId);
                if(pSO.OwnerId != null
                    && uIdtouserSOMap.containsKey(pSO.OwnerId)){
                    pliSO.APTS_User_Manager__c = uIdtouserSOMap.get(pSO.OwnerId).ManagerId;
                }
            }

            //Derivation 2: Ramped Months for Ramp > 6 months approval
            pliSO.Ramped_Months__c = pliSO.Ramp_Months__c;
        }
        //system.debug('tempPropObj.Total_Net_to_Zscaler__c==='+tempPropObj.Total_Net_to_Zscaler__c);
        If(tempPropObj.Id != Null){ //added by minkesh patel 30/03/2020
            update tempPropObj;
        }
    }

    // Vijay: Commented this block as the logic is moved to proposal trigger.
    // public static void doAfterDerivations(List<Apttus_Proposal__Proposal_Line_Item__c> pliSOList){
    //     map<Id, String> proposalLineBundleMap = new map<Id, String>();
    //     map<Id, Product2> productMap = new map<Id, Product2>([Select Id, Description from Product2 Where Name IN: BUNDLE_PRODUCTS]);
    //     set<Id> proposalSet = new Set<Id>();
    //     for(Apttus_Proposal__Proposal_Line_Item__c pliSO : pliSOList){
    //         proposalSet.add(pliSO.Apttus_Proposal__Proposal__c);
    //     }
    //     List<Apttus_Proposal__Proposal_Line_Item__c> allProposalLines = [Select Id,
    //                                                                             Apttus_Proposal__Product__c,
    //                                                                             Product_Name__c,
    //                                                                             Apttus_Proposal__Proposal__c
    //                                                                             From
    //                                                                             Apttus_Proposal__Proposal_Line_Item__c
    //                                                                             Where
    //                                                                             Apttus_Proposal__Proposal__c IN: proposalSet];
    //     for(Apttus_Proposal__Proposal_Line_Item__c pliSO : allProposalLines){
    //         if(BUNDLE_PRODUCTS.contains(pliSO.Product_Name__c)){
    //             String productDescription = '';
    //             if(productMap.get(pliSO.Apttus_Proposal__Product__c) != null){
    //                 productDescription = productMap.get(pliSO.Apttus_Proposal__Product__c).Description;
    //             }
    //             if(proposalLineBundleMap.get(pliSO.Apttus_Proposal__Proposal__c) == null){
    //                 proposalLineBundleMap.put(pliSO.Apttus_Proposal__Proposal__c, pliSO.Product_Name__c + ' - ' + productDescription + '; \n');
    //             }
    //             else{
    //                 proposalLineBundleMap.put(pliSO.Apttus_Proposal__Proposal__c, proposalLineBundleMap.get(pliSO.Apttus_Proposal__Proposal__c) + pliSO.Product_Name__c + ' - ' + productDescription + '; \n');
    //             }
    //         }
    //     }
    //     List<Apttus_Proposal__Proposal__c> proposalToUpdate = [Select Id, Proposal_Bundle_Items__c
    //                                                                     from Apttus_Proposal__Proposal__c
    //                                                                     Where
    //                                                                     Id IN: proposalSet];
    //     for(Apttus_Proposal__Proposal__c proposalRec : proposalToUpdate){
    //        if(proposalLineBundleMap.get(proposalRec.Id) == null){
    //            proposalRec.Proposal_Bundle_Items__c = null;
    //        }
    //        else{
    //            proposalRec.Proposal_Bundle_Items__c = proposalLineBundleMap.get(proposalRec.Id);
    //        }
    //     }
    //     try{
    //         Database.update(proposalToUpdate, true);
    //     }
    //     catch(Exception exp){
    //     }
    // }
    // public static void updatepropasal(List<Apttus_Proposal__Proposal_Line_Item__c> prolineitemsList){
    //     Set<Id> QuoteIds= new Set<Id> ();
    //  Set<String> ProductNames= new Set<String>();
    //     for(Apttus_Proposal__Proposal_Line_Item__c pli: prolineitemsList){
    //         QuoteIds.add(pli.Apttus_Proposal__Proposal__c);
    //     }
    //     List<Apttus_Proposal__Proposal__c> qutrecList = new list<Apttus_Proposal__Proposal__c>();
    //     List<Apttus_Proposal__Proposal_Line_Item__c> qutlineitemrecList = new list<Apttus_Proposal__Proposal_Line_Item__c>();
    //     qutrecList        = [Select id,
    //                         OTS_Products__c,Support_Products__c,
    //                         ZIA_Products__c,ZPA_Products__c,
    //                         Subscription_to_Zscaler_Internet_Access__c,
    //                         Subscription_to_Zscaler_Private_Access__c,
    //                         Premium_Support__c,One_Time_Services__c
    //                         from Apttus_Proposal__Proposal__c
    //                         where id in : QuoteIds];
    //     qutlineitemrecList= [SELECT Apttus_QPConfig__ExtendedPrice__c,Apttus_Proposal__Proposal__c,
    //                         Apttus_Proposal__Product__r.Zscaler_Product_Family__c,Apttus_Proposal__Product__r.Name
    //                         FROM Apttus_Proposal__Proposal_Line_Item__c
    //                         WHERE Apttus_Proposal__Proposal__c In :QuoteIds];
    //
    //    for(Apttus_Proposal__Proposal__c app: qutrecList){
    //                 app.Subscription_to_Zscaler_Internet_Access__c=0;
    //                 app.Subscription_to_Zscaler_Private_Access__c=0;
    //                 app.One_Time_Services__c=0;
    //                 app.Premium_Support__c=0;
    //                 app.OTS_Products__c= null;
    //                 app.Support_Products__c=null;
    //                 app.ZPA_Products__c= null;
    //                 app.ZIA_Products__c= null;
    //
    //         for(Apttus_Proposal__Proposal_Line_Item__c appl: qutlineitemrecList){
    //          system.debug('&&&&&&&&'+appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c);
    //              boolean b = false;
    //              for(String str : ProductNames){
    //                  if(str==appl.Apttus_Proposal__Product__r.Name)
    //                  b=true;
    //              }
    //          if(app.id == appl.Apttus_Proposal__Proposal__c){
    //             ProductNames.add(appl.Apttus_Proposal__Product__r.Name);
    //                if(appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZIA'){
    //                app.Subscription_to_Zscaler_Internet_Access__c+=appl.Apttus_QPConfig__ExtendedPrice__c;
    //                  if(app.ZIA_Products__c != null && !b){
    //                  app.ZIA_Products__c=app.ZIA_Products__c+',\r\n'+appl.Apttus_Proposal__Product__r.Name;
    //                  }
    //                  else
    //                  app.ZIA_Products__c=appl.Apttus_Proposal__Product__r.Name;
    //                }
    //                else if(appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'ZPA'){
    //                app.Subscription_to_Zscaler_Private_Access__c+=appl.Apttus_QPConfig__ExtendedPrice__c;
    //                    if(app.ZPA_Products__c !=null && !b){
    //                    app.ZPA_Products__c=app.ZPA_Products__c+',\r\n'+appl.Apttus_Proposal__Product__r.Name;
    //                    }
    //                    else
    //                    app.ZPA_Products__c=appl.Apttus_Proposal__Product__r.Name;
    //                }
    //                else if(appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Support' || appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Premium Support'){
    //                app.Premium_Support__c+=appl.Apttus_QPConfig__ExtendedPrice__c;
    //                    if(app.Support_Products__c != null && !b){
    //                    app.Support_Products__c=app.Support_Products__c+',\r\n'+appl.Apttus_Proposal__Product__r.Name;
    //                    }
    //                    else
    //                    app.Support_Products__c=appl.Apttus_Proposal__Product__r.Name;
    //                }
    //                else if(appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Deployment' || appl.Apttus_Proposal__Product__r.Zscaler_Product_Family__c == 'Education'){
    //                app.One_Time_Services__c+=appl.Apttus_QPConfig__ExtendedPrice__c;
    //                    if(app.OTS_Products__c !=null && !b){
    //                    app.OTS_Products__c=app.OTS_Products__c+',\r\n'+appl.Apttus_Proposal__Product__r.Name;
    //                    }
    //                    else
    //                    app.OTS_Products__c=appl.Apttus_Proposal__Product__r.Name;
    //                }
    //
    //             }
    //         }
    //     }
    //     update qutrecList;
    // }
}