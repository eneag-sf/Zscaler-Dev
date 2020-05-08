({
    doInit: function (component, event, helper) {
        console.log('inside doinit');
        
        if (component.get("v.recordId")) {
            
            console.log(component.get("v.recordId"));
            console.log(component.get("v.oppId"));
            console.log(component.get("v.accId"));
            component.set("v.isEdit", true);
            
            if (!component.get("v.oppId")) {
                component.set("v.proceedload", true);
            }
            if (component.get('v.accId')) {
                let contactfiltercriteria = 'Active__c = false and ';
                contactfiltercriteria += ' AccountId = \'' + component.get('v.accId') + '\'' ;
                component.set("v.contactfiltercriteria", contactfiltercriteria);
            }
            
        } else {
            console.log(component.get("v.recordId"));
            console.log(component.get("v.oppId"));
            console.log(component.get("v.accId"));
            component.set("v.isEdit", false);
            component.set("v.proceedload", true);
        }
        
        if (component.get('v.oppId') || component.get('v.accId')) {
            helper.populateOppdetails(component, event, helper, component.get('v.oppId'), false,component.get('v.accId'));
        }
        
        component.set("v.stepname", '1');
    },
    
    
    handleLoad: function (cmp, event, helper) {
        
        console.log('handleLoad called');
        
        cmp.set("v.showSpinner", false);
        
        if (!cmp.get("v.isEdit")) {
            helper.prepopulate(cmp, event, helper, false); 
        }
        else{
            if (cmp.get('v.oppId')) {
                if (!cmp.get("v.stage")) {
                    cmp.set("v.stage", cmp.get("v.oppRec")['StageName']);
                }
                if (!cmp.get("v.type")) {
                    cmp.set("v.type", cmp.get("v.oppRec")['Type']);
                }
                if (!cmp.get("v.rsm")) {
                    cmp.set("v.rsm", cmp.get("v.oppRec")['Owner']['Name']);
                }
                if (!cmp.get("v.tcv")) {
                    var num = cmp.get("v.oppRec")['TCV__c'];
                    cmp.set("v.tcv", num);
                }
                if (!cmp.get("v.acv")) {
                    var num = cmp.get("v.oppRec")['Amount'];
                    cmp.set("v.acv", num);
                }
                if (!cmp.get("v.closedate")) {
                    cmp.set("v.closedate", cmp.get("v.oppRec")['CloseDate']);
                }
            }
        }
    },
    
    handleSubmit: function (component, event, helper) {  
        
        event.preventDefault();       // stop the form from submitting
        
        var fields = event.getParam('fields');
        var CurrentDate = new Date();
        var IsSuccess = true;
        
        var ismeetingConfirmed = component.get("v.IsMeetingConfirmed");
        
        
        //For Default Until QA give commnets
        fields.Approval_Status__c = "Approval Required";
        
        
        if(ismeetingConfirmed){
            if(fields.Date_of_Meeting__c != null){
                var dom = $A.localizationService.formatDate(new Date(fields.Date_of_Meeting__c), "yyyy-MM-dd");
                var curDate =  $A.localizationService.formatDate(CurrentDate, "yyyy-MM-dd");
                if(dom <= curDate){
                    component.set("v.domValidationError",true);
                    IsSuccess = false;
                }else{
                    component.set("v.domValidationError",false);
                }
            }
        }
        
        //Start Date and EndDate value Validation
        if(fields.Start_Date__c != null || fields.End_Date__c != null){
            if(fields.Start_Date__c != null){
                if(new Date(fields.Start_Date__c) < CurrentDate){
                    component.set("v.startdateValidationError",true);
                    IsSuccess = false;
                }else{
                    component.set("v.startdateValidationError",false);
                }
            }
            
            if(fields.End_Date__c != null && fields.Start_Date__c != null){
                if(new Date(fields.End_Date__c) < new Date(fields.Start_Date__c)){
                    component.set("v.enddateValidationError",true);
                    IsSuccess = false;
                }else{
                    component.set("v.enddateValidationError",false);
                }
            }
        }
        
        //Start time Validation
        if(component.get("v.StartTime") != null){
            var time = component.get("v.StartTime") + 'Z';
            fields.Start_Time__c = time;
            $A.util.removeClass(component.find("ErrorOne"), "show");
            $A.util.removeClass(component.find("ErrorSectionOne"), "show");
        }else{
            $A.util.addClass(component.find("ErrorOne"),"show");
            $A.util.addClass(component.find("ErrorSectionOne"),"show");
            event.preventDefault();
        }
        
        //End time Validation
        if(component.get("v.EndTime") != null){
            var Endtime = component.get("v.EndTime") + 'Z';
            fields.End_Time__c = Endtime;
            $A.util.removeClass(component.find("ErrorTwo"), "show");
            $A.util.removeClass(component.find("ErrorSectionTwo"), "show");
        }else{
            $A.util.addClass(component.find("ErrorTwo"),"show");
            $A.util.addClass(component.find("ErrorSectionTwo"),"show");
            event.preventDefault();
        }
        
     
        
        //Set Current Quator value
        fields.Current_Quarter_Opportunity__c = component.get("v.currQtr");
        
		if(IsSuccess == true){
			
			//Set 3 Why values from opportunity
			if(component.get("v.oppRec") != null){
				let oppRec = component.get("v.oppRec");
				if(oppRec.Why_Buy_Now__c){
					fields.Why_Now__c = oppRec.Why_Buy_Now__c;
				}
				if(oppRec.Why_Buy_Anything__c){
					fields.Why_Anything__c = oppRec.Why_Buy_Anything__c;
				}
				if(oppRec.Why_Buy_Zscaler__c){
					fields.Why_Zscaler__c = oppRec.Why_Buy_Zscaler__c;
				}
			}
			//Set Company Information from Account
			if(component.get("v.AccountRec") != null){
				let accRec = component.get("v.AccountRec");
				if(accRec.Zscaler_Customer_Summary__c){
					fields.Value_Summary__c = accRec.Zscaler_Customer_Summary__c;
				}
			}
			//Set install Base
			if(component.get("v.InstallBase") != null){
				let insBase = component.get("v.InstallBase");
				if(insBase){
					console.log('--Set insBase--',insBase);
					fields.Install_Base__c = insBase;
				}
			}
			//Set travel request
			if(component.get("v.travelReq") != null){
				let trvReq = component.get("v.travelReq");
				if(trvReq){
					fields.Travel_Request__c = trvReq;
				}
			}
			
			//Submit the form
			component.find('execform').submit(fields);
		}
    },
    
    ChangeMeeting : function (component, event, helper) {
        component.set('v.isVisible',false);
        component.set('v.isVisible',true);
        component.set("v.IsMeetingConfirmed",component.find('meetingconfirmed').get("v.value"));
        
        if(component.get("v.IsMeetingConfirmed") != undefined){
            if( component.get("v.IsMeetingConfirmed") == true){
                component.set("v.startdateValidationError",false);
                component.set("v.enddateValidationError",false);
            }else {
                component.set("v.domValidationError",false);
            }
        }
    },
    
    ChangeMeetingEdit : function (component, event, helper) {
        component.set('v.isVisibleEdit',false);
        component.set('v.isVisibleEdit',true);
        component.set("v.IsMeetingConfirmed",component.find('meetingconfirmedEdit').get("v.value"));
        
        if(component.get("v.IsMeetingConfirmed") != undefined){
            if( component.get("v.IsMeetingConfirmed") == true){
                component.set("v.startdateValidationError",false);
                component.set("v.enddateValidationError",false);
            }else {
                component.set("v.domValidationError",false);
            }
        }
    },
    
    handleError: function (cmp, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        cmp.set('v.showSpinner', false);
    },
    
    handleSuccess: function (cmp, event, helper) {
        var payload = event.getParams().response;
        console.log(payload.id);
        if (!cmp.get("v.recordId")) {
            cmp.set("v.recordId", payload.id);
            cmp.set("v.isEdit", true);
        }
        console.log(cmp.get("v.recordId"));
        cmp.set('v.showSpinner', false);
        cmp.set('v.stepname', '2');
    },
    pathstepchange: function (cmp, event, helper) {
        event.preventDefault();
        let prevstep = cmp.get('v.stepname');
        cmp.set('v.stepname', prevstep);
    },
    
    previous: function (cmp, event, helper) {
        let currstep = cmp.get('v.stepname');
        currstep = Number(currstep) - 1;
        cmp.set('v.stepname', String(currstep));
    },
    
    userchanged: function (cmp, event, helper) {
        let selItem = cmp.get("v.selItem");
        console.log('userchanged :: selItem::',cmp.get("v.selItem"));
        if(selItem){
            console.log(cmp.get("v.selItem")['rec']);
            let record = cmp.get("v.selItem")['rec'];
            if (record) {
                let userdetail = {
                    id: record['Id'],
                    name: record['Name'],
                    title: record['Title'],
                    email: record['Email']
                };
                console.log(userdetail);
                let userlst = [];
                userlst = cmp.get('v.userList'); 
                
                let found = false;
                if(userlst.some(user => user.email === userdetail.email)){
                    found = true;
                }            
                console.log('userchanged ::found ::',found);
                if(!found){      
                    userlst.push(userdetail);
                    console.log(userlst);
                }
                cmp.set("v.userList", userlst);
            }
        }
    },
    
    contactchanged: function (cmp, event, helper) {
        console.log(cmp.get("v.contactselecteditem")['rec']);
        let record = cmp.get("v.contactselecteditem")['rec'];
        if (record) {
            let contact = {
                id: record['Id'],
                name: record['Name'],
                title: record['Title'],
                email: record['Email']
            };
            console.log(contact);
            let headofitlst = cmp.get('v.headofitlst');
            let headofsecuritylst = cmp.get('v.headofsecuritylst');
            let headofnetworkinglst = cmp.get('v.headofnetworkinglst');
            let othercontactlst = cmp.get('v.othercontactlst');
            if (record['Head_of_IT__c']) {
                let donotadd = false;
                headofitlst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                    });
                if (!donotadd) {
                    headofitlst.push(contact);
                }
                console.log(headofitlst);
            } else if (record['Head_of_Security__c']) {
                let donotadd = false;
                headofsecuritylst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                          });
                if (!donotadd) {
                    headofsecuritylst.push(contact);
                }
                console.log(headofsecuritylst);
            } else if (record['Head_of_Networking__c']) {
                let donotadd = false;
                headofnetworkinglst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                            });
                if (!donotadd) {
                    headofnetworkinglst.push(contact);
                }
                console.log(headofnetworkinglst);
            } else {
                let donotadd = false;
                othercontactlst.forEach(con => {
                    if (con.id == contact.id) {
                    donotadd = true;
                }
                                        });
                if (!donotadd) {
                    othercontactlst.push(contact);
                }
                console.log(othercontactlst);
            }
            cmp.set("v.headofitlst", headofitlst);
            cmp.set("v.headofsecuritylst", headofsecuritylst);
            cmp.set("v.headofnetworkinglst", headofnetworkinglst);
            cmp.set("v.othercontactlst", othercontactlst);
        }
    },
    
    saveinternalatt: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        helper.saveinternalatt(cmp, event, helper);
    },
    
    saveexternalatt: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        helper.saveexternalatt(cmp, event, helper);
    },
    
    cancel: function (cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        if (cmp.get('v.recordId')) {
            window.open('/' + cmp.get('v.recordId'), '_self');
        } else if (cmp.get('v.oppId')) {
            window.open('/' + cmp.get('v.oppId'), '_self');
        } else if (cmp.get('v.accId')) {
            window.open('/' + cmp.get('v.accId'), '_self');
        }
    },
    
    setMinEndTime :function(cmp, event, helper){
        let startTime =  event.getSource().get('v.value') + 'Z';
        cmp.set("v.minTime",  startTime);
    },
    
    setMaxStartTime :function(cmp, event, helper){
        let endTime =  event.getSource().get('v.value') + 'Z';
        cmp.set("v.maxTime",  endTime);
    },
    
    oppChanged: function(cmp, event, helper){
        cmp.set("v.oppId", event.getSource().get('v.value'));
        helper.populateOppdetails(cmp,event, helper, event.getSource().get('v.value'), true,component.get('v.accId'));
    },
    
    accountChanged: function(cmp, event, helper){
        cmp.set("v.accId", event.getSource().get('v.value'));
        helper.changecontactfilter(cmp,event, helper, event.getSource().get('v.value'));
    },
    
    openCreateContactRecordModel: function(component, event, helper) {
        component.set("v.createContact", true);
    },
    
    closeCreateContactRecordModel: function(component, event, helper) {
        component.set("v.createContact", false);
    },
    
    handleContactSaved : function(component, event, helper) {
        let savedContact  = event.getParam("closeOnSaveContact");
        component.set("v.createContact", savedContact);
    },
    
})