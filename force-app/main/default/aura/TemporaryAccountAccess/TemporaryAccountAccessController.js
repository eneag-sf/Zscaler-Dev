({
    doInit: function(component,event,helper) {
        helper.getAreaList(component,event);
        helper.getManagerList(component,event);
        helper.getUserManagerList(component,event);
        helper.getVacationManagerList(component,event);
        helper.getCoverageHelper(component,event);
        helper.getUserRecordHelper(component,event);
        
        var ddDiv = component.find('ddId');
        $A.util.toggleClass(ddDiv,'slds-is-open');
    },
    changeCoverage: function(component,event,helper) {
        helper.showSpinner(component, event);
        //var selected = component.find("coverageid").get("v.value");
        //component.set("v.coverageType",selected);
        if(component.get("v.coverageType") == ''){
            component.set("v.coverageType",'Temporary Account Access');
            helper.clearTBHCoverageFields(component, event);
            helper.clearVacationCoverageFields(component, event);
        }
        if(component.get("v.coverageType") == 'TBH Coverage'){
            helper.clearVacationCoverageFields(component, event);
        }
        if(component.get("v.coverageType") == 'Vacation Coverage'){
            var records = component.get("v.userRecord");
            if(component.get("v.isRep") == true && records != null && records != ''){
                component.set("v.isRep",true); 
                component.set("v.selectedVacationManager",records.Id);
                component.set("v.selectedVacationManagerLabel",records.Name);
                component.set("v.selectedRemovaVacationManager",records.Id);
                component.set("v.selectedRemovaVacationManagerLabel",records.Name);
            }
            
            helper.clearTBHCoverageFields(component, event);
        }
        //helper.helperGetValuesMethod(component,event);
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        helper.hideSpinner(component, event);
    },
    tabSelected: function(component,event,helper) {
        helper.showSpinner(component, event);
        //helper.helperGetValuesMethod(component,event);
        helper.hideSpinner(component, event);
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(component.get("v.selTabId") == 'tab1'){
            helper.getVacationCoverageListHelper(component,event);
        }
        if(component.get("v.selTabId") == 'tab2'){
            helper.getTBHCoverageCasesHelper(component,event);
        }
        
    },
    dateValidateForHowlong: function(component,event,helper) {
        component.set("v.isHowLongError",false);
        component.set("v.HowLongValidationError",'');
        component.set("v.HowLongValidationErrorMsg",'');
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.howLongDate") != '' && component.get("v.howLongDate") < todayFormattedDate){
            component.set("v.HowLongValidationError" , true);
            component.set("v.HowLongValidationErrorMsg",'Error:Date must be in present or in future..');
        }
        
        var minDate = new Date(); 
        minDate = minDate.setMonth(minDate.getMonth() + 6);
        var sixMonthsDate = new Date(minDate);
        var ddforsixMonths = sixMonthsDate.getDate();
        var mmforsixMonths = sixMonthsDate.getMonth() + 1; //January is 0!
        var yyyyforsixMonths = sixMonthsDate.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(ddforsixMonths < 10){
            ddforsixMonths = '0' + ddforsixMonths;
        } 
        // if month is less then 10, then append 0 before date    
        if(mmforsixMonths < 10){
            mmforsixMonths = '0' + mmforsixMonths;
        }
        
        var sixMonthsFormattedDate = yyyyforsixMonths+'-'+mmforsixMonths+'-'+ddforsixMonths;
        if(component.get("v.howLongDate") != '' && component.get("v.howLongDate") > sixMonthsFormattedDate){
            component.set("v.HowLongValidationError" , true);
            component.set("v.HowLongValidationErrorMsg",'Error:Date must be less than 6 months of future..');
        }

        

    },
    dateValidateForEndDate: function(component,event,helper) {
        component.set("v.isvacationEndDateError",false);
        component.set("v.vacationEndDateValidationError" , false);
        component.set("v.vacationEndDateValidationErrorMsg",'');
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.vacationEndDate") != '' && component.get("v.vacationEndDate") < todayFormattedDate){
            component.set("v.vacationEndDateValidationError" , true);
            component.set("v.vacationEndDateValidationErrorMsg",'Error:Date must be in present or in future..');
        }
        
        var minDate = new Date(); 
        let numWeeks = 4;
		minDate = minDate.setDate(minDate.getDate() + numWeeks * 7);
        var sixMonthsDate = new Date(minDate);
        var ddforsixMonths = sixMonthsDate.getDate();
        var mmforsixMonths = sixMonthsDate.getMonth() + 1; //January is 0!
        var yyyyforsixMonths = sixMonthsDate.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(ddforsixMonths < 10){
            ddforsixMonths = '0' + ddforsixMonths;
        } 
        // if month is less then 10, then append 0 before date    
        if(mmforsixMonths < 10){
            mmforsixMonths = '0' + mmforsixMonths;
        }
        
        var sixMonthsFormattedDate = yyyyforsixMonths+'-'+mmforsixMonths+'-'+ddforsixMonths;
        if(component.get("v.vacationEndDate") != '' && component.get("v.vacationEndDate") > sixMonthsFormattedDate){
            component.set("v.vacationEndDateValidationError" , true);
            component.set("v.vacationEndDateValidationErrorMsg",'Error:Date must be less than 4 weeks of future..');
        }

        

    },
    createTBHCoverage: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateTBHCoverageHelper(component, event)){
            helper.createTBHCoverageHelper(component, event);
        }
    },
    removeTBHAccess: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateremoveTBHAccessHelper(component, event)){
            var records = component.get("v.TBHCoverageCaseList");
            if(records.length>0){
                helper.removeTBHAccessHelper(component, event,'All');
            }
        }
    },
    removeSelectedTBHAccess: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateremoveTBHAccessHelper(component, event)){
            var isSelected = false;
            var records = component.get("v.TBHCoverageCaseList");
            for (var i = 0; i < records.length; i++) {
                if(records[i].isSelected == true){
                    isSelected = true;
                }
            }
            if(records.length>0){
                if(isSelected == true){
                	helper.removeTBHAccessHelper(component, event,'Selected');
                }
                else{
                    component.set("v.showError",true);
                    component.set("v.errorMessage",'Please select at least one coverage.');
                    helper.scrollTotop(component, event);
                }
            }
        }
    },
    removeVacationAccess: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateremoveVacationccessHelper(component, event)){
            var records = component.get("v.VacationCoverageCaseList");
            if(records.length>0){
                helper.removeVacationAccessHelper(component, event,'All');
            }
        }
    },
    removeSelectedVacationAccess: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateremoveVacationccessHelper(component, event)){
            var isSelected = false;
            var records = component.get("v.VacationCoverageCaseList");
            for (var i = 0; i < records.length; i++) {
                if(records[i].isSelected == true){
                    isSelected = true;
                }
            }
            if(records.length>0){
                if(isSelected == true){
                	helper.removeVacationAccessHelper(component, event,'Selected');
                }
                else{
                    component.set("v.showError",true);
                    component.set("v.errorMessage",'Please select at least one coverage.');
                    helper.scrollTotop(component, event);
                }
            }
        }
    },
    createVacationCoverage: function(component,event,helper) {
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        if(!helper.validateVacationCoverageHelper(component, event)){
            helper.createVacationCoverageHelper(component, event);
        }
    },
    closeMenu : function(component, event, helper) {
        var comboParentDiv = document.getElementById('combo-parent-div');
        comboParentDiv.classList.remove('slds-is-open');
    },
    toggleVisibility : function(component, event, helper)
    {
        //var RelatedTo=component.get("v.RelatedTo");
        //var whichOne = event.target.id;
        var selectedSection = event.currentTarget;
        var whichOne = selectedSection.dataset.name;

        var findId;
        if(whichOne == 'combobox-area'){
            findId = 'areaId';
        }
        if(whichOne == 'combobox-Territorie'){
            findId = 'TerritorieId';
        }
        if(whichOne == 'combobox-Manager'){
            findId = 'ManagerId';
        }
        if(whichOne == 'combobox-removalTBH'){
            findId = 'removalTBHId';
        }
        if(whichOne == 'combobox-whovacation'){
            findId = 'whovacationId';
        }
        if(whichOne == 'combobox-whoCovering'){
            findId = 'whoCoveringId';
        }
        if(whichOne == 'combobox-removalVacation'){
            findId = 'removalVacationId';
        }
        var RelatedTo=document.getElementById(whichOne).value;
        if (RelatedTo==null || RelatedTo.length==0)
        {
            helper.clearValuesHelper(component,event,whichOne);
            var ddDiv = component.find(findId);
            $A.util.toggleClass(ddDiv,'slds-is-open');
        }
    },
    
    blurtoggleVisibility : function(component, event, helper)
    {
        var whichOne = event.target.id;
        var findId;
        if(whichOne == 'combobox-area'){
            findId = 'areaId';
        }
        if(whichOne == 'combobox-Territorie'){
            findId = 'TerritorieId';
        }
        if(whichOne == 'combobox-Manager'){
            findId = 'ManagerId';
        }
        if(whichOne == 'combobox-removalTBH'){
            findId = 'removalTBHId';
        }
        if(whichOne == 'combobox-whovacation'){
            findId = 'whovacationId';
        }
        if(whichOne == 'combobox-whoCovering'){
            findId = 'whoCoveringId';
        }
        if(whichOne == 'combobox-removalVacation'){
            findId = 'removalVacationId';
        }
        var RelatedTo=document.getElementById(whichOne).value;
        console.log(component.get("v.selectedArea")+'-----------'+RelatedTo);
        if (RelatedTo==null || RelatedTo.length==0)
        {
            helper.clearValuesHelper(component,event,whichOne);
            /*var ddDiv = component.find(findId);
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.toggleClass(ddDiv,'slds-is-open');
                }), 300);*/
        }
    },

    itemSelected : function(component, event, helper)
    {

        var findId;
        var selectedSection = event.currentTarget;
        var index = selectedSection.dataset.id;
        var label = selectedSection.dataset.index;
        var whichOne = selectedSection.dataset.name;
        if(whichOne == 'combobox-area'){
            findId = 'areaId';
            component.set("v.selectedArea",index);
            helper.getTerritorieList(component, event);
        }
        if(whichOne == 'combobox-Territorie'){
            findId = 'TerritorieId';
            component.set("v.selectedTBHTerritorie",index);
            component.set("v.selectedTBHTerritorieLabel",label);
        }
        if(whichOne == 'combobox-Manager'){
            findId = 'ManagerId';
            component.set("v.selectedTBHManager",index);
            component.set("v.selectedTBHManagerLabel",label);
        }
        if(whichOne == 'combobox-removalTBH'){
            findId = 'removalTBHId';
            component.set("v.selectedRemovaTBHManager",index);
            component.set("v.selectedRemovaTBHManagerLabel",label);
        }
        if(whichOne == 'combobox-whovacation'){
            findId = 'whovacationId';
            component.set("v.selectedVacationManager",index);
            component.set("v.selectedVacationManagerLabel",label);
        }
        if(whichOne == 'combobox-whoCovering'){
            findId = 'whoCoveringId';
            component.set("v.selectedCoveringManager",index);
            component.set("v.selectedCoveringManagerLabel",label);
        }
        if(whichOne == 'combobox-removalVacation'){
            findId = 'removalVacationId';
            component.set("v.selectedRemovaVacationManager",index);
            component.set("v.selectedRemovaVacationManagerLabel",label);
        }
        var RelatedTo=document.getElementById(whichOne);

        if(!RelatedTo.classList.contains('slds-is-open')){
            var ddDiv = component.find(findId);
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.toggleClass(ddDiv,'slds-is-open');
                }), 300);
        }
        
        helper.clearSuccessMessageHelper(component, event);
        helper.clearErrorMessageHelper(component, event);
        
        
        if(whichOne == 'combobox-area'){
            component.set("v.selectedTBHTerritorie",'')
            component.set("v.selectedTBHTerritorieLabel",'')
        }
        if(whichOne == 'combobox-removalTBH'){
            helper.getTBHCoverageCasesHelper(component,event);
        }
        if(whichOne == 'combobox-Territorie'){
            helper.getTBHCoverageListHelper(component,event);
        }
        if(whichOne == 'combobox-whovacation' || whichOne == 'combobox-whoCovering'){
            component.set("v.isvacationFieldsSame",false);
            var CoveringField = component.find("combobox-whoCovering");
            var CoveringValue = component.get("v.selectedCoveringManager");
            CoveringField.set("v.errors", [{message: null}]);
            $A.util.removeClass(CoveringField, 'slds-has-error');
            if(component.get("v.selectedVacationManager") != null && component.get("v.selectedVacationManager") != ''){
                helper.getVacationCoverageListHelper(component,event);
            }
            if(component.get("v.selectedVacationManager") == component.get("v.selectedCoveringManager")){
                $A.util.addClass(CoveringField, 'slds-has-error');
                CoveringField.set("v.errors", [{message: "Vacation manager and covering managers can't be same."}]);
                component.set("v.isvacationFieldsSame",true);
                
                
            }else{
                CoveringField.set("v.errors", [{message: null}]);
                $A.util.removeClass(CoveringField, 'slds-has-error');
            }
            
        }
        if(whichOne == 'combobox-removalVacation'){
            helper.getVacationCoverageCasesHelper(component,event);
        }
    },
    serverCall : function(component, event, helper) { 
        var target = event.target;  
        var RelatedTo = target.value; 
        var input, filter, ul, li, a, i, txtValue;
        var whichOne = event.target.id;
        var findId;
        if(whichOne == 'combobox-area'){
            findId = 'areaId';
            ul = document.getElementById("ulDropArea");
        }
        if(whichOne == 'combobox-Territorie'){
            findId = 'TerritorieId';
            ul = document.getElementById("ulDropTerritorie");
        }
        if(whichOne == 'combobox-Manager'){
            findId = 'ManagerId';
            ul = document.getElementById("ulDropManager");
        }
        if(whichOne == 'combobox-removalTBH'){
            findId = 'removalTBHId';
            ul = document.getElementById("ulDropremovalTBH");
        }
        if(whichOne == 'combobox-whovacation'){
            findId = 'whovacationId';
            ul = document.getElementById("ulDropwhovacation");
        }
        if(whichOne == 'combobox-whoCovering'){
            findId = 'whoCoveringId';
			ul = document.getElementById("ulDropwhoCovering");
        }
        if(whichOne == 'combobox-removalVacation'){
            findId = 'removalVacationId';
            ul = document.getElementById("ulDropremovalVacation");
        }
        var ddDiv = component.find(findId);
        $A.util.addClass(ddDiv,'slds-is-open');

        
        filter = RelatedTo.toUpperCase();
        li = ul.getElementsByTagName("li");
        for (i = 0; i < li.length; i++) {
            a = li[i].getElementsByTagName("span")[0];
            txtValue = a.textContent || a.innerText;
            if (txtValue.toUpperCase().indexOf(filter) > -1) {
                li[i].style.display = "";
            } else {
                li[i].style.display = "none";
            }
        }

    }
    
    
    
})