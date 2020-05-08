({
    
    remoteCall: function(component, functionName, payload){
		
         return new Promise(function(resolve, reject)
        { 
        	var action = component.get('c.' + functionName);
        	action.setParams(payload);
            
            action.setCallback(this, function(res){          
                res.getState() === 'SUCCESS' ? resolve(res.getReturnValue()) : reject(res.getReturnValue());
            });
            
            $A.enqueueAction(action);
        });
        
	},

})