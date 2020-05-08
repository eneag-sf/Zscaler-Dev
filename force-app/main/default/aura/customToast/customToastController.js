({
    showToast : function(component, event, helper) {
                
        var params = event.getParam( 'arguments' );  
        try {
          component.find('notifLib').showToast({
                "variant": params.messageType,
                "message": params.message,
                "mode": "dismissable"
            });
        }
        catch(err) {
            component.set("v.message", params.message);
            component.set("v.messageType", params.messageType);
            
            $A.util.removeClass( component.find( 'toastModel' ), 'slds-hide' );
            $A.util.addClass( component.find( 'toastModel' ), 'slds-show' );
            
            var closeTime =  component.get("v.autoCloseTime");
            var autoClose =  component.get("v.autoClose");
            var autoCloseErrorWarning =  component.get("v.autoCloseErrorWarning");
            
            if(autoClose)
                if( (autoCloseErrorWarning && params.messageType != 'success') || params.messageType == 'success') {
                setTimeout(function(){ 
                    $A.util.addClass( component.find( 'toastModel' ), 'slds-hide' ); 
                    component.set("v.message", "");
                    component.set("v.messageType", "");
                }, closeTime);
            }
        }
       
	},
    
	closeModel : function(component, event, helper) {
		$A.util.addClass( component.find( 'toastModel' ), 'slds-hide' );
        component.set("v.messageType", "");
        component.set("v.messageType", "");
	}
})