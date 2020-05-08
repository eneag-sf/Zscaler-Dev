({
    showSpinner: function(component, event) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    getUserRecordHelper : function(component,event) {
        this.showSpinner(component, event);
        var action = component.get("c.getCurrentUserRecord");
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.userRecord",records);
            if(records.Level__c == 'Rep'){
                component.set("v.isRep",true); 
                component.set("v.selectedVacationManager",records.Id);
                component.set("v.selectedVacationManagerLabel",records.Name);
                component.set("v.selectedRemovaVacationManager",records.Id);
                component.set("v.selectedRemovaVacationManagerLabel",records.Name);
            }
            this.getVacationCoverageListHelper(component,event);
            this.getVacationCoverageCasesHelper(component,event);
            
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    getCoverageHelper : function(component,event) {
        this.showSpinner(component, event);
        var action = component.get("c.getCoverageAccessFromProfile");
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            
            if(records == 'Both'){
                component.set("v.isAccessCoverage", true);
               // component.set("v.coverageType", 'TBH Coverage');
            }
            if(records == 'TBH Coverage'){
                component.set("v.isAccessCoverage", false);
                component.set("v.coverageType", 'TBH Coverage');
            }
            if(records == 'Vacation Coverage'){
                component.set("v.isAccessCoverage", false);
                component.set("v.coverageType", 'Vacation Coverage');
            }
            
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    getAreaList : function(component,event) {
        this.showSpinner(component, event);
        var action = component.get("c.getAreaListWrap");
        
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.areaList", records);
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    getTerritorieList: function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getTerritorieWrap");
        action.setParams({
            selectedArea : component.get("v.selectedArea")
        });
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.territoriesList", records);
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    getManagerList: function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getManagerWrap");
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.managerList", records);
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    getUserManagerList: function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getUserManagerWrap");
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.userManagerList", records);
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    getVacationManagerList: function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getVacationManagerWrap");
        action.setCallback(this, function(result){
            var records = result.getReturnValue();
            //alert(JSON.stringify(records));
            component.set("v.vacationManagerList", records);
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    createTBHCoverageHelper : function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.TBHCoverageCreate");
        action.setParams({
            selectedArea : component.get("v.selectedArea"),
            selectedTBHTerritorie : component.get("v.selectedTBHTerritorie"),
            selectedTBHTerritorieLabel : component.get("v.selectedTBHTerritorieLabel"),
            selectedTBHManager : component.get("v.selectedTBHManager"),
            selectedTBHManagerLabel : component.get("v.selectedTBHManagerLabel"),
            howLongDate : component.get("v.howLongDate")
        });
        
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                //alert(JSON.stringify(records));
                if(records.status == 'SUCCESS'){
                    component.set("v.showSuccess",true);
                    component.set("v.successMessage",records.message);
                    //this.clearTBHCoverageValuesHelper(component, event);
                    this.getTBHCoverageListHelper(component,event);
                }
                else{
                    component.set("v.showError",true);
                    component.set("v.errorMessage",records.message);
                }
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
           }
            this.hideSpinner(component, event);
            this.scrollTotop(component, event);
        });
        $A.enqueueAction(action);
    },
    clearValuesHelper : function(component,event,whichOne){
        if(whichOne == 'combobox-area'){
            component.set("v.selectedArea",'');
        }
        if(whichOne == 'combobox-Territorie'){
            component.set("v.selectedTBHTerritorie",'');
            component.set("v.selectedTBHTerritorieLabel",'');
        }
        if(whichOne == 'combobox-Manager'){
            component.set("v.selectedTBHManager",'');
            component.set("v.selectedTBHManagerLabel",'');
        }
        if(whichOne == 'combobox-removalTBH'){
            component.set("v.selectedRemovaTBHManager",'');
            component.set("v.selectedRemovaTBHManagerLabel",'');
        }
        if(whichOne == 'combobox-whovacation'){
            component.set("v.selectedVacationManager",'');
            component.set("v.selectedVacationManagerLabel",'');
        }
        if(whichOne == 'combobox-whoCovering'){
            component.set("v.selectedCoveringManager",'');
            component.set("v.selectedCoveringManagerLabel",'');
        }
    },
    validateTBHCoverageHelper : function(component,event){
        component.set("v.isAreaError",false);
        component.set("v.isTerritorieError",false);
        component.set("v.isManagerError",false);
        component.set("v.isHowLongError",false);
        
        var returnvalue = false;
        var areaField = component.find("combobox-area");
        var areaValue = component.get("v.selectedArea");
		if(!$A.util.isEmpty(areaValue)){ 
            areaField.set("v.errors", [{message: null}]);
            $A.util.removeClass(areaField, 'slds-has-error');
        }
        else{
            $A.util.addClass(areaField, 'slds-has-error');
            areaField.set("v.errors", [{message: "Please select the area value."}]);
            returnvalue = true;
            component.set("v.isAreaError",true);
        }

        var territorieField = component.find("combobox-Territorie");
        var territorieValue = component.get("v.selectedTBHTerritorie");
        if(!$A.util.isEmpty(territorieValue)){ 
            territorieField.set("v.errors", [{message: null}]);
            $A.util.removeClass(territorieField, 'slds-has-error');
        }
        else{
            $A.util.addClass(territorieField, 'slds-has-error');
            areaField.set("v.errors", [{message: "Please select the territorie value."}]);
            returnvalue = true;
            component.set("v.isTerritorieError",true);
        }
        
		var managerField = component.find("combobox-Manager");
        var managerValue = component.get("v.selectedTBHManager");
        if(!$A.util.isEmpty(managerValue)){ 
			managerField.set("v.errors", [{message: null}]);
            $A.util.removeClass(managerField, 'slds-has-error');
        }
        else{
			$A.util.addClass(managerField, 'slds-has-error');
            managerField.set("v.errors", [{message: "Please select the manager value."}]);
            returnvalue = true;
            component.set("v.isManagerError",true);
        } 
        
        var howLongField = component.find("howLongdate");
        var howLongValue = component.get("v.howLongDate");
        if(!$A.util.isEmpty(howLongValue)){ 
			//howLongField.set("v.errors", [{message: null}]);
            //$A.util.removeClass(howLongField, 'slds-has-error');
        }
        else{
			//$A.util.addClass(howLongField, 'slds-has-error');
            //howLongField.set("v.errors", [{message: "Please select the date value."}]);
            returnvalue = true;
            component.set("v.isHowLongError",true);
        } 
        if(component.get("v.HowLongValidationError") == true){
           returnvalue = true;
        }
        return returnvalue;
    },
    validateremoveTBHAccessHelper : function(component,event){
        component.set("v.isRemovaTBHManagerError",false);
        
        var returnvalue = false;
        var removalTBHField = component.find("combobox-removalTBH");
        var removalTBHValue = component.get("v.selectedRemovaTBHManager");
		if(!$A.util.isEmpty(removalTBHValue)){ 
            removalTBHField.set("v.errors", [{message: null}]);
            $A.util.removeClass(removalTBHField, 'slds-has-error');
        }
        else{
            $A.util.addClass(removalTBHField, 'slds-has-error');
            removalTBHField.set("v.errors", [{message: "Please select the Removal of TBH Access."}]);
            returnvalue = true;
            component.set("v.isRemovaTBHManagerError",true);
        }

        return returnvalue;
    },
    removeTBHAccessHelper : function(component,event,TBHtype){
        this.showSpinner(component, event);
        var action = component.get("c.TBHCoverageRemove");
        action.setParams({
            selectedRemovaTBHManager : component.get("v.selectedRemovaTBHManager"),
            TBHtype:TBHtype,
            JsonString:JSON.stringify(component.get("v.TBHCoverageCaseList"))
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                var message = 'Removed TBH Coverage successfully.';
                component.set("v.showSuccess",true);
                component.set("v.successMessage",'Removed TBH Coverage successfully.');
                //alert(JSON.stringify(records));
                //component.set("v.selectedRemovaTBHManager",'');
                //component.set("v.selectedRemovaTBHManagerLabel",'');
                this.getTBHCoverageCasesHelper(component,event);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
            this.scrollTotop(component, event);
        });
        $A.enqueueAction(action);
    },
    removeVacationAccessHelper : function(component,event,TBHtype){
        this.showSpinner(component, event);
        var action = component.get("c.VacationCoverageRemove");
        action.setParams({
            selectedRemovaVacationManager : component.get("v.selectedRemovaVacationManager"),
            selectType:TBHtype,
            JsonString:JSON.stringify(component.get("v.VacationCoverageCaseList"))
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                var message = 'Removed Vacation Coverage successfully.';
                component.set("v.showSuccess",true);
                component.set("v.successMessage",'Removed Vacation Coverage successfully.');
                this.getVacationCoverageCasesHelper(component,event);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
            this.scrollTotop(component, event);
        });
        $A.enqueueAction(action);
    },    
    
    validateremoveVacationccessHelper : function(component,event){
        component.set("v.isRemovaVacationManagerError",false);
        
        var returnvalue = false;
        if(component.get("v.isRep") == false){
            var removalTBHField = component.find("combobox-removalVacation");
            var removalTBHValue = component.get("v.selectedRemovaVacationManager");
            if(!$A.util.isEmpty(removalTBHValue)){ 
                removalTBHField.set("v.errors", [{message: null}]);
                $A.util.removeClass(removalTBHField, 'slds-has-error');
            }
            else{
                $A.util.addClass(removalTBHField, 'slds-has-error');
                removalTBHField.set("v.errors", [{message: "Please select the Removal of Vacation Access."}]);
                returnvalue = true;
                component.set("v.isRemovaVacationManagerError",true);
            }
        }

        return returnvalue;
    },
    
    validateVacationCoverageHelper : function(component,event){
        component.set("v.iswhovacationError",false);
        component.set("v.iswhoCoveringError",false);
        component.set("v.isvacationEndDateError",false);
        component.set("v.isvacationFieldsSame",false);
        
        var returnvalue = false;
        if(component.get("v.isRep") == false){
            var vacationField = component.find("combobox-whovacation");
            var vacationValue = component.get("v.selectedVacationManager");
            if(!$A.util.isEmpty(vacationValue)){ 
                vacationField.set("v.errors", [{message: null}]);
                $A.util.removeClass(vacationField, 'slds-has-error');
            }
            else{
                $A.util.addClass(vacationField, 'slds-has-error');
                vacationField.set("v.errors", [{message: "Please select the Vacation value."}]);
                returnvalue = true;
                component.set("v.iswhovacationError",true);
            }
        }

        var CoveringField = component.find("combobox-whoCovering");
        var CoveringValue = component.get("v.selectedCoveringManager");
        if(!$A.util.isEmpty(CoveringValue)){ 
            CoveringField.set("v.errors", [{message: null}]);
            $A.util.removeClass(CoveringField, 'slds-has-error');
        }
        else{
            $A.util.addClass(CoveringField, 'slds-has-error');
            CoveringField.set("v.errors", [{message: "Please select the who Covering value."}]);
            returnvalue = true;
            component.set("v.iswhoCoveringError",true);
        }
        
        if(component.get("v.selectedVacationManager") != null && component.get("v.selectedVacationManager") != '' && component.get("v.selectedCoveringManager") != null && component.get("v.selectedCoveringManager") != ''){
            if(component.get("v.selectedVacationManager") == component.get("v.selectedCoveringManager")){
                $A.util.addClass(CoveringField, 'slds-has-error');
                CoveringField.set("v.errors", [{message: "Vacation manager and covering managers can't be same."}]);
                component.set("v.isvacationFieldsSame",true);
                returnvalue = true;
                
            }else{
                CoveringField.set("v.errors", [{message: null}]);
                $A.util.removeClass(CoveringField, 'slds-has-error');
            }
        }
        
        
        var vacationEndDateField = component.find("vacationEndDate");
        var vacationEndDateValue = component.get("v.vacationEndDate");
        if(!$A.util.isEmpty(vacationEndDateValue)){ 
			//howLongField.set("v.errors", [{message: null}]);
            //$A.util.removeClass(howLongField, 'slds-has-error');
        }
        else{
			//$A.util.addClass(howLongField, 'slds-has-error');
            //howLongField.set("v.errors", [{message: "Please select the date value."}]);
            returnvalue = true;
            component.set("v.isvacationEndDateError",true);
        } 
        
        if(component.get("v.vacationEndDateValidationError") == true){
            returnvalue = true;
        }
        
        return returnvalue;
  
    },
    
    createVacationCoverageHelper : function(component,event){
         this.showSpinner(component, event);
        var action = component.get("c.VacationCoverageCreate");
        action.setParams({
            selectedVacationManager : component.get("v.selectedVacationManager"),
            selectedCoveringManager : component.get("v.selectedCoveringManager"),
            selectedVacationManagerLabel : component.get("v.selectedVacationManagerLabel"),
            selectedCoveringManagerLabel : component.get("v.selectedCoveringManagerLabel"),
            vacationEndDate : component.get("v.vacationEndDate"),
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                //alert(JSON.stringify(records));
                if(records.status == 'SUCCESS'){
                    component.set("v.showSuccess",true);
                    component.set("v.successMessage",records.message);
                    //this.clearTBHCoverageValuesHelper(component, event);
                    this.getVacationCoverageListHelper(component,event);
                }
                else{
                    component.set("v.showError",true);
                    component.set("v.errorMessage",records.message);
                }
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
            this.scrollTotop(component, event);
        });
        $A.enqueueAction(action);        
    },
    
    clearErrorMessageHelper : function(component,event){
        component.set("v.showError",false);
        component.set("v.errorMessage",'');
        /*window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showError",false);
                component.set("v.errorMessage",'');
            }), 3000);*/
    },
    clearSuccessMessageHelper : function(component,event){
        component.set("v.showSuccess",false);
        component.set("v.successMessage",'');
        /*window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSuccess",false);
                component.set("v.successMessage",'');
            }), 3000);*/
    },
    scrollTotop: function(component, event){
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    clearTBHCoverageValuesHelper : function(component,event){
			component.set("v.selectedArea",'');
 			component.set("v.selectedTBHTerritorie",'');
            component.set("v.selectedTBHTerritorieLabel",'');
			component.set("v.selectedTBHManager",'');
            component.set("v.selectedTBHManagerLabel",'');
        	component.set("v.howLongDate",'');
            component.set("v.TBHCoverageList",[]);
        
     },
        
    clearTBHCoverageFields : function(component, event, helper){
        component.set("v.selectedArea",'');
        component.set("v.selectedTBHTerritorie",'');
        component.set("v.selectedTBHTerritorieLabel",'');
        component.set("v.selectedTBHManager",'');
        component.set("v.selectedTBHManagerLabel",'');
        component.set("v.selectedRemovaTBHManager",'');
        component.set("v.selectedRemovaTBHManagerLabel",'');
        component.set("v.howLongDate",'');
        component.set("v.TBHCoverageList",[]);
        component.set("v.TBHCoverageCaseList",[]);
        component.set("v.isAreaError",false);
        component.set("v.isTerritorieError",false);
        component.set("v.isManagerError",false);
        component.set("v.isHowLongError",false);
        component.set("v.isRemovaTBHManagerError",false);
        
    },
    clearVacationCoverageFields : function(component, event, helper){
        component.set("v.selectedVacationManager",'');
        component.set("v.selectedVacationManagerLabel",'');
        component.set("v.selectedCoveringManager",'');
        component.set("v.selectedCoveringManagerLabel",'');
        component.set("v.selectedRemovaVacationManager",'');
        component.set("v.selectedRemovaVacationManagerLabel",'');
        component.set("v.vacationEndDate",'');
        component.set("v.iswhovacationError",false);
        component.set("v.iswhoCoveringError",false);
        component.set("v.isvacationEndDateError",false);
        component.set("v.VacationCoverageList",[]);
        
        
    },
    getTBHCoverageCasesHelper : function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getTBHCases");
        action.setParams({
            selectedRemovaTBHManager : component.get("v.selectedRemovaTBHManager")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                component.set("v.TBHCoverageCaseList",records);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);  
    },
    getTBHCoverageListHelper : function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getTBHCoverageList");
        action.setParams({
            selectedTBHTerritorie : component.get("v.selectedTBHTerritorie")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                //alert(JSON.stringify(records));
                component.set("v.TBHCoverageList",records);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);     
    },
    getVacationCoverageListHelper : function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getVacationCoverageList");
        action.setParams({
            selectedVacationManager : component.get("v.selectedVacationManager"),
            selectedCoveringManager : component.get("v.selectedCoveringManager"),
            isRep : component.get("v.isRep")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                component.set("v.VacationCoverageList",records);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);     
    },
    getVacationCoverageCasesHelper: function(component,event){
        this.showSpinner(component, event);
        var action = component.get("c.getVacationCases");
        action.setParams({
            selectedRemovaVacationManager : component.get("v.selectedRemovaVacationManager"),
            isRep : component.get("v.isRep")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if (state == "SUCCESS") {
                var records = result.getReturnValue();
                component.set("v.VacationCoverageCaseList",records);
            }
            else if(state == "ERROR"){
                var errors = result.getError();                       
                component.set("v.showError",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);  
    },
 
})