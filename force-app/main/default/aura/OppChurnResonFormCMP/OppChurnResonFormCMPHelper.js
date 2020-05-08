({
    showSpinner: function(component, event) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    changedTabHelperMethod : function(component, event, tabId) {
        this.showSpinner(component, event);
        component.set("v.section1",false);
        component.set("v.section2",false);
        component.set("v.section3",false);
        component.set("v.summary",false);
        component.set("v.isSubmit",false);
        
        if(tabId == 'section1'){
            component.set("v.section1",true);
            var section1 = component.find('section1');
            var section2 = component.find('section2');
            var section3 = component.find('section3');
            var summary = component.find('summary');
            
            $A.util.removeClass(section1, 'slds-is-complete');
            $A.util.addClass(section1, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.removeClass(section2, 'slds-is-complete slds-is-active slds-is-current');
            //$A.util.addClass(section2, 'slds-is-incomplete');
            if(component.get("v.section2Completed")){
                $A.util.addClass(section2, 'slds-is-complete');
            }
            else{
                $A.util.addClass(section2, 'slds-is-incomplete');
            }
            
            $A.util.removeClass(section3, 'slds-is-complete slds-is-active slds-is-current');
            $A.util.addClass(section3, 'slds-is-incomplete');
            $A.util.removeClass(summary, 'slds-is-complete slds-is-active slds-is-current');
            $A.util.addClass(summary, 'slds-is-incomplete');
        }
        if(tabId == 'section2'){
            component.set("v.section2",true);
            var section1 = component.find('section1');
            var section2 = component.find('section2');
            var section3 = component.find('section3');
            var summary = component.find('summary');
            
            $A.util.addClass(section1, 'slds-is-complete');
            $A.util.removeClass(section1, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(section2, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.removeClass(section2, 'slds-is-complete');
            $A.util.removeClass(section3, 'slds-is-complete slds-is-active slds-is-current');
            //$A.util.addClass(section3, 'slds-is-incomplete');
            if(component.get("v.section3Completed")){
                $A.util.addClass(section2, 'slds-is-complete');
            }
            else{
                $A.util.addClass(section2, 'slds-is-incomplete');
            }
            $A.util.removeClass(summary, 'slds-is-complete slds-is-active slds-is-current');
            $A.util.addClass(summary, 'slds-is-incomplete');
            
        }
        if(tabId == 'section3'){
            
            component.set("v.section3",true);
            var section1 = component.find('section1');
            var section2 = component.find('section2');
            var section3 = component.find('section3');
            var summary = component.find('summary');
            
            $A.util.addClass(section1, 'slds-is-complete');
            $A.util.removeClass(section1, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(section2, 'slds-is-complete');
            $A.util.removeClass(section2, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(section3, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.removeClass(section3, 'slds-is-complete');
            $A.util.removeClass(summary, 'slds-is-complete slds-is-active slds-is-current');
            $A.util.addClass(summary, 'slds-is-incomplete');
            
            var index = component.get("v.ChurnRecord.Lost_Analysis_Call__c");
            if(index == 'Call Conducted'){
                // component.set("v.SCINumber",component.get("v.ChurnRecord.SCINumber__c"));
            	this.SCIListHelperMethod(component, event);
            }
            else{
                //component.set("v.SCINumber",'');
            }


            

        }
        if(tabId == 'summary'){
            component.set("v.section1", true);
            component.set("v.section2", true);
            component.set("v.section3", true);
            component.set("v.summary", true);
            component.set("v.isSubmit",true);
            var section1 = component.find('section1');
            var section2 = component.find('section2');
            var section3 = component.find('section3');
            var summary = component.find('summary');
            
            $A.util.addClass(section1, 'slds-is-complete');
            $A.util.removeClass(section1, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(section2, 'slds-is-complete');
            $A.util.removeClass(section2, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(section3, 'slds-is-complete');
            $A.util.removeClass(section3, 'slds-is-incomplete slds-is-active slds-is-current');
            $A.util.addClass(summary, 'slds-is-incomplete  slds-is-active slds-is-current');
            $A.util.removeClass(summary, 'slds-is-complete');
            
        }
        
        this.hideSpinner(component, event);
        this.scrollTotop(component, event);
    },
    pickListWrapHelperMethod : function(component, event, helper) {
        this.showSpinner(component, event);
        var action = component.get("c.getPickListData");
        action.setParams({ oppId : component.get("v.oppId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var records = response.getReturnValue();
                component.set("v.pickListData", records);
            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);  
        
    },
    manageSectionHelper : function(component, event,helper){
        var initDat = component.get("v.initData");
        var opportunityRecordType = initDat.opportunityRecordType;
        var isZIApresent = initDat.isZIAproduct;
        var isZPApresent = initDat.isZPAproduct;
        var isactiveEncloserQuestion = initDat.activeEncloserQuestion;
        if(isactiveEncloserQuestion == true){
            component.set("v.ClosureQuestion",true)
        }
        if(opportunityRecordType == 'Renewal Opportunity'){
            component.set("v.RenewalQuestiondiv",true)
        }
        component.set("v.experencediv",true)
        component.set("v.experenceZPAdiv",true)
        component.set("v.customerdiv",true)
        component.set("v.SSLinspectiondiv",true)
        component.set("v.BranchBreakoutdiv",true)
        component.set("v.Appsmovedtotheclouddiv",true)
        component.set("v.Zappdeploymentsdiv",true)
        component.set("v.ImplementingZeroTrustdiv",true)
        component.set("v.ZIACompetitorsdiv",true)
        component.set("v.ZPACompetitorsdiv",true)
        
    },
    SCIListHelperMethod : function(component, event){
        this.showSpinner(component, event);
        component.set("v.noSCIFound",false);
        //var action = component.get("c.getSCIrecords");
        var action = component.get("c.getSCIWraprecords");
        action.setParams({ oppId : component.get("v.oppId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var seletedSCINumber = component.get("v.SCINumber");
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
               if(result != null){
                   
                    // alert(seletedSCINumber);
                    var i;
                    for(i=0; i<result.length; i++){
                        if(result[i].SCIRecord.Id == seletedSCINumber){
                            // alert('hi'+result[i].SCIRecord.Id);
                            result[i].isChecked = true;
                        }
                       /* var table = document.getElementById("sciListView");
                        var row = table.insertRow();
                        //row.setAttribute("class", "slds-cell-wrap");
                        var radioButton = document.createElement("input"); 
                        radioButton.setAttribute("type", "radio");
                        radioButton.setAttribute("name", "sciRowsInput");
                        radioButton.setAttribute("id", "sciSelected_"+result[i].Id);
                        if(seletedSCINumber == result[i].Id){
                            radioButton.checked = true; 
                        }
                        else{
                            radioButton.checked = false;
                        }
                        //radioButton.checked = false; 
                        //row.appendChild(radioButton);
                        var cell1 = row.insertCell();
                        var cell2 = row.insertCell();
                        var cell3 = row.insertCell();
                        var cell4 = row.insertCell();
                        var cell5 = row.insertCell();
                        cell3.setAttribute("id","primaryTopicTD");
                        cell1.appendChild(radioButton);
                        if(result[i].Name != null || result[i].Name != undefined)
                            cell2.innerHTML = result[i].Name;
                        if(result[i].Type_of_Interaction__c != null || result[i].Type_of_Interaction__c != undefined)
                            cell3.innerHTML = result[i].Type_of_Interaction__c;
                        if(result[i].Primary_Topic_Covered__c != null || result[i].Primary_Topic_Covered__c != undefined)
                            cell4.innerHTML = result[i].Primary_Topic_Covered__c;
                        if(result[i].Date__c != null || result[i].Date__c != undefined){
                            var d = new Date(result[i].Date__c);
                            cell5.innerHTML = (d.getMonth()+1)+"/"+d.getDate()+"/"+d.getFullYear();
                        }
                        document.getElementById('primaryTopicTD').style.width = '20%';
                        */
                    }
                    component.set("v.SCIList", result);
                }
                else{
                    component.set("v.noSCIFound",true);
                }
            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action);  
    },
    validateScreen1Helper : function(component, event,helper){
        this.showSpinner(component, event);
        var returnvalue = false;
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        this.clearScreen1Errors(component, event,helper);
        var downgradingFrom = component.find("downgradingFrom");
        var downgradingFromValue = component.get("v.ChurnRecord.DowngradingFrom__c");
        var downgradingTo = component.find("downgradingTo");
        var downgradingToValue = component.get("v.ChurnRecord.DowngradingTo__c");
        if(!$A.util.isEmpty(downgradingFromValue) && !$A.util.isEmpty(downgradingToValue)){ 
            if(downgradingFromValue == downgradingToValue){
                component.set("v.downgradiononrror",true);
                $A.util.addClass(downgradingTo, 'slds-has-error');
                //downgradingTo.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                returnvalue = true;
            }
            else{
                //downgradingTo.set("v.errors", [{message: null}]);
                $A.util.removeClass(downgradingTo, 'slds-has-error');
            }
        }
        
        if(returnvalue == true){
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            component.set("v.section1Completed",false);
            this.scrollTotop(component, event); 
        }
        else{
            component.set("v.section1Completed",true);
        }
        

        
        this.hideSpinner(component, event);
        return returnvalue;
        
    },
    validateScreen2Helper : function(component, event,helper){
        this.showSpinner(component, event);
        var returnvalue = false;
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        this.clearScreen1Errors(component, event,helper);
        
        
        
        if(component.get("v.SSLinspectiondiv") == true){
            var sslInspection = component.find("sslInspection");
            var sslInspectionValue = component.get("v.ChurnRecord.SSL_inspection__c");
            if(!$A.util.isEmpty(sslInspectionValue)){ 
                $A.util.removeClass(sslInspection, 'slds-has-error');
            }
            else{
                $A.util.addClass(sslInspection, 'slds-has-error');
                component.set("v.SSLinspectionError",true);
                returnvalue = true;
            }
        }
        if(component.get("v.BranchBreakoutdiv") == true){
            var branchBreakout = component.find("branchBreakout");
            var branchBreakoutValue = component.get("v.ChurnRecord.Branch_Breakout__c");
            if(!$A.util.isEmpty(branchBreakoutValue)){ 
                $A.util.removeClass(branchBreakout, 'slds-has-error');
            }
            else{
                $A.util.addClass(branchBreakout, 'slds-has-error');
                component.set("v.BranchBreakoutError",true);
                returnvalue = true;
            }
        }
        if(component.get("v.Appsmovedtotheclouddiv") == true){
            var appsMovedToTheCloud = component.find("appsMovedToTheCloud");
            var appsMovedToTheCloudValue = component.get("v.ChurnRecord.Apps_Moved_To_The_Cloud__c");
            if(!$A.util.isEmpty(appsMovedToTheCloudValue)){ 
                $A.util.removeClass(appsMovedToTheCloud, 'slds-has-error');
            }
            else{
                $A.util.addClass(appsMovedToTheCloud, 'slds-has-error');
                component.set("v.AppsmovedtothecloudError",true);
                returnvalue = true;
            }
        }  
        if(component.get("v.Zappdeploymentsdiv") == true){
            var zappDeployments = component.find("zappDeployments");
            var zappDeploymentsValue = component.get("v.ChurnRecord.Zapp_deployments__c");
            if(!$A.util.isEmpty(zappDeploymentsValue)){ 
                $A.util.removeClass(zappDeployments, 'slds-has-error');
            }
            else{
                $A.util.addClass(zappDeployments, 'slds-has-error');
                component.set("v.ZappdeploymentsError",true);
                returnvalue = true;
            }
        }  
        if(component.get("v.ImplementingZeroTrustdiv") == true){
            var implementingZeroTrust = component.find("implementingZeroTrust");
            var implementingZeroTrustValue = component.get("v.ChurnRecord.Implementing_Zero_Trust__c");
            if(!$A.util.isEmpty(implementingZeroTrustValue)){ 
                $A.util.removeClass(implementingZeroTrust, 'slds-has-error');
            }
            else{
                $A.util.addClass(implementingZeroTrust, 'slds-has-error');
                component.set("v.ImplementingZeroTrustError",true);
                returnvalue = true;
            }
        }   
        

            var ZIAPrimaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZIAPrimaryReason__c");
            var ZIASecondaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZIASecondaryReason__c");
            var ZIASecondaryReason = component.find("ZIASecondaryResn");
            if(!$A.util.isEmpty(ZIAPrimaryReasonValue) && !$A.util.isEmpty(ZIASecondaryReasonValue)){ 
                if(ZIAPrimaryReasonValue == ZIASecondaryReasonValue)  {
                    component.set("v.ZIASecondaryReasonrror",true);
                    $A.util.addClass(ZIASecondaryReason, 'slds-has-error');
                    //ZIASecondaryReason.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                    returnvalue = true;
                }
                else{
                    //ZIASecondaryReason.set("v.errors", [{message: null}]);
                    $A.util.removeClass(ZIASecondaryReason, 'slds-has-error');
                    
                    
                }
            }

            var ZPAPrimaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZPAPrimaryReason__c");
            var ZPASecondaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZPASecondaryReason__c");
            var ZPASecondaryReason = component.find("ZPASecondaryResn");
            if(!$A.util.isEmpty(ZPAPrimaryReasonValue) && !$A.util.isEmpty(ZPASecondaryReasonValue)){ 
                if(ZPAPrimaryReasonValue == ZPASecondaryReasonValue)  {
                    component.set("v.ZPASecondaryReasonrror",true);
                    $A.util.addClass(ZPASecondaryReason, 'slds-has-error');
                    //ZPASecondaryReason.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                    returnvalue = true;
                }
                else{
                    //ZPASecondaryReason.set("v.errors", [{message: null}]);
                    $A.util.removeClass(ZPASecondaryReason, 'slds-has-error');
                }
            }

        var isExperienceRequired =false;
        
        var ZIAPrimaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZIAPrimaryReason__c");
        if(ZIAPrimaryReasonValue != '' && ZIAPrimaryReasonValue !=null){
            if(ZIAPrimaryReasonValue.includes("lacking")){
                isExperienceRequired = true; 
            }
        }
        
        
        var ZPAPrimaryReasonValue = component.get("v.ChurnRecord.ExperienceFeaturesZPAPrimaryReason__c");
        if(ZPAPrimaryReasonValue != '' && ZPAPrimaryReasonValue !=null){
            if(ZPAPrimaryReasonValue.includes("lacking")){
                isExperienceRequired = true; 
            }
        }
        
        if(isExperienceRequired == true){
            var ExperienceMissingfunctionalityValue = component.get("v.ChurnRecord.ExperienceMissingfunctionality__c");
            if(!$A.util.isEmpty(ExperienceMissingfunctionalityValue)){ 
            }
            else{
                component.set("v.expFunctionalityError",true);
                returnvalue = true;
            }
        }

        var OtherPrimaryReasonValue = component.get("v.ChurnRecord.Other_Primary_Reason__c");
        var OtherSecondaryReasonValue = component.get("v.ChurnRecord.Other_Secondary_Reason__c");
        var OtherSecondaryReason = component.find("secondaryotherResn");
        if(!$A.util.isEmpty(OtherPrimaryReasonValue) && !$A.util.isEmpty(OtherSecondaryReasonValue)){ 
            if(OtherPrimaryReasonValue == OtherSecondaryReasonValue)  {
                component.set("v.OtherSecondaryReasonrror",true);
                $A.util.addClass(OtherSecondaryReason, 'slds-has-error');
                //OtherSecondaryReason.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                returnvalue = true;
            }
            else{
                //OtherSecondaryReason.set("v.errors", [{message: null}]);
                $A.util.removeClass(OtherSecondaryReason, 'slds-has-error');
            }
        }
        
        var LifeTimePrimaryReasonValue = component.get("v.ChurnRecord.Lifetime_Value_Primary_Reason__c");
        var LifeTimeSecondaryReasonValue = component.get("v.ChurnRecord.Lifetime_Value_Secondary_Reason__c");
        var LifeTimeSecondaryReason = component.find("secondarylifetimeResn");
        if(!$A.util.isEmpty(LifeTimePrimaryReasonValue) && !$A.util.isEmpty(LifeTimeSecondaryReasonValue)){ 
            if(LifeTimePrimaryReasonValue == LifeTimeSecondaryReasonValue)  {
                component.set("v.LifeSecondaryReasonrror",true);
                $A.util.addClass(LifeTimeSecondaryReason, 'slds-has-error');
                //LifeTimeSecondaryReason.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                returnvalue = true;
            }
            else{
                //LifeTimeSecondaryReason.set("v.errors", [{message: null}]);
                $A.util.removeClass(LifeTimeSecondaryReason, 'slds-has-error');
            }
        }
        if(returnvalue == true){
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            component.set("v.section2Completed",false);
            this.scrollTotop(component, event); 
        }
        else{
            component.set("v.section2Completed",true);
        }
        
        var isRenwalQuestion = component.get("v.RenewalQuestiondiv");
        if(isRenwalQuestion == true){
            var isRenwalQuestionValue = component.get("v.ChurnRecord.Renewalquestion__c");
            var isRenwalQuestionNotesValue = component.get("v.ChurnRecord.Renewal_Question_Notes__c");
            var LifeTimeSecondaryReason = component.find("renewalQuestionNotes");
            if(isRenwalQuestionValue == 'Other'){
                if(!$A.util.isEmpty(isRenwalQuestionNotesValue)){ 
                    $A.util.removeClass(LifeTimeSecondaryReason, 'slds-has-error');
                }
                else{
                    component.set("v.renwalNotesError",true);
                    $A.util.addClass(LifeTimeSecondaryReason, 'slds-has-error');
                    returnvalue = true;
                }
            }
        }
        
        
        this.hideSpinner(component, event);
        return returnvalue;
    },
    validateScreen3Helper : function(component, event,helper){
        component.set("v.ZIASecondaryCompetitorReasonrror",false);
        component.set("v.ZIAPrimaryOtherCompetitorReasonrror",false);
        component.set("v.ZIASecondaryOtherCompetitorReasonrror",false);
        component.set("v.ZPASecondaryCompetitorReasonrror",false);
        component.set("v.ZPAPrimaryOtherCompetitorReasonrror",false);
        component.set("v.ZPASecondaryOtherCompetitorReasonrror",false);
        component.set("v.lossAnalysysError",false);
        component.set("v.SCIReasonrror",false);  
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        this.showSpinner(component, event);
        var returnvalue = false;
        var SCI = '';
        //if(component.get("v.isLossCallConducted") == true){
        //if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'  && component.get("v.SCINumber") == ''){
        if(component.get("v.ChurnRecord.Lost_Analysis_Call__c") == 'Call Conducted'){
            /*var SCI=getSelectedSCI();
            function getSelectedSCI(){
                var radios = document.getElementsByName('sciRowsInput');
                var i;
                for (var i = 0, length = radios.length; i < length; i++) {
                    if (radios[i].checked) {
                        var str = radios[i].id;
                        if(str != null || str != undefined){
                            var res = str.split("_");
                            return res[1];
                        }
                    }
                    
                }
            }
            */
            
            if(component.get("v.SCINumber") != '' && component.get("v.SCINumber") != undefined){
                returnvalue = false;
            }
            else{
                returnvalue = true;
                component.set("v.SCIReasonrror",true);  
            }
            //component.set("v.SCINumber",SCI);
		}
      
        var ZIAPrimaryCompetitorValue = component.get("v.ChurnRecord.ZIA_Primary_Competitor__c");
        var ZIASecondaryCompetitorValue = component.get("v.ChurnRecord.ZIA_Secondary_Competitor__c");
        var ZPAPrimaryCompetitorValue = component.get("v.ChurnRecord.ZPA_Primary_Competitor__c");
        var ZPASecondaryCompetitorValue = component.get("v.ChurnRecord.ZPA_Secondary_Competitor__c");
        
        var ZIASecondaryCompetitor = component.find("oppLossZIASecondaryReason");
        if(!$A.util.isEmpty(ZIAPrimaryCompetitorValue) && !$A.util.isEmpty(ZIASecondaryCompetitorValue)){ 
            if(ZIAPrimaryCompetitorValue == ZIASecondaryCompetitorValue && ZIAPrimaryCompetitorValue != 'Other'&& ZIASecondaryCompetitorValue != 'Other')  {
                component.set("v.ZIASecondaryCompetitorReasonrror",true);
                $A.util.addClass(ZIASecondaryCompetitor, 'slds-has-error');
                //ZIASecondaryCompetitor.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                returnvalue = true;
            }
            else{
                //ZIASecondaryCompetitor.set("v.errors", [{message: null}]);
                $A.util.removeClass(ZIASecondaryCompetitor, 'slds-has-error');
            }
        }
            if(ZIAPrimaryCompetitorValue == 'Other'){
                var ZIAPrimaryOtherCompetitorValue = component.get("v.ChurnRecord.ZIA_Other_Primary_Competitor__c");
                var oppLossOtherPrimaryCompetitorsNotes = component.find("oppLossOtherPrimaryCompetitorsNotes");
                
                 if(!$A.util.isEmpty(ZIAPrimaryOtherCompetitorValue)){ 
                    $A.util.removeClass(oppLossOtherPrimaryCompetitorsNotes, 'slds-has-error');
                    }
                     else{
                        $A.util.addClass(oppLossOtherPrimaryCompetitorsNotes, 'slds-has-error');
                        component.set("v.ZIAPrimaryOtherCompetitorReasonrror",true);
                        returnvalue = true;
                    }
                
            }
            
            if(ZIASecondaryCompetitorValue == 'Other'){
                
                var ZIASecondaryOtherCompetitorValue = component.get("v.ChurnRecord.ZIA_Other_Secondary_Competitor__c");
                var oppLossOtherSecondaryCompetitorsNotes = component.find("oppLossOtherSecondaryCompetitorsNotes");
                
                 if(!$A.util.isEmpty(ZIASecondaryOtherCompetitorValue)){ 
                     
                    $A.util.removeClass(oppLossOtherSecondaryCompetitorsNotes, 'slds-has-error');
                    }
                     else{
                        $A.util.addClass(oppLossOtherSecondaryCompetitorsNotes, 'slds-has-error');
                        component.set("v.ZIASecondaryOtherCompetitorReasonrror",true);
                        returnvalue = true;
                    }
                
            }
        
        
        var ZPASecondaryCompetitor = component.find("oppLossZPASecondaryReason");
        if(!$A.util.isEmpty(ZPAPrimaryCompetitorValue) && !$A.util.isEmpty(ZPASecondaryCompetitorValue)){ 
            if(ZPAPrimaryCompetitorValue == ZPASecondaryCompetitorValue && ZPAPrimaryCompetitorValue != 'Other' && ZPASecondaryCompetitorValue != 'Other')  {
                component.set("v.ZPASecondaryCompetitorReasonrror",true);
                $A.util.addClass(ZPASecondaryCompetitor, 'slds-has-error');
                //ZPASecondaryCompetitor.set("v.errors", [{message: "Primary and Secondary can not be same"}]);
                returnvalue = true;
            }
            else{
                //ZPASecondaryCompetitor.set("v.errors", [{message: null}]);
                $A.util.removeClass(ZPASecondaryCompetitor, 'slds-has-error');
            }
        }
             if(ZPAPrimaryCompetitorValue == 'Other'){
                var ZPAPrimaryOtherCompetitorValue = component.get("v.ChurnRecord.ZPA_Other_Primary_Competitor__c");
                var oppLossZPAOtherPrimaryCompetitorsNotes = component.find("oppLossZPAOtherPrimaryCompetitorsNotes");
                
                 if(!$A.util.isEmpty(ZPAPrimaryOtherCompetitorValue)){ 
                    $A.util.removeClass(oppLossZPAOtherPrimaryCompetitorsNotes, 'slds-has-error');
                    }
                     else{
                        $A.util.addClass(oppLossZPAOtherPrimaryCompetitorsNotes, 'slds-has-error');
                        component.set("v.ZPAPrimaryOtherCompetitorReasonrror",true);
                        returnvalue = true;
                    }
                
            }
             if(ZPASecondaryCompetitorValue == 'Other'){
                var ZPASecondaryOtherCompetitorValue = component.get("v.ChurnRecord.ZPA_Other_Secondary_Competitor__c");
                var oppLossZPAOtherSecondaryCompetitorsNotes = component.find("oppLossZPAOtherSecondaryCompetitorsNotes");
                
                 if(!$A.util.isEmpty(ZPASecondaryOtherCompetitorValue)){ 
                    $A.util.removeClass(oppLossZPAOtherSecondaryCompetitorsNotes, 'slds-has-error');
                    }
                     else{
                        $A.util.addClass(oppLossZPAOtherSecondaryCompetitorsNotes, 'slds-has-error');
                        component.set("v.ZPASecondaryOtherCompetitorReasonrror",true);
                        returnvalue = true;
                    }
                
            }
        
            var lossAnalysisCallValue = component.get("v.ChurnRecord.Lost_Analysis_Call__c");
            var lossAnalysisCall = component.find("lostCallConductedId");
            
            if(!$A.util.isEmpty(lossAnalysisCallValue)){ 
                $A.util.removeClass(lossAnalysisCall, 'slds-has-error');
            }
            else{
                $A.util.addClass(lossAnalysisCall, 'slds-has-error');
                component.set("v.lossAnalysysError",true);
                returnvalue = true;
            }
        
        

        
        if(returnvalue == true){
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            component.set("v.section3Completed",false);
            this.scrollTotop(component, event); 
        }
        else{
            component.set("v.section3Completed",true);
        }
        
        this.hideSpinner(component, event);
        return returnvalue;
    },
    validateSaveHelper : function(component, event,helper){
        component.set("v.encloserQuestionError",false);
        var returnvalue = false;
        component.set("v.showErrors",false);
        component.set("v.errorMessage",'');
        if(component.get("v.ClosureQuestion")==true){
            if(component.get("v.confirmEncloser") == false){
                component.set("v.encloserQuestionError",true);
                returnvalue = true;
            }
        }
        if(returnvalue == true){
            component.set("v.showErrors",true);
            component.set("v.errorMessage",'Please fill the all required fields.');
            component.set("v.summaryCompleted",false);
            this.scrollTotop(component, event); 
        }
        else{
            component.set("v.summaryCompleted",true);
        }
        
        return returnvalue;
    },
    clearScreen1Errors : function(component, event,helper){
        component.set("v.downgradiononrror",false);
        component.set("v.ZPAPrimaryReasonrror",false);
        component.set("v.ZIAPrimaryReasonrror",false);
        component.set("v.ZPASecondaryReasonrror",false);
        component.set("v.ZIASecondaryReasonrror",false);
        component.set("v.LifeSecondaryReasonrror",false);
        component.set("v.OtherSecondaryReasonrror",false);
        component.set("v.ZIASecondaryCompetitorReasonrror",false);
        component.set("v.ZIAPrimaryOtherCompetitorReasonrror",false);
        component.set("v.ZIASecondaryOtherCompetitorReasonrror",false);
        component.set("v.ZPASecondaryCompetitorReasonrror",false);
        component.set("v.ZPAPrimaryOtherCompetitorReasonrror",false);
        component.set("v.ZPASecondaryOtherCompetitorReasonrror",false);
        component.set("v.SSLinspectionError",false);
        component.set("v.BranchBreakoutError",false);
        component.set("v.AppsmovedtothecloudError",false);
        component.set("v.ZappdeploymentsError",false);
        component.set("v.ImplementingZeroTrustError",false);
        component.set("v.SCIReasonrror",false);
        component.set("v.renwalNotesError",false);
    },
    scrollTotop: function(component, event){
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
    },
    saveRecordHelper : function(component, event,helper){
        this.showSpinner(component, event);
        var action = component.get("c.saveRecord");
        if(component.get("v.isAdvancedZIA") == true){
            component.set("v.ChurnRecord.DonotrenewZIAProducts__c",component.get("v.DonotrenewZIAProducts"));
        }
        else{
            component.set("v.ChurnRecord.DonotrenewZIAProducts__c",'');
        }
        
        if(component.get("v.isAdvancedZPA") == true){
            component.set("v.ChurnRecord.DonotrenewZPAProducts__c",component.get("v.DonotrenewZPAProducts"));
        }
        else{
            component.set("v.ChurnRecord.DonotrenewZPAProducts__c",'');
        }
        if(component.get("v.isAdvancedSupport") == true){
            component.set("v.ChurnRecord.DonotrenewSupportProducts__c",component.get("v.DonotrenewSupportProducts"));
        }
        else{
            component.set("v.ChurnRecord.DonotrenewSupportProducts__c",'');
        }

        action.setParams({ 
            recordId : component.get("v.recordId"),
            oppId : component.get("v.oppId"),
            SCINumber : component.get("v.SCINumber"),
            confirmEncloser : component.get("v.confirmEncloser"),
            isReductionCheck:component.get("v.isReductionCheck"),
            isDowngradingCheck:component.get("v.isDowngradingCheck"),
            isRenewAdvancedCheck:component.get("v.isRenewAdvancedCheck"),
            isOtherCheck:component.get("v.isOtherCheck"),
            churnObj:component.get("v.ChurnRecord")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                if(data.status == true){
                    window.open("/"+component.get("v.oppId"),'_top');
                }
                else{
                    var errors = response.getError();   
                    component.set("v.showErrors",true);
                    component.set("v.errorMessage",data.exceptionMsg);
                }
                

            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action); 
    },
    getChurnRecordHelper: function(component, event,helper){
        this.showSpinner(component, event);
        var action = component.get("c.getChuran");
        action.setParams({ recordId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                if(data != null){
                    //alert(data.Type_of_Churn__c);
                    component.set("v.ChurnRecord",data);
                    if(data.Type_of_Churn__c != null && data.Type_of_Churn__c != ''){
                        var churanTypeList = data.Type_of_Churn__c.split(';');
                        var i;
                        for (i = 0; i < churanTypeList.length; i++) {
                            //alert(churanTypeList[i]);
                            if(churanTypeList[i] == 'Reduction in Seats'){
                                component.set("v.isReductionCheck",true);
                            }
                            if(churanTypeList[i] == 'Downgrading to a Lower Bundle'){
                                component.set("v.isDowngradingCheck",true);
                            }
                            if(churanTypeList[i] == 'Did not Renew Advanced features'){
                                component.set("v.isRenewAdvancedCheck",true);
                                if(data.DonotrenewZIAProducts__c != null && data.DonotrenewZIAProducts__c != ''){
                                    component.set("v.isAdvancedZIA",true);
                                    component.set("v.DonotrenewZIAProducts",data.DonotrenewZIAProducts__c);
                                }
                                else{
                                    component.set("v.ChurnRecord.DonotrenewZIAProducts__c",'');
                                }
                                if(data.DonotrenewZPAProducts__c != null && data.DonotrenewZPAProducts__c != ''){
                                    component.set("v.isAdvancedZPA",true);
                                    component.set("v.DonotrenewZPAProducts",data.DonotrenewZPAProducts__c);
                                }
                                else{
                                    component.set("v.ChurnRecord.DonotrenewZPAProducts__c",'');
                                    
                                }
                                if(data.DonotrenewSupportProducts__c != null && data.DonotrenewSupportProducts__c != ''){
                                    component.set("v.isAdvancedSupport",true);
                                    component.set("v.DonotrenewSupportProducts",data.DonotrenewSupportProducts__c);
                                }
                                else{
                                    component.set("v.ChurnRecord.DonotrenewSupportProducts__c",'');
                                }
                            }
                            if(churanTypeList[i] == 'Other (If other, state reason)'){
                                component.set("v.isOtherCheck",true);
                            }
                        }
                    }
                    component.set("v.ChurnRecord",data);
                    //component.set("v.isLossCallConducted",data.LossAnalysisCall__c);
                    component.set("v.lostCallValue",data.Lost_Analysis_Call__c);
                    component.set("v.SCINumber",data.SCINumber__c);
                }
            }
            else if(state == "ERROR"){
                var errors = response.getError();   
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(action); 
    },
})