({
    doInit: function (component, event, helper) {
        helper.GetOppPartnersList(component, event, helper);
        helper.GetOppDetails(component, event, helper);
        helper.AddRowHelper(component, event, helper);
    },

    AddRow: function (component, event, helper) {
        helper.AddRowHelper(component, event, helper);
    },

    AddNewReseller: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        var Type = 'Reseller';
        component.set("v.PartnerType", Type);
    },

    AddNewTechPartner: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        var Type = 'Tech Partner';
        component.set("v.PartnerType", Type);
    },

    AddNewIntegrator: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        var Type = 'System Integrator';
        component.set("v.PartnerType", Type);
    },

    AddNewDistributor: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        var Type = 'Distributor';
        component.set("v.PartnerType", Type);
    },

    AddNewDealReg: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.donotshownewRow", true);
        var Type = 'Deal Reg';
        component.set("v.PartnerType", Type);
    },

    AddNewArch: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.donotshownewRow", true);
        var Type = 'Architecture Workshop';
        component.set("v.PartnerType", Type);
    },

    AddNewPOV: function (component, event, helper) {
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.IsAddNewPartner", true);
        component.set("v.donotshownewRow", true);
        var Type = 'POV';
        component.set("v.PartnerType", Type);
    },

    closeModel: function (component, event, helper) {
        component.set("v.IsPrimary", false);
        component.set("v.SelectedRecord", null);
        component.set("v.IsAddNewPartner", false);
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.set("v.donotshownewRow", false);
        var RowItemList = [];
        RowItemList.push({
            'SelectedRecord': null,
            'IsRadioChecked': false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.WrapperList", RowItemList);
    },

    DeleteRecord: function (component, event, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        var result = confirm("Want to delete?");
        if (result) {
            var OptyId = component.get("v.OppId");
            var selectedItem = event.currentTarget;
            var OppPartnerId = selectedItem.dataset.variablename;
            //alert('--Partner Id--'+OppPartnerId);
            var action = component.get("c.DeletePartnerRec");
            action.setParams({
                'PartnerId': OppPartnerId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                component.find("Id_spinner").set("v.class", 'slds-hide');
                if (state === "SUCCESS") {
                    var ResultMap = response.getReturnValue();
                    if (ResultMap.State == 'Success') {
                        component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                        //location.reload();
                        component.set("v.IsAddNewPartner", false);
                        helper.GetOppPartnersList(component, event, helper);
                        //window.open('/'+OptyId, '_parent');
                    } else {
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
        } else {
            component.find("Id_spinner").set("v.class", 'slds-hide');
        }

    },

    SaveDetails: function (component, event, helper) {
        //alert(JSON.stringify(component.get("v.WrapperList")));
        component.set("v.showErrors", false);
        component.set("v.showMainErrors", false);
        component.set("v.errorMessage", '');
        component.find("Id_spinner").set("v.class", 'slds-show');
        var PartnerType = component.get("v.PartnerType");
        var OptyId = component.get("v.OppId");
        var IsSave = true;

        var WrapperList = component.get("v.WrapperList");
        if (WrapperList.length > 0) {
            for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
                if (WrapperList[indexVar].SelectedRecord == null) {
                    IsSave = false;
                }
            }
            console.log(IsSave);
            if (IsSave == true) {
                var action = component.get("c.SavePartnerRec");
                action.setParams({
                    'OppId': OptyId,
                    'PartnerRecords': JSON.stringify(component.get("v.WrapperList")),
                    'PartnerType': PartnerType
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                    console.log('inside calback');
                    console.log(state);
                    if (state === "SUCCESS") {
                        var ResultMap = response.getReturnValue();
                        if (ResultMap.State == 'Success') {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'success');
                            //location.reload();
                            component.set("v.IsAddNewPartner", false);
                            component.set("v.donotshownewRow", false);
                            helper.GetOppPartnersList(component, event, helper);
                            //window.open('/'+OptyId, '_parent');
                        } else if (ResultMap.State == 'Validation') {
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", ResultMap.Message);
                        }
                        else {
                            component.find("Custtoast").showToastModel(ResultMap.Message, 'Error');
                        }
                    }
                    else if (state === "INCOMPLETE") {
                        component.set("v.showErrors", true);
                        component.set("v.errorMessage", 'Response is Incompleted');
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        console.log(errors);
                        if (errors) {
                            let message = '';
                            if (errors[0] && errors[0].message) {
                                message = errors[0].message;

                            } else if (errors[0] && errors[0].pageErrors && errors[0].pageErrors[0] && errors[0].pageErrors[0].message) {
                                message = errors[0].pageErrors[0].message;
                            }
                            component.set("v.showErrors", true);
                            component.set("v.errorMessage", message);

                        }
                        else {
                            alert("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                component.find("Id_spinner").set("v.class", 'slds-hide');
                component.set("v.showErrors", true);
                component.set("v.errorMessage", 'Please Select account');
            }
        } else {
            component.find("Id_spinner").set("v.class", 'slds-hide');
            component.set("v.showErrors", true);
            component.set("v.errorMessage", 'Please Select atleast one record');
        }
    },

    ChangeSelected: function (component, event, helper) {
        //alert('--changed--'+event.getSource().get("v.text"));
        var index = event.getSource().get("v.text");
        var WrapperList = component.get("v.WrapperList");
        for (var indexVar = 0; indexVar < WrapperList.length; indexVar++) {
            if (indexVar == index) {
                //alert(WrapperList[indexVar].IsRadioChecked);
                if (!WrapperList[indexVar].IsRadioChecked) {
                    WrapperList[indexVar].IsRadioChecked = true;
                } else {
                    WrapperList[indexVar].IsRadioChecked = false;
                }
            } else {
                WrapperList[indexVar].IsRadioChecked = false;
            }
        }
        component.set("v.WrapperList", WrapperList);
        //alert('--list--'+JSON.stringify(WrapperList));
    },

    removeRow: function (component, event, helper) {
        var Index = event.target.dataset.id;
        //alert('--index--'+Index);
        var WrapperList = component.get("v.WrapperList");
        WrapperList.splice(Index, 1);
        component.set("v.WrapperList", WrapperList);
    },

    ChangeResellerPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
        //alert('---PartnerId--'+PartnerId);
        helper.UpdatePartner(component, event, helper, PartnerId, 'Reseller');
    },
    editPartner: function (component, event, helper) {
        let partId = event.getSource().get("v.title");
        component.set("v.partnerid", partId);
        component.set("v.editMode", true);
    },
    savePartnerProgram: function (component, event, helper) {
        let partId = event.getSource().get("v.title");
        let selectedVal = event.getSource().get("v.value");
        helper.savePartnerProgramforPrimaryPartner(component, event, helper, partId, selectedVal);

    },

    ChangeTechPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
	    /*var selected = !event.getSource().get("v.value");
	    //alert('---PartnerId--'+PartnerId);
	    if(selected){ */
        helper.UpdatePartner(component, event, helper, PartnerId, 'Tech Partner');
	    /*}else{
	        helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Tech Partner');
	    }*/
    },

    ChangeSysIntegratorPrimary: function (component, event, helper) {
        var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'System Integrator');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'System Integrator');
        }
    },

    ChangeDistributorPrimary: function (component, event, helper) {

        var PartnerId = event.getSource().get("v.text");
        var selected = !event.getSource().get("v.value");
        //alert('selected' + selected+'----PartnerId----'+PartnerId);

        //alert('---PartnerId--'+PartnerId);
        if (selected) {
            helper.UpdatePartner(component, event, helper, PartnerId, 'Distributor');
        } else {
            helper.RemovePrimaryPartner(component, event, helper, PartnerId, 'Distributor');
        }
    }
})