({
    GetOppPartnersList: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var OpportunityId = component.get("v.OppId");
        if (OpportunityId != undefined) {
            var action = component.get("c.GetOppPartnersDetais");
            action.setParams({
                'OppId': OpportunityId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var InnerRecord = response.getReturnValue();
                    //alert('--List--'+OptyPartners.length);
                    component.set("v.OppPartnersList", InnerRecord.PartnersList);
                    component.set("v.IsResellerPresent", InnerRecord.IsResellerPresent);
                    component.set("v.IsTechPartnerPresent", InnerRecord.IsTechPartnerPresent);
                    component.set("v.IsIntegratorPresent", InnerRecord.IsIntegratorPresent);
                    component.set("v.IsDistributorPresent", InnerRecord.IsDistributorPresent);
                    component.set("v.isDealRegPresent", InnerRecord.isDealRegPresent);
                    component.set("v.isPOVPresent", InnerRecord.isPOVPresent);
                    component.set("v.isArchWorkshopPresent", InnerRecord.isArchPresent);
                    component.set("v.showEditandDelete", InnerRecord.showEditandDelete);
                    component.set("v.PartnerProgramMap", InnerRecord.partnerProgramPickvals);

                    for (let rec in InnerRecord.PartnersList) {
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'Deal Reg') {
                            component.set("v.dealRegrec", InnerRecord.PartnersList[rec]);
                        }
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'Architecture Workshop') {
                            component.set("v.archWorkshoprec", InnerRecord.PartnersList[rec]);
                        }
                        if (InnerRecord.PartnersList[rec].Partner_Type__c == 'POV') {
                            component.set("v.POVrec", InnerRecord.PartnersList[rec]);
                        }
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
    },

    GetOppDetails: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var OpportunityId = component.get("v.OppId");
        if (OpportunityId != undefined) {
            var action = component.get("c.GetOpportunity");
            action.setParams({
                'OppId': OpportunityId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var Opportunity = response.getReturnValue();
                    component.set("v.OppRecord", Opportunity);
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
    },
    AddRowHelper: function (component, event, helper) {
        var RowItemList = component.get("v.WrapperList");
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
    },
    savePartnerProgramforPrimaryPartner: function (component, event, helper, PartnerId, PartProg) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.updatePartnerProgram");
        action.setParams({
            'PartnerId': PartnerId,
            'Program': PartProg,
            'OppId': component.get("v.OppId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                    component.set("v.partnerid", '');
                    component.set("v.editMode", false);
                }
                else if (ResultMap.State == 'Validation') {
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
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
    },

    UpdatePartner: function (component, event, helper, PartnerId, Type) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var OptyId = component.get("v.OppId");
        var action = component.get("c.UpdatePrimaryPartner");
        action.setParams({
            'PartnerId': PartnerId,
            'Type': Type,
            'OppId': OptyId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                }
                else if (ResultMap.State == 'Validation') {
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
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
    },

    RemovePrimaryPartner: function (component, event, helper, PartnerId, Type) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var OptyId = component.get("v.OppId");
        var action = component.get("c.UuncheckPrimaryPartner");
        action.setParams({
            'PartnerId': PartnerId,
            'Type': Type,
            'OppId': OptyId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            component.find("Id_spinner").set("v.class", 'slds-hide');
            if (state === "SUCCESS") {
                var ResultMap = response.getReturnValue();
                if (ResultMap.State == 'Success') {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                    helper.GetOppPartnersList(component, event, helper);
                }
                else if (ResultMap.State == 'Validation') {
                    component.set("v.showMainErrors", true);
                    component.set("v.errorMessage", ResultMap.Message);
                    helper.GetOppPartnersList(component, event, helper);
                }
                else {
                    component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
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