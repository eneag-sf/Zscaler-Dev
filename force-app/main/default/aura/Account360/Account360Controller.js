({
    doinit : function(component, event, helper) {
        let rec = component.get("v.record");
        var redirectTo = '/apex/AccountReportLWC?id=' + rec.fields.Id.value;
        $A.get('e.force:closeQuickAction').fire();
        window.open(redirectTo,'_blank');
    }
})