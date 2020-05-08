({
    doinit: function (component, event, helper) {
        let rec = component.get("v.record");
        if (rec.fields.Contacts_that_matter__c.value == true) {
            console.log('CTM is checked');
            rec.fields.Contacts_that_matter__c.value = false;
            helper.handleSaveRecord(component, event, helper);
            
        } else {
            console.log('CTM is uncheck');
            let contemail = rec.fields.Email.value;
            let contacdomain = contemail != null && contemail != undefined && contemail != '' && contemail.indexOf('@') != -1 && contemail.split('@')[1] != null && contemail.split('@')[1].indexOf('.') != -1 ? contemail.split('@')[1] : '';
            let action = component.get("c.checkdomain");
            action.setParams({
                accountId: rec.fields.AccountId.value,
                contactemaildomain: contemail
            });
            action.setCallback(this, function (res) {
                console.log(res);
                if (res.getState() === 'SUCCESS') {
                    if (res.getReturnValue() != null && res.getReturnValue() != undefined) {
                        let resp = res.getReturnValue();
                        console.log(resp);
                        if (resp) {
                            rec.fields.Contacts_that_matter__c.value = true;
                            helper.handleSaveRecord(component, event, helper);
                        } else {
                            let response = confirm('The email domain for this contact does not match with the organizational domain of the account. To make this contact a CTM, the domain address should match. Click OK to create a case with SFDC support team to validate if the email domain is valid. You will be notified once the domain review is completed.');
                            if (response == true) {
                                let action1 = component.get("c.createCase");
                                action1.setParams({ accId: rec.fields.AccountId.value, accName: rec.fields.Account.value.fields.Name.value, conId: rec.fields.Id.value, contactname: rec.fields.Name.value });
                                action1.setCallback(this, function (res) {
                                    console.log(res);
                                    if (res.getState() === 'SUCCESS') {
                                        if (res.getReturnValue() != null && res.getReturnValue() != undefined) {
                                            let resp = res.getReturnValue();
                                            console.log(resp);
                                            alert(resp);
                                            $A.get('e.force:closeQuickAction').fire();

                                        }
                                    } else if (res.getState() === 'ERROR') {
                                        var errors = res.getError();
                                        if (errors) {
                                            if (errors[0] && errors[0].message) {
                                                helper.showtoast('Error', 'error', errors[0].message);
                                                component.set("v.showSpinner", false);
                                                $A.get('e.force:closeQuickAction').fire();
                                            }
                                        }
                                    }
                                });
                                $A.enqueueAction(action1);
                            }else{
                                $A.get('e.force:closeQuickAction').fire();
                            }
                        }
                    }
                } else if (res.getState() === 'ERROR') {
                    var errors = res.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showtoast('Error', 'error', errors[0].message);
                            component.set("v.showSpinner", false);
                        }
                    }
                    $A.get('e.force:closeQuickAction').fire();
                }
            });
            $A.enqueueAction(action);
        }
    },

})