({
    doinit : function(component, event, helper) {
        
        var retUrl = "" + window.parent.location;
        if (retUrl.indexOf('#') > -1) 
        {
            retUrl = retUrl.substr(0, retUrl.indexOf('#'));
        }

        let rec = component.get("v.record");
            var redirectTo = '/apex/ManageSCI?edit=falseretUrl='+retUrl+'&accountId='+rec.fields.Id.value+'&patchTeamId='+rec.fields.Sales_Territory__c.value;
            window.open(redirectTo,'_self');
            $A.get('e.force:closeQuickAction').fire();
    }
})