({
    doinit : function(component, event, helper) {
        let rec = component.get("v.record");
        console.log(rec.fields.Generate_Value_Summary__c.value);
        if(rec.fields.Generate_Value_Summary__c.value != 'This account does not have enough data to generate value summary document.'){
            console.log('inside if');
            let action = component.get("c.checkdomain");
            action.setParams({
                accountId: rec.fields.Id.value
            });
            action.setCallback(this, function (res) {
                console.log(res);
                if (res.getState() === 'SUCCESS') {
                    if(res.getReturnValue() == 'Success'){
                        helper.showtoast('Success!','success','Request for Value Summary Doc has been submitted. Link to the Document will be received via Email');
                    }else{
                        helper.showtoast('Error!','error',res.getReturnValue());
                    }
                    $A.get('e.force:closeQuickAction').fire();
                    
                } else if (res.getState() === 'ERROR') {
                    var errors = res.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showtoast('Error!','error',errors[0].message);
                            $A.get('e.force:closeQuickAction').fire();
                        }
                    }
                }
            });
            $A.enqueueAction(action);
            
        }else{
            console.log('inside else');
            helper.showtoast('Error!','error',rec.fields.Generate_Value_Summary__c.value);
            $A.get('e.force:closeQuickAction').fire();
        }
    }
})