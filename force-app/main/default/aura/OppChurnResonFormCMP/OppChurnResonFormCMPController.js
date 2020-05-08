({
    doInit : function(component, event, helper) {
        if(component.get("v.recordId") != '' && component.get("v.recordId") != null){
            helper.getChurnRecordHelper(component, event, helper);
        }
        helper.showSpinner(component, event);
        helper.changedTabHelperMethod(component, event,'section1');
        var action = component.get("c.getInitData");
        action.setParams({ oppId : component.get("v.oppId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var records = response.getReturnValue();
                component.set("v.initData", records);
                if(component.get("v.recordId") != '' && component.get("v.recordId") != null){
                    if(records.oppStage == '11 - Closed Lost' || records.oppStage == '12 - Closed With No Decision'){
                        component.set("v.opportunityStage", records.oppStage);
                        component.set("v.confirmEncloser", records.oppCloser);
                    }
                }
                component.set("v.oppType", records.oppType);
                helper.pickListWrapHelperMethod(component, event, helper);
                helper.manageSectionHelper(component, event, helper);
            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            //helper.hideSpinner(component, event);
        });
        $A.enqueueAction(action); 
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
                }
            }
            if(component.get("v.activeTab")  == 'section3'){
                helper.changedTabHelperMethod(component, event, 'section2');
                component.set("v.activeTab",'section2');
            }
            
            if(component.get("v.activeTab")  == 'summary'){
                helper.changedTabHelperMethod(component, event, 'section2');
                component.set("v.activeTab",'section2');
            }
        }
        if(id == 'section3'){
            if(component.get("v.activeTab")  == 'section1'){
                var error = helper.validateScreen1Helper(component, event,helper);
                if(component.get("v.section1Completed")){
                var error1 = helper.validateScreen2Helper(component, event,helper);
                }
                if(component.get("v.section1Completed") && component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section3');
                    component.set("v.activeTab",'section3');
                    if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                       // helper.SCIListHelperMethod(component, event);
                    }
                }
                if(component.get("v.section1Completed") && !component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section2');
                    component.set("v.activeTab",'section2');
                }
            }
            if(component.get("v.activeTab")  == 'section2'){
                var error1 = helper.validateScreen2Helper(component, event,helper);
                if(component.get("v.section1Completed") && component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section3');
                    component.set("v.activeTab",'section3');
                    if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                        //helper.SCIListHelperMethod(component, event);
                    }
                }
            }
            if(component.get("v.activeTab")  == 'summary'){
                helper.changedTabHelperMethod(component, event, 'section3');
                component.set("v.activeTab",'section3');
                if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                    //helper.SCIListHelperMethod(component, event);
                }
            }
            
        }
        
        
        if(id == 'summary'){
            if(component.get("v.activeTab") == 'section1'){
                var error = helper.validateScreen1Helper(component, event,helper);
                if(component.get("v.section1Completed")){
                    var error1 = helper.validateScreen2Helper(component, event,helper);
                }
                if(component.get("v.section2Completed")){
                var error2 = helper.validateScreen3Helper(component, event,helper);
                }

                if(component.get("v.section1Completed") && component.get("v.section2Completed") && component.get("v.section3Completed")) {
                    helper.changedTabHelperMethod(component, event, 'summary');
                    component.set("v.activeTab",'summary');
                }
                if(component.get("v.section1Completed") && !component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section2');
                    component.set("v.activeTab",'section2');
                }
                if(component.get("v.section1Completed") && component.get("v.section2Completed") && !component.get("v.section3Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section3');
                    component.set("v.activeTab",'section3');
                    if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                       // helper.SCIListHelperMethod(component, event);
                    }
                }
                
            }
            if(component.get("v.activeTab")  == 'section2'){
                var error = helper.validateScreen2Helper(component, event,helper);
                if(component.get("v.section2Completed")){
                var error2 = helper.validateScreen3Helper(component, event,helper);
                }
                if(component.get("v.section1Completed") && component.get("v.section2Completed") && component.get("v.section3Completed")) {
                    helper.changedTabHelperMethod(component, event, 'summary');
                    component.set("v.activeTab",'summary');
                }
                if(component.get("v.section1Completed") && !component.get("v.section2Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section2');
                    component.set("v.activeTab",'section2');
                }
                if(component.get("v.section1Completed") && component.get("v.section2Completed") && !component.get("v.section3Completed")) {
                    helper.changedTabHelperMethod(component, event, 'section3');
                    component.set("v.activeTab",'section3');
                    if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                        //helper.SCIListHelperMethod(component, event);
                    }
                }
            }
            if(component.get("v.activeTab")  == 'section3'){
                var error2 = helper.validateScreen3Helper(component, event,helper);
                if(component.get("v.section1Completed") && component.get("v.section2Completed") && component.get("v.section3Completed")) {
                    helper.changedTabHelperMethod(component, event, 'summary');
                    component.set("v.activeTab",'summary');
                }
            }
            if(component.get("v.activeTab")  == 'section3'){
                // helper.SCIListHelperMethod(component, event);
            }
            
        }
        
    },
    getSCI : function(component, event, helper) {
    	helper.SCIListHelperMethod(component, event);
    },
    redirectToBack:function(component, event, helper){
        window.open("/"+component.get("v.oppId"),'_top');
    },
    nextScreen1:function(component, event, helper){
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        if(!helper.validateScreen1Helper(component, event,helper)){
            helper.changedTabHelperMethod(component, event, 'section2')
        }
        else{
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            helper.scrollTotop(component, event);
        }
    },
    nextScreen2:function(component, event, helper){
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        if(!helper.validateScreen2Helper(component, event,helper)){
            helper.changedTabHelperMethod(component, event, 'section3')
            //if(component.get("v.isLossCallConducted") == true){
            
            if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
                //helper.SCIListHelperMethod(component, event);
            }
        }
        else{
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            helper.scrollTotop(component, event);
        }
    },
    nextScreen3:function(component, event, helper){
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        if(!helper.validateScreen3Helper(component, event,helper)){
            helper.changedTabHelperMethod(component, event, 'summary')
            
        }
        else{
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            helper.scrollTotop(component, event);
        }
    },
    save:function(component, event, helper){
        if(!helper.validateSaveHelper(component, event,helper)){
            helper.saveRecordHelper(component, event,helper)
        }
        else{
            
        }       
    },
    backToScreen1:function(component, event, helper){
        helper.changedTabHelperMethod(component, event, 'section1')
    },
    backToScreen2:function(component, event, helper){
        helper.changedTabHelperMethod(component, event, 'section2')
    },
    backToScreen3:function(component, event, helper){
        helper.changedTabHelperMethod(component, event, 'section3')
    },
    
    LostCallSelected : function(component, event, helper)
    {
        var index = component.get("v.ChurnRecord.Lost_Analysis_Call__c");

        if(index == 'Call Conducted'){
        	helper.SCIListHelperMethod(component, event);
        }
        else{
            //component.set("v.SCINumber",'');
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
                // alert('dsd'+selected);
            }
            else{
                records[i].isChecked = false;
            }
        }
        component.set("v.SCIList",records);
        //alert(selected);
    }
    
})