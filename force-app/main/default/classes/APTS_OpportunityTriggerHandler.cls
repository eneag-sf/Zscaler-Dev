public class APTS_OpportunityTriggerHandler {


      List<Opportunity> existingOppRenewal;

      public void handleBeforeInsert(list<Opportunity> newOppList)
      {
          string defaultPriceBookName = null;
          string defaultPriceList = null;

          Apttus__APTS_Admin__c[] adminEntry = [select Name, Apttus__Value__c from Apttus__APTS_Admin__c
                               where Name = 'APTS_DefaultPriceBook'];

          Pricebook2[] priceBooks;
          Apttus_Config2__PriceList__c[] priceLists;


          if(adminEntry !=null && !adminEntry.isEmpty())
          {
            defaultPriceBookName =  adminEntry[0].Apttus__Value__c;
          }

          adminEntry = null;

          adminEntry = [select Name, Apttus__Value__c from Apttus__APTS_Admin__c
                               where Name = 'APTS_DefaultPriceList'];


          if(adminEntry !=null && !adminEntry.isEmpty())
          {
            defaultPriceList =  adminEntry[0].Apttus__Value__c;
          }

         if(defaultPriceBookName != null)
         {
            priceBooks = [select Id, name from Pricebook2 where name =: defaultPriceBookName];
         }

         if(defaultPriceList != null)
         {
            priceLists = [select Id, name from Apttus_Config2__PriceList__c where name =: defaultPriceList];
         }

        for(Opportunity oppor : newOppList)
        {
            if(priceBooks != null && !priceBooks.isEmpty())
            {
                oppor.Pricebook2Id = priceBooks[0].Id;
            }

            if( priceLists!= null && !priceLists.isEmpty())
            {
                oppor.Price_List__c = priceLists[0].Id;
            }


            if (oppor.Farthest_Renewal_Due_Date_Formula__c != null) {
                oppor.Contract_End_Date_New__c = oppor.Farthest_Renewal_Due_Date_Formula__c;
            }
        }

      }
    /*
      public void autoreneOpportunity(list<Opportunity> newOppList, Map<Id, Opportunity> oppOldMap)
       {

           existingOppRenewal = new List<Opportunity>();
           List<Opportunity> oppClone = new List<Opportunity>();
           List<Opportunity> oppFutureList= new List<Opportunity>();
           List<Opportunity> oppClosedList = new List<Opportunity>();
           Set<ID> accntid = new Set<ID>();
           Map<ID,Opportunity> accntOppMap= new Map<ID,Opportunity>();
           for(Opportunity opp: newOppList)
           {
                System.debug('3---'+oppOldMap.get(opp.id));
             if(opp.IsWon && !oppOldMap.get(opp.id).isWon)
             {
               oppClosedList.add(opp);
               accntid.add(opp.accountid);
             }
           }

           List<Opportunity> opportunityList = [Select id, accountid from opportunity where accountid in :accntid and type='Renewal'];
           System.debug('1---'+newOppList);
           for(Opportunity opp:opportunityList )
           {
               if(!accntOppMap.containsKey(opp.accountid))
                accntOppMap.put(opp.accountid, opp);
           }
            System.debug('1---'+oppClosedList);
           for(Opportunity opp: oppClosedList)
           {
               if(accntOppMap.containsKey(opp.accountid))
               {
                   existingOppRenewal.add(opp);
               }
               else
               {
                oppClone.add(opp);
               }
           }
           if(oppClone!=null && !oppClone.isEmpty())
             oppFutureList=  deepCloneOpps(oppClone);

              oppFutureList.addAll(existingOppRenewal);

               Set<ID> oppidSet = new Set<ID>();

               for(Opportunity opp:oppFutureList )
                    oppidSet.add(opp.id);

                if(oppidSet!=null && !oppidSet.isEmpty())
                APTS_AutoRenewQuote.autocreateQUoteFunction(oppidSet);

       }

          public  list<Opportunity> deepCloneOpps(list<Opportunity> oppstoclone)
        {



            list<Opportunity> clones = new list<Opportunity>();



            if(oppstoclone.isEmpty())
            {
                system.debug('\n\n\n-------------------- No records in set to clone. Aborting');
                return null;
            }


                //get the ids of all these objects.
                for(Opportunity thisObj :oppstoclone)
                {

                    Opportunity clonedObject = thisObj.clone(true,true,false,false);
                    clonedObject.id=null;

                     clonedObject.name = clonedObject.APTS_Account_Name__c + ' - Renewal';
                     clonedObject.StageName='3-Qualified and Provisioned';
                     clonedobject.type='Existing Customer (Renewal)';
                     clonedobject.Expected_Term_Months__c=36;
                     //change it to quote last date
                     clonedobject.Start_Date__c=Date.today();
                     clonedobject.End_Date__c=clonedobject.Start_Date__c.addYears(3);

                    clones.add(clonedObject);
                }



                //insert the clones
                insert clones;

                return clones;

        }

*/
  }