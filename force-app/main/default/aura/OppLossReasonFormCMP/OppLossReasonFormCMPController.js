({
    doInit : function(component, event, helper) {
        var StageClosedLost = $A.get("$Label.c.Stage_7_Closed_Lost");
        if(component.get("v.recordId") != '' && component.get("v.recordId") != null){
            helper.getChurnRecordHelper(component, event, helper);
        }
        helper.showSpinner(component, event);
        helper.changedTabHelperMethod(component, event,'section1');
        var validationErrorAction = component.get("c.checkValidationErrors");
        validationErrorAction.setParams({ oppId : component.get("v.oppId") });
        validationErrorAction.setCallback(this, function(validationErrorActionresponse) {
            var state = validationErrorActionresponse.getState();
            if (state == "SUCCESS") {
                var responseFromController = validationErrorActionresponse.getReturnValue();
                if(responseFromController.hasNoErrors){
                    var action = component.get("c.getInitData");
                    action.setParams({ oppId : component.get("v.oppId") });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            var records = response.getReturnValue();
                            component.set("v.initData", records);
                            if(component.get("v.recordId") != '' && component.get("v.recordId") != null){
                                if(records.oppStage == StageClosedLost /*records.oppStage == '11 - Closed Lost' || records.oppStage == '12 - Closed With No Decision'*/){
                                    component.set("v.opportunityStage",records.oppSubStage);
                                    component.set("v.confirmEncloser",records.oppCloser);
                                }
                            }
                            component.set("v.oppType", records.oppType);
                            helper.pickListWrapHelperMethod(component, event, helper);
                            helper.manageSectionHelper(component, event, helper);
                        }
                        else if(state == "ERROR"){
                            var errors = response.getError();   
                            component.set("v.showErrors",true);
                            component.set("v.errorMessage", errors[0].message);
                        }
                        //helper.hideSpinner(component, event);
                    });
                    $A.enqueueAction(action);
                }
                else{
                    component.set("v.showErrors", true);
                    component.set("v.showValidationErrorMsg", true);
                    component.set("v.errorMessage", responseFromController.ErrorMessage);
                    helper.hideSpinner(component, event);
                }
                //var records = response.getReturnValue();
                //component.set("v.initData", records);
                //if(component.get("v.recordId") != '' && component.get("v.recordId") != null){
                    //if(records.oppStage == StageClosedLost /*records.oppStage == '11 - Closed Lost' || records.oppStage == '12 - Closed With No Decision'*/){
                        //component.set("v.opportunityStage",records.oppSubStage);
                        //component.set("v.confirmEncloser",records.oppCloser);
                    //}
                //}
                //component.set("v.oppType", records.oppType);
                //helper.pickListWrapHelperMethod(component, event, helper);
                //helper.manageSectionHelper(component, event, helper);
            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            //helper.hideSpinner(component, event);
        });
        $A.enqueueAction(validationErrorAction);
        
    },
    onclickTab : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var id = selectedItem.dataset.id;
        component.set("v.stageError",false);
        component.set("v.encloserQuestionError",false);
        
        if(id == 'section1'){
            helper.changedTabHelperMethod(component, event, 'section1')
             component.set("v.activeTab",id);
        }
        
        if(id == 'section2'){
            if(component.get("v.activeTab")  == 'section1'){
                var error = helper.validateScreen1Helper(component, event,helper);
                if(component.get("v.section1Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section2');
                    component.set("v.activeTab",'section2');
                    if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                       // helper.SCIListHelperMethod(component, event);
                    }
                }
            }
            if(component.get("v.activeTab")  == 'summary'){
                helper.changedTabHelperMethod(component, event, 'section2');
                component.set("v.activeTab",'section2');
                if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                        //helper.SCIListHelperMethod(component, event);
                }
            }
        }


        if(id == 'summary'){
            if(component.get("v.activeTab") == 'section1'){
                var error = helper.validateScreen1Helper(component, event,helper);
                var error = helper.validateScreen2Helper(component, event,helper);
                if(component.get("v.section1Completed") && component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'summary');
                    component.set("v.activeTab",'summary');
                }
                if(component.get("v.section1Completed") && !component.get("v.section2Completed")) {
                    	helper.changedTabHelperMethod(component, event, 'section2');
                     component.set("v.activeTab",'section2');
                     if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                        //helper.SCIListHelperMethod(component, event);
                    }
                }
            }
            if(component.get("v.activeTab")  == 'section2'){
                var error = helper.validateScreen2Helper(component, event,helper);
                if(component.get("v.section1Completed") && component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'summary');
                    component.set("v.activeTab",'summary');
                }
            }
		}
    },
    toggleSection : function(component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    getSCI : function(component, event, helper) {
    	helper.SCIListHelperMethod(component, event);
    },
    validateScreen1:function(component, event, helper){
        var ret =helper.validateScreen1Helper(component, event,helper);
    },
    nextScreen1:function(component, event, helper){
        //component.set("v.showErrors",false);
        //component.set("v.errorMessage",'');
    	if(!helper.validateScreen1Helper(component, event,helper)){
            helper.changedTabHelperMethod(component, event, 'section2')
            //if(component.get("v.isLossCallConducted") == true){
            if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                //helper.SCIListHelperMethod(component, event);
            }
        }
        else{
            //component.set("v.showErrors",true);
            //component.set("v.errorMessage",'Please fill the all required fields.');
            //helper.scrollTotop(component, event);
            //alert('error');
        }
    },
    nextScreen2:function(component, event, helper){
        //component.set("v.showErrors",false);
        //component.set("v.errorMessage",'');
        // alert(JSON.stringify(component.get("v.SCIList")));
        if(!helper.validateScreen2Helper(component, event,helper)){
            helper.changedTabHelperMethod(component, event, 'summary')
        }
        else{
           //component.set("v.showErrors",true);
            //component.set("v.errorMessage",'Please fill the all required fields.');
            //helper.scrollTotop(component, event);
        }
    },
    save:function(component, event, helper){
        if(!helper.validateSaveHelper(component, event,helper)){
            helper.saveRecordHelper(component, event,helper)
        }
        else{
            
        }        
    },
    redirectToBack:function(component, event, helper){
        //window.open("/"+component.get("v.oppId"),'_top');
        if(component.get("v.custpartowneremails") != null && component.get("v.custpartowneremails") != ''){
            window.open("/apex/Renewal_Notification_Console",'_top');
        }
        else{
            window.open("/"+component.get("v.oppId"),'_top');
        }
    },
    backToScreen1:function(component, event, helper){
        helper.changedTabHelperMethod(component, event, 'section1')
    },
    backToScreen2:function(component, event, helper){
        helper.changedTabHelperMethod(component, event, 'section2')
    },



    LostCallSelected : function(component, event, helper)
    {
        var index = component.get("v.ChurnRecord.Lost_Analysis_Call__c");

        if(index == 'Call Conducted'){
        	helper.SCIListHelperMethod(component, event);
        }
        else{
            component.set("v.SCINumber",'');
        }
    },
    onRadioChange : function(component, event, helper) {
       var selected = event.getSource().get("v.text");
        var records = component.get("v.SCIList");
        var i;
        for(i=0; i<records.length; i++){
            if(records[i].SCIRecord.Id == selected){
                records[i].isChecked = true;
                component.set("v.SCINumber",selected);
            }
            else{
                records[i].isChecked = false;
            }
        }
        component.set("v.SCIList",records);
        //alert(selected);
    }

})