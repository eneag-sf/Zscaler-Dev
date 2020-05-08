({
    SearchHelper: function(component, event) {
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchAccount");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'selectedgeo' : component.get("v.geo"),
            'selectedRegion' : component.get("v.Region"),
            'selectedindustry' : component.get("v.selectedIndustry"),
            'ZIAString' : component.get("v.ZIAString"),
            'ZPAString' : component.get("v.ZPAString"),
            'nameDrop' : component.get("v.selectedNameDrop")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert(JSON.stringify(storeResponse));
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                    component.set("v.errMessage", 'No Records Found...');
                } else {
                    component.set("v.Message", false);
                    component.set("v.errMessage", '');
                    
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);
                
                // set searchResult list with return value from server.
                 var pageSize = component.get("v.pageSize");
                component.set("v.searchResult", storeResponse); 
                component.set("v.totalRecords", component.get("v.searchResult").length);
                component.set("v.startPage", 0);                
                component.set("v.endPage", pageSize - 1);
                var PagList = [];
                for ( var i=0; i< pageSize; i++ ) {
                    if ( component.get("v.searchResult").length> i )
                        PagList.push(response.getReturnValue()[i]);    
                }
                component.set('v.PaginationList', PagList);
                component.set("v.page", 0);
                
                var pageCount =  Math.ceil(storeResponse.length / pageSize);
                component.set("v.pages", pageCount);
                
            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
   ExtCatOptions : function(component, fieldName, elementId) {
	   // alert('elementId --> '+elementId);
        var action = component.get("c.getAccountIndustryoptions");
       action.setParams({
           "objObject": component.get("v.AccountRec"),
           "fld": fieldName
       });
       var opts = [];
       action.setCallback(this, function(response) {
           console.log('in init helper before sucess..');
           if (response.getState() == "SUCCESS") {
               var allValues = response.getReturnValue();
               if (allValues != undefined && allValues.length > 0) {
                   opts.push({
                       class: "optionClass",
                       label: "--- None ---",
                       value: ""
                   });
               }
               for (var i = 0; i < allValues.length; i++) {
                   opts.push({
                       class: "optionClass",
                       label: allValues[i],
                       value: allValues[i]
                   });
               }
               component.find(elementId).set("v.options", opts);
           }
       });
       $A.enqueueAction(action);
   
    },
    pickListWrapHelperMethod : function(component, event, helper) {
        var action = component.get("c.getPickListData");
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
        });
        $A.enqueueAction(action);  
        
    },
   checkCaseRecHelper : function(component, event) {
       component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.isEditAcess", false);
        var JustificationRequestvalue = component.get("v.JustificationRequestvalue");
        var recid = component.get("v.selectedrecid");
        //var recid = event.target.id;
        
        var action = component.get("c.createAccountAccessRequest");
        action.setParams({
            'recid': recid ,
            'JustificationRequestvalue' :JustificationRequestvalue
        }); 
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var stResponse = response.getReturnValue();
                if (stResponse == 'Request Access Submitted Successfully') {
                    component.set("v.isOpenRequestAcess", false);
                    
                    if(component.get("v.isRequestModel") == true){
                        component.set("v.isRequestModel", false);
                        component.set("v.ismodalSubmited", true);
                        component.set("v.ismodalcheck", 'false');
                        component.set("v.showSuccess", true);
                        component.set("v.successMessage", 'Request Access Submitted Successfully');
                    }
                    else{
                        component.set("v.isOpen", false);
                        component.set("v.isEditAcess", true);
                        component.set("v.successMsg", 'Request Access Submitted Successfully');
                    }
                    
                    component.set("v.JustificationRequestvalue"," ");
                     this.SearchHelper(component, event);
                } 
                else {
                    component.set("v.isEditAcess", true);
                    component.set("v.successMsg", 'Request Access Case Already Submitted');
                }
                //set numberOfRecord attribute value with length of return value from server
                //component.set("v.TotalNumberOfRecord", storeResponse.length);
                //set searchResult list with return value from server.
                //component.set("v.searchResult", storeResponse); 
            }
            else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
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