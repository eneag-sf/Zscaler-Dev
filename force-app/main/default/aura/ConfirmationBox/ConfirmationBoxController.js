({
    doInit: function(component, event, helper) 
    {
        component.set('v.loading', false);
        helper.remoteCall(component, 'getEmailText', {
            caseId: component.get('v.recordId')
        })
        .then(function(order) {
            console.log('order:-'+order);
            component.set('v.mailBody', order);
         });
    },
    
    
    confirmBox: function(component, event, helper){
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        var refreshView = $A.get('e.force:refreshView');
        //component.set('v.loading', true);
        console.log('00000000'+component.get('v.mailBody'));
        helper.remoteCall(component, 'sendMail', {
            caseId: component.get('v.recordId'),
            emailBody: component.get('v.mailBody')
        })
        .then(function(order) {
            console.log(order); 
            component.set('v.loading', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type":"success",
                "message": "Email Sent successfully."
            });
            toastEvent.fire();
            refreshView.fire();
            closeQuickAction.fire();            
        });
        
    },
    
    
    handleClose: function(component, event, helper) 
    {
        $A.get("e.force:closeQuickAction").fire()
    },
    
    saveTemplateOnCase: function(component, event, helper){
        console.log(component.get('v.mailBody'));
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        var refreshView = $A.get('e.force:refreshView');
        helper.remoteCall(component, 'setEmailTextOnCase', {
            caseId: component.get('v.recordId'),
            emailBody: component.get('v.mailBody')
        })
        .then(function(order) {
            console.log('data:--'+order);
            var toastEvent = $A.get("e.force:showToast");
            if(order === 'Success'){
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "message": "Email has been updated successfully."
                });
            }else{
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"Error",
                    "message": "More then 131,072 characters are not Allowed."
                });
            }
            toastEvent.fire();
            refreshView.fire();
            closeQuickAction.fire();
        });
    }
    
    
})