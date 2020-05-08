({
	showtoast: function(title, type, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        
        toastEvent.fire();
    },
    escalate: function (component, event, helper, deflevel, custBasedEsc) {
        let action = component.get("c.escalateCs");
        console.log(component.get("v.recordId"));
        console.log(component.get("v.reason"));
        console.log(component.get("v.typeofEscalation"));
        console.log(deflevel);
        component.set("v.showSpinner", true);
        action.setParams({
            recId: component.get("v.recordId"),
            reason: component.get("v.reason"),
            typeofEscalation: component.get("v.typeofEscalation"),
            deflevel: deflevel,
            custBasedEsc: custBasedEsc
        });
        action.setCallback(this, function (res) {
            console.log(res);
            if (res.getState() === 'SUCCESS') {
                if (res.getReturnValue() == 'Success') {
                    helper.showtoast('Success!', 'success', 'Case has been Escalated!');
                } else {
                    helper.showtoast('Error!', 'error', res.getReturnValue());
                }

                component.set("v.showSpinner", false);
                component.set("v.reason", "");
                $A.get('e.force:refreshView').fire();
                //$A.get("e.force:closeQuickAction").fire();
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showtoast('Error!', 'error', errors[0].message);
                        component.set("v.showSpinner", false);
                        component.set("v.reason", "");
                        //$A.get("e.force:closeQuickAction").fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
})