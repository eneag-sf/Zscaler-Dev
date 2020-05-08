({
    doInit : function(component, event, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var ExecutiveReqId = component.get("v.ExecutiveBriefId");
        var action = component.get("c.SubmitForApproval");
        action.setParams({
            'ExecutiveReqRecId': ExecutiveReqId
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if(ResultMap.State == 'Success'){
                    component.set("v.Message",ResultMap.Message);
                    helper.openERRecord(component);
                }else{
                    component.set("v.IsSubmitError",true);
                    component.set("v.Message",ResultMap.Message);
                }
            }else if (state === "INCOMPLETE") {
                component.set("v.IsSubmitError",true);
                component.set("v.Message","Error occurred, Please try again.");
            }else if (state === "ERROR") {
                component.set("v.IsSubmitError",true);
                component.set("v.Message","Error occurred, Please contact Administartor");
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                     console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel : function(component, event, helper){
        helper.openERRecord(component);
    },
    
    
})