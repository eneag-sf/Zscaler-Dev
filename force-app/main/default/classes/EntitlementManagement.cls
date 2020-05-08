public class EntitlementManagement {
    public static void createEntitleMent(Map<Id, String> accmap){
        Map<String, Id>  spmap = new Map<String, Id>();
        for(SlaProcess sp: [Select Id, Name from SlaProcess where (name in :accmap.values() or name = 'Standard') and IsActive =true]){
            spmap.put(sp.Name, sp.Id);
        }
        List<Entitlement> elst = new List<Entitlement>();
        for(Id accid: accmap.keySet()){
            Entitlement erec = new Entitlement();
            erec.Name = accmap.get(accid);
            erec.AccountId = accId;
            erec.StartDate = date.today();
            erec.SlaProcessId = accmap.get(accid) != null && spmap != null && !spmap.isEmpty() && spmap.containsKey(accmap.get(accid)) ? spmap.get(accmap.get(accid)) : spmap.get('Standard');
            elst.add(erec);
        }
        insert elst;
    }
    public static void updateExistingEntitlement(Map<Id, String> accmap){
        List<Entitlement> elst = new List<Entitlement>();
        for(Entitlement erec: [Select Id, EndDate, Startdate from Entitlement where AccountId in :accmap.keySet() and Enddate= null]){
            if(erec.Startdate <= date.today().adddays(-1)){
                erec.EndDate = date.today().adddays(-1);
            }else{
                erec.EndDate = date.today();
            }
            elst.add(erec);
        }
        update elst;
    }
}