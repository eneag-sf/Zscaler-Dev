({
    PushCommentstoChild : function(component, event, helper) {
        var rec = component.get("v.record");       
        console.log('inside PushCommentstoChild method '+rec);
		
		if(rec.fields.Push_comment_to_child_cases__c.value == true){
			var action = component.get("c.PushCommentstoChildCases");
			action.setParams({
				'Caseid': component.get("v.recordId")
			});  
			action.setCallback(this,function(response) {
				var state = response.getState();
				component.set("v.showSpinner",false);
				if (state === "SUCCESS") {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "SUCCESS!",
						"message": "Operation Successful"
					});
					toastEvent.fire();
					$A.get('e.force:closeQuickAction').fire();
				}else if (state === "ERROR") { 
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "ERROR!",
						"message": "Failed to update Comments"
					});
					toastEvent.fire();
					$A.get('e.force:closeQuickAction').fire();
				}
													
			});
			$A.enqueueAction(action);
			
		}else{
			 var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error!",
					"message": "Please Enable Push comment to child_cases to process the Operation."
			});
			toastEvent.fire();
		}
		$A.get('e.force:closeQuickAction').fire();	 
    }
})