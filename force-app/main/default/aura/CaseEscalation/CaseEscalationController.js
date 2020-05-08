({
    doinit: function (component, event, helper) {
        
        let action = component.get("c.checkCaseEscalation");
        action.setParams({
            recId: component.get("v.recordId")
        });
        action.setCallback(this, function (res) {
            console.log(res);
            if (res.getState() === 'SUCCESS') {
                if (res.getReturnValue() != null && res.getReturnValue() != undefined) {
                    let resp = res.getReturnValue();
                    console.log(resp);
                    /*if(resp.isEscalated){
                        component.set("v.inescalation", false);
                    }
                    component.set("v.showengesc", resp.showengesc);
                    component.set("v.showhandoff", resp.showhandoff);
                    component.set("v.showescalation", resp.isEscalated);*/
                    component.set("v.showdefcon", resp.showdefcon);
                    component.set("v.showSpinner", false);
                    component.set("v.typeofEscalation", "otherescalation");
                    component.set("v.escTitle", "Request for Escalation");
                    component.set("v.escLabel", "Reason for Escalation");
                }
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showtoast('Error - Escalation section!', 'error', errors[0].message);
                        component.set("v.showSpinner", false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    /*engescalation: function (component, event, helper) {
        component.set("v.typeofEscalation", "engEscalation");
        component.set("v.escTitle", "Engineering Escalation");
        component.set("v.escLabel", "Reason for Engineering Escalation");
        component.set("v.showModal", true);
    },
    otherescalation: function (component, event, helper) {
        component.set("v.typeofEscalation", "otherescalation");
        component.set("v.escTitle", "Request for Escalation");
        component.set("v.escLabel", "Reason for Escalation");
        component.set("v.showModal", true);
    },
    handoff: function (component, event, helper) {
        component.set("v.typeofEscalation", "handoff");
        component.set("v.escTitle", "Case Handoff");
        component.set("v.escLabel", "Reason for Case Handoff");
        component.set("v.showdefcon", false);
        component.set("v.showModal", true);
        
    },*/
    cancel: function (component, event, helper) {
        component.set("v.typeofEscalation", "");
        $A.get("e.force:closeQuickAction").fire();

    },

    handleLoad: function (cmp, event, helper) {
        console.log(cmp.find('defconval').get("v.value"));
        if (cmp.get("v.showdefcon") && !cmp.find('defconval').get("v.value")) {
            cmp.find('defconval').set("v.value", '5');
        }
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        if (component.get("v.showdefcon")){
            var fields = event.getParam('fields');
            helper.escalate(component, event, helper, fields.Defcon_Level__c, fields.Escalation_on_behalf_of_Customer__c);
            console.log(fields.Defcon_Level__c);
        } else {
            helper.escalate(component, event, helper, '');
        }
        //component.find('caseform').submit(fields);
        component.set('v.showSpinner', true);
    },
    escalateCase: function(component, event, helper){
        helper.escalate(component, event, helper, '');
    },
    custesc: function(cmp, event, helper){
        if (cmp.get("v.showdefcon") && !cmp.find('custesc').get("v.value")) {
            cmp.find('defconval').set("v.value", '5');
        }else if (cmp.get("v.showdefcon") && cmp.find('custesc').get("v.value")) {
            cmp.find('defconval').set("v.value", '4');
        }
    },

})