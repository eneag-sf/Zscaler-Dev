({
    myAction : function(component, event, helper) {
        
    },
    handleClose: function(component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire()
    },
    closeMessage: function(component, event, helper){
         component.set("v.showErrorModal",false);
    },
    handleModal : function (component,event,helper) {
        var isTrue = component.get("v.showModal");
        if(isTrue===false){
            component.set("v.showModal",true);
        }else if(isTrue===true){
            component.set("v.showModal",false);
        }
    },
    handleSave: function(component, event, helper)
    {
        component.set("v.loading",true);
        var action = component.get('c.cloneCase'); 
        action.setParams({
            "caseId" : component.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            var storeResponse = a.getReturnValue();
            if(state == 'SUCCESS') {
                $A.get("e.force:closeQuickAction").fire();
                var redirectUrl = '/' + storeResponse.Id;
                component.set("v.loading",false);
                component.set("v.showModal",false);
                $A.get("e.force:navigateToURL").setParams({
                    "url": redirectUrl
                }).fire();
            }else{
                component.set("v.loading",false);
                component.set("v.showModal",false);
                component.set("v.errorMessage",'Something went wrong please try again.');
                component.set("v.showErrorModal",true);
            }
        });
        $A.enqueueAction(action);
    }
})