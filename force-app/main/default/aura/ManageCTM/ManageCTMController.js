({
    doinit : function(component, event, helper) {
        let rec = component.get("v.record");
            var redirectTo = '/apex/ContactThatMatterEditPage?Accid=' + rec.fields.Id.value;
            window.open(redirectTo,'_self');
            $A.get('e.force:closeQuickAction').fire();
    }
})