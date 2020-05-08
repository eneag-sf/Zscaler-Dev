({
    doInit : function(component, event, helper) {
        
		//helper.ExtCatOptions(component, 'Industry', 'Industryval');
		
		const ZIAoptions = [{'Id':1,'Name':'Proxy replacement'},
                               {'Id':2,'Name':'Coverage of Remote User Security'},
                               {'Id':3,'Name':'Coverage of SSL Interception'},
                               {'Id':4,'Name':'Security depth with Sandbox & CloudIPS'},
                               {'Id':5,'Name':'Security Stack - Simplification'},
                               {'Id':6,'Name':'Simplified security with cost reduction'},
                               {'Id':7,'Name':'Data Protection'},
                               {'Id':8,'Name':'Guest WiFi Security'},
                               {'Id':9,'Name':'O365 Deployment and Optimization'},
                               {'Id':10,'Name':'Network Infrastructure - Cost Reduction'},
                               {'Id':11,'Name':'Branch Simplification with Local Internet Breakouts'},
                               {'Id':12,'Name':'SD-WAN Deployment'},
                               {'Id':13,'Name':'Improved Latency and User Experience'},
                               {'Id':14,'Name':'Not Applicable'},];
        component.set("v.ZIAoptions", ZIAoptions);
        
        const ZPAoptions = [{'Id':1,'Name':'Accelerated Merger and Acquisition'},
                               {'Id':2,'Name':'Not Applicable'},
                               {'Id':3,'Name':'SDP/Zero Trust Networking'},
                               {'Id':4,'Name':'VPN alternative'},
                               {'Id':5,'Name':'Secure third-party access'},
                               {'Id':6,'Name':'Secure multi-cloud access'},];
        component.set("v.ZPAoptions", ZPAoptions);
        helper.pickListWrapHelperMethod(component, event, helper);
		
	},
	 
    onkeypressEvent : function(component, event, helper){
         if(event.which == 13) {
            component.pressEnterKeyMethod();
        }
    },
    Search: function(component, event, helper) {
        component.set("v.isEditAcess", false);
        /*var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            searchField.focus();
        }else{
            // else call helper function 
            helper.SearchHelper(component, event, helper);
        }*/
        
        var accountName = component.get("v.searchKeyword");
        //var country = component.get("v.countryval");
        var geo = component.get("v.geo");
        var Region = component.get("v.Region");
        var nameDrop = component.get("v.selectedNameDrop");
        var ZIAoptions = component.get("v.SelectedZIAoptions");
        var ZPAoptions = component.get("v.SelectedZPAoptions");
        var selectedIndustry = component.get("v.selectedIndustry");
        var isError = true;
        var ZPAString = '';
        var ZIAString = '';
        if(accountName != null && accountName != undefined && accountName.length > 0 ){
            isError = false;
        }
        if(geo != null && geo != undefined && geo.length > 0 ){
            isError = false;
        }
        if(Region != null && Region != undefined && Region.length > 0 ){
            isError = false;
        }
        if(nameDrop != null && nameDrop != undefined && nameDrop.length > 0 ){
            isError = false;
        }

        if(ZIAoptions != null && ZIAoptions != undefined && ZIAoptions.length > 0 ){
            isError = false;
            var i;
            for (i = 0; i < ZIAoptions.length; i++) {
                if(ZIAString == ''){
                    ZIAString = ZIAoptions[i].Name; 
                }
                else{
                    ZIAString = ZIAString+';'+ZIAoptions[i].Name;
                }
            }
            component.set("v.ZIAString",ZIAString);
        }
        else{
            component.set("v.ZIAString",'');
        }
        if(ZPAoptions != null && ZPAoptions != undefined && ZPAoptions.length > 0 ){
            isError = false;
            var i;
            for (i = 0; i < ZPAoptions.length; i++) {
                if(ZPAString == ''){
                    ZPAString = ZPAoptions[i].Name; 
                }
                else{
                    ZPAString = ZPAString+';'+ZPAoptions[i].Name;
                }
            }
            component.set("v.ZPAString",ZPAString);
        }
        else{
            component.set("v.ZPAString",'');
        }
        if(selectedIndustry != null && selectedIndustry != undefined && selectedIndustry.length > 0 ){
            isError = false;
        }
        component.set("v.Message", false);
        component.set("v.errMessage", '');
        if(isError == true){
            component.set("v.Message", true);
            component.set("v.errMessage", 'Please select atleast one value');
        }
        else{
            helper.SearchHelper(component, event, helper,ZPAString,ZIAString);
        }
    },
    
    
    checkCaseRec :function(component,event,helper){
        var searchField = component.find('JustificationRequest');
        var justValue = searchField.get('v.value');
        searchField.set("v.errors", [{message: null}]);
        $A.util.removeClass(searchField, 'slds-has-error');
        if(justValue == ' ' || justValue === undefined || justValue == null || justValue.length <= 0){ 
            $A.util.addClass(searchField, 'slds-has-error');
            searchField.set("v.errors", [{message: "Please enter the value."}]);
        }
        else{
            searchField.set("v.errors", [{message: null}]);
            $A.util.removeClass(searchField, 'slds-has-error');
            helper.checkCaseRecHelper(component, event);
        }
        
    },
    
    
     openRequestAcessModel: function(component, event, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        // var accrec = event.currentTarget.dataset.id;
        
         var accrecname = event.currentTarget.dataset.name;
         var accrec = event.target.id;
         component.set("v.isEditAcess", false);
         component.set("v.selectedrecid", accrec);
         component.set("v.AccRecName", accrecname);
         component.set("v.JustificationRequestvalue"," ");
         component.set("v.isOpenRequestAcess", true);
         component.find("Id_spinner").set("v.class" , 'slds-hide');
           
    },
    
    openModel: function(component, event, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var accrecid = event.target.id;
         component.set("v.selectedrecid", accrecid);
         var ischeckval = event.currentTarget.dataset.ischeck;
         var issubmitval = event.currentTarget.dataset.issubmited; //event.getSource().getElement().getAttribute('data-issubmited');//objEvent.currentTarget.dataset.issubmited;
          
         if(issubmitval != undefined && issubmitval != '' && issubmitval != false){
             component.set("v.ismodalSubmited", true);
         }else{
             component.set("v.ismodalSubmited", false);
          }
         component.set("v.ismodalcheck", ischeckval);
        
         
        var action = component.get("c.moreInfoData");
        component.set("v.isEditAcess", false);
        action.setParams({
            'accrecid': accrecid
        }); 
        
        action.setCallback(this, function(response) {
            
            //hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();

            if (state === "SUCCESS") {
                var stResponse = response.getReturnValue();
                 //alert(JSON.stringify(stResponse));
                //for Display Model,set the "isOpen" attribute to "true"
                component.set("v.isOpen", true);
                //set moreInfoData list with return value from server.
                component.set("v.AccRecords", stResponse.mAccountRecs);
                component.set("v.mPartnerCloseDate", stResponse.mPartnerCloseDate);
                component.set("v.mTotalZPAACV", stResponse.mTotalZPAACV);
                component.set("v.mTotalZIAACV", stResponse.mTotalZIAACV);
                
               
                
                var FirstZPAConractdate;
                var FirstZIAConractdate;
                
                if(stResponse.mAccountRecs.First_Contract_Date__c !=null && stResponse.mAccountRecs.First_Contract_Date__c !=''){
                    FirstZIAConractdate = stResponse.mAccountRecs.First_Contract_Date__c;
                }
                if(stResponse.mAccountRecs.First_ZPA_Contract_Date__c !=null && stResponse.mAccountRecs.First_ZPA_Contract_Date__c !=''){
                    FirstZPAConractdate = stResponse.mAccountRecs.First_ZPA_Contract_Date__c;
                }

                if(FirstZIAConractdate == null && FirstZPAConractdate ==null){
                    component.set("v.OldDate", FirstZIAConractdate);
                }
                if(FirstZIAConractdate == null && FirstZPAConractdate !=null){
                    component.set("v.OldDate", FirstZPAConractdate);
                }
                if(FirstZIAConractdate != null && FirstZPAConractdate ==null){
                    component.set("v.OldDate", FirstZIAConractdate);
                }
                if(FirstZIAConractdate != null && FirstZPAConractdate !=null){
                    if(FirstZPAConractdate > FirstZIAConractdate){
                        component.set("v.OldDate", FirstZIAConractdate); 
                    }
                    else{
                        component.set("v.OldDate", FirstZPAConractdate); 
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
    },
 
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
    component.set("v.isOpen", false);
    component.set("v.isOpenRequestAcess", false);
    component.set("v.showSuccess", false);
    component.set("v.successMessage", '');
    
    },
 
    likenClose: function(component, event, helper) {
        // Display alert message on the click on the "Like and Close" button from Model Footer 
        // and set set the "isOpen" attribute to "False for close the model Box.
        //alert('thanks for like Us :)');
        component.set("v.isOpen", false);
    },
    openRequetModel: function(component, event, helper) {
        component.set("v.isRequestModel", true);
        component.set("v.JustificationRequestvalue"," ");
        component.set("v.isEditAcess", false);
        component.set("v.showSuccess", false);
        component.set("v.successMessage", '');
    },
    closeRequetModel: function(component, event, helper) {
        component.set("v.isRequestModel", false);
        component.set("v.showSuccess", false);
        component.set("v.successMessage", '');
    },
    RequestToAccount: function(component, event, helper) {
        var searchField = component.find('textAreaBox');
        var justValue = searchField.get('v.value');
        searchField.set("v.errors", [{message: null}]);
        $A.util.removeClass(searchField, 'slds-has-error');
        if(justValue == ' ' || justValue === undefined || justValue == null || justValue.length <= 0){ 
            $A.util.addClass(searchField, 'slds-has-error');
            searchField.set("v.errors", [{message: "Please enter the value."}]);
        }
        else{
            searchField.set("v.errors", [{message: null}]);
            $A.util.removeClass(searchField, 'slds-has-error');
            helper.checkCaseRecHelper(component, event);
        }
    },
    
    redirectToAccount : function(component, event, helper){
        var accid = event.target.id;
         component.set("v.isEditAcess", false);
        window.open('/'+accid, '_blank') ;
    },
    
    keyCheck : function(component, event, helper){
        if (event.which == 13){
            //component.Search(component, event, helper);
            component.set("v.isEditAcess", false);
            var searchField = component.find('searchField');
            var isValueMissing = searchField.get('v.validity').valueMissing;
            // if value is missing show error message and focus on field
            if(isValueMissing) {
                searchField.showHelpMessageIfInvalid();
                searchField.focus();
            }else{
                // else call helper function 
                helper.SearchHelper(component, event);
            }
        }    
    },
    
    redirectToNewSCI :function(component, event, helper) {
    //component.find("Id_spinner").set("v.class" , 'slds-show');
    component.set("v.isEditAcess", false);
        var accid = event.target.id;
         var action = component.get("c.redirectSCI");
        action.setParams({
            'accountId': accid
        });
                action.setCallback(this, function(response) {
            
            //hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
                    if (state === "SUCCESS") {
                        var stResponse = response.getReturnValue();
                        var retUrl = window.parent.location; 
                        var retUrl = "" + window.parent.location;
                        if (retUrl.indexOf('#') > -1) {
                            retUrl = retUrl.substr(0, retUrl.indexOf('#'));
                        }
                        window.open('/apex/ManageSCI?retUrl='+retUrl+'&'+stResponse, '_blank') ;
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
     next: function (component, event, helper) {
         component.set("v.isEditAcess", false);
        var sObjectList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
         start = start + counter;
         end = end + counter;
         component.set("v.startPage", start);
         component.set("v.endPage", end);
         component.set('v.PaginationList', PagList);
         var pageCount = start+10;
         pageCount = start/10;
         component.set("v.page", pageCount);
         
         var pageCount =  Math.ceil(sObjectList.length / pageSize);
         component.set("v.pages", pageCount);

 },
 previous: function (component, event, helper) {
         component.set("v.isEditAcess", false);
        var sObjectList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
         start = start - counter;
         end = end - counter;
         component.set("v.startPage", start);
         component.set("v.endPage", end);
         component.set('v.PaginationList', PagList);
         var pageCount = start+10;
         pageCount = start/10;
         component.set("v.page", pageCount);
         
         var pageCount =  Math.ceil(sObjectList.length / pageSize);
         component.set("v.pages", pageCount);     
 }
})