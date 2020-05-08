public class UpdatecontactStatus{
    @InvocableMethod
    public static void updateContactStatus(List<Id> ldIds){
        
    if(OnOffSwitch__c.getInstance('updateContactStatus').Deactivate_Component__c!=null && OnOffSwitch__c.getInstance('updateContactStatus').Deactivate_Component__c==False){
      system.debug('run the code ');      
      Set<String> setldIds = new Set<String>();
        
      for(String i: (List<String>) ldIds){
        setldIds.add(String.valueOf(i).substring(0,15));
      }
      system.debug('++++'+setldIds);
      Map<Id,Lead> maplds = new map<Id,Lead>([Select Id, Status from Lead where Id in :ldIds]);
      Map<Id,Contact> mapleadidcontacts = new Map<Id,contact>();
      for(Contact con: [Select Id, Converted_Lead_Id__c, Contact_Lead_Status__c from contact where Converted_Lead_Id__c in :setldIds]){
        mapleadidcontacts.put(con.Converted_Lead_Id__c,con);
      }
      for(Id ldId: mapleadidcontacts.keyset()){
         if(mapleadidcontacts.get(ldId) != null && maplds.containskey(ldId) && maplds.get(ldId) != null){
           mapleadidcontacts.get(ldId).Contact_Lead_Status__c = maplds.get(ldId).Status;
           system.debug('+++++++++'+maplds.get(ldId).Status);
         } 
         
      }
      
      system.debug('+++++++++'+mapleadidcontacts.values());
      update mapleadidcontacts.values();
  
    }else{
      system.debug('do not run the code as updateContactStatus is deactivated');
    }       
    } 
}