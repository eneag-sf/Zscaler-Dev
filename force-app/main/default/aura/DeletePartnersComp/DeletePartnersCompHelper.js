({
    DeleteRecord : function(component, event, helper){
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.Errors",false);
        component.set("v.errorMessage",'');
        var OppPartnerId = component.get("v.PartnerId");
        var action = component.get("c.DeletePartner");
        action.setParams({
            'PartnerId': OppPartnerId
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('--state--'+state);
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                var OptyId = ResultMap.OppId;
                component.set("v.OppId",OptyId);
                if(ResultMap.State == 'Success'){
                    window.location = '/'+OptyId;
                }else{
                    component.set("v.Errors",true);
                    component.set("v.errorMessage",ResultMap.Message);
                }
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + 
                                  errors[0].message);
                        }
                    } 
                    else {
                        alert("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})