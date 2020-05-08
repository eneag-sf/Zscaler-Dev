({
    processexistingintattendee: function (cmp, intatt) {
        if (intatt) {
            let usrlst = [];
            intatt.forEach(record => {
                let userdetail = {
                    id: record['User__c'],
                    name: record['User__r']['Name'],
                    title: record['User__r']['Title'],
                    email: record['User__r']['Email']
                };
                usrlst.push(userdetail);
            });
            cmp.set("v.userList", usrlst);
        }
    },
 
    processexistingextattendee: function (cmp, extatt) {
        if (extatt) {
            let headofitlst = [];
            let headofsecuritylst = [];
            let headofnetworkinglst = [];
            let othercontactlst = [];
            extatt.forEach(record => {
                let contact = {
                    id: record['Attendee__c'],
                    name: record['Attendee__r']['Name'],
                    title: record['Attendee__r']['Title'],
                    email: record['Attendee__r']['Email']
                };
                //console.log(contact);
                if (record['Attendee__r']['Head_of_IT__c']) {
                    headofitlst.push(contact);
                    //console.log(headofitlst);
                } else if (record['Attendee__r']['Head_of_Security__c']) {
                    headofsecuritylst.push(contact);
                    //console.log(headofsecuritylst);
                } else if (record['Attendee__r']['Head_of_Networking__c']) {
                    headofnetworkinglst.push(contact);
                    //console.log(headofnetworkinglst);
                } else {
                    othercontactlst.push(contact);
                    //console.log(othercontactlst);
                }
            });
            cmp.set("v.headofitlst", headofitlst);
            cmp.set("v.headofsecuritylst", headofsecuritylst);
            cmp.set("v.headofnetworkinglst", headofnetworkinglst);
            cmp.set("v.othercontactlst", othercontactlst);
        }
    },
    saveinternalatt: function (cmp, event, helper) {
        let userlst = cmp.get("v.userList");
        let action = cmp.get("c.saveintattendees");
        //console.log(userlst);
        if (userlst.length < 1) {
            cmp.set("v.errorMsg", 'Please add at least one Internal Attendee');
            cmp.set('v.showSpinner', false);
            return;
        } else {
            cmp.set('v.errorMsg', '');
        }
        action.setParams({
            userList: JSON.stringify(userlst),
            ebId: cmp.get('v.recordId')
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                cmp.set('v.stepname', '3');
                cmp.set('v.showSpinner', false);
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
        
        
    saveexternalatt: function (cmp, event, helper) {
        let headofitlst = cmp.get('v.headofitlst');
        let headofsecuritylst = cmp.get('v.headofsecuritylst');
        let headofnetworkinglst = cmp.get('v.headofnetworkinglst');
        let othercontactlst = cmp.get('v.othercontactlst');
        let finalarr = [];
        finalarr = headofitlst.concat(headofsecuritylst, headofnetworkinglst, othercontactlst);
        console.log(finalarr);
        if (finalarr.length < 1) {
            cmp.set("v.errorMsg", 'Please add at least one External Attendee');
            cmp.set('v.showSpinner', false);
            return;
        } else {
            cmp.set('v.errorMsg', '');
        }
        let action = cmp.get("c.saveextattendees");
        action.setParams({
            conlst: JSON.stringify(finalarr),
            ebId: cmp.get('v.recordId')
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                window.open('/' + cmp.get('v.recordId'), '_self');
                cmp.set('v.errorMsg', '');
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
        
        
    populateOppdetails: function (component, event, helper, oppId, oppchanged, AccId) {
        //alert('--AccountId--'+AccId);
        let action = component.get("c.getData");
        action.setParams({
            oppId: oppId,
            ebId: component.get('v.recordId'),
            AccountId : AccId
        });
        action.setCallback(this, function (res) {
            if (res.getState() === 'SUCCESS') {
                var retObj = res.getReturnValue();
                console.log('populateOppdetails ::',retObj);
                if (retObj) {
                    if (retObj.opp) {
                        component.set('v.oppRec', retObj.opp);
                    }
                    if (retObj.prodvals) {
                        component.set('v.prodnames', retObj.prodvals);
                    }
                    if (retObj.Champion) {
                        component.set('v.championId', retObj.Champion);
                    }
                    if (retObj.econBuyer) {
                        component.set('v.econbuyerId', retObj.econBuyer);
                    }
                    if (retObj.currQtr) {
                        component.set('v.currQtr', retObj.currQtr);
                    }
                    if(retObj.EventBriefingReq){
                        if(retObj.EventBriefingReq.Is_Meeting_Confirmed__c == true){
                            component.set('v.IsMeetingConfirmed',true);
                        }else{
                            component.set('v.IsMeetingConfirmed',false);
                        }
                        if(retObj.EventBriefingReq.Date_of_Meeting__c != undefined){
                            component.set('v.DatoOfMeeting',retObj.EventBriefingReq.Date_of_Meeting__c);
                        }
                        if(retObj.EventBriefingReq.Approval_Status__c != undefined){
                            component.set('v.ApprovalStatus',retObj.EventBriefingReq.Approval_Status__c);
                        }
                        if(retObj.EventBriefingReq.Start_Date__c != undefined){
                            component.set('v.StartDate',retObj.EventBriefingReq.Start_Date__c);
                        }
                        if(retObj.EventBriefingReq.End_Date__c != undefined){
                            component.set('v.EndDate',retObj.EventBriefingReq.End_Date__c);
                        }
                    }
                    if(retObj.AccountRec){
                        component.set('v.AccountRec', retObj.AccountRec);
                    }
    
                    if(retObj.EventBriefingReq != undefined){
                        if(retObj.EventBriefingReq.Start_Time__c != undefined){
                        	component.set("v.StartTime",new Date(retObj.EventBriefingReq.Start_Time__c).toISOString().substr(11, 8)+'.000Z');
                        }
                        
                        if(retObj.EventBriefingReq.End_Time__c != undefined){
                        	component.set('v.EndTime',new Date(retObj.EventBriefingReq.End_Time__c).toISOString().substr(11, 8)+'.000Z');
                        }
                    }
    
                    if(retObj.InstallBase){
                        component.set("v.InstallBase",retObj.InstallBase);
                    }
                    
                    this.processexistingintattendee(component, retObj.intAttlst);
                    this.processexistingextattendee(component, retObj.extAttlst);
                    if(oppchanged){
                        this.prepopulate(component, event, helper, oppchanged);
                    }
                }
            } else if (res.getState() === 'ERROR') {
                var errors = res.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
            component.set("v.proceedload", true);
        });
        $A.enqueueAction(action);
    },
        
    prepopulate: function (cmp, event, helper, oppchanged) {
        console.log('inside new rec pre pop');
        
        if (cmp.get('v.accId')) {
            cmp.find('accountval').set("v.value", cmp.get('v.accId'));
        }
        
        if (cmp.get('v.oppId')) {
            
            if (!cmp.find('accountval').get("v.value")) {
                if (cmp.get('v.accId')) {
                    cmp.find('accountval').set("v.value", cmp.get('v.accId'));
    
                } else if (cmp.get('v.oppRec') && cmp.get('v.oppRec')['AccountId']) {
                    cmp.find('accountval').set("v.value", cmp.get('v.oppRec')['AccountId']);
                    cmp.set('v.accId', cmp.get('v.oppRec')['AccountId']);
                }
                let contactfiltercriteria = 'Active__c = false and ';
                contactfiltercriteria += ' AccountId = \'' + cmp.get('v.accId') + '\'';
                cmp.set("v.contactfiltercriteria", contactfiltercriteria);
            }
        
            if (!cmp.find('oppIdval').get("v.value")) {
                cmp.find('oppIdval').set("v.value", cmp.get('v.oppId'));
            }
            
            if (!cmp.get("v.stage") || oppchanged) {
                cmp.set("v.stage", cmp.get("v.oppRec")['StageName']);
            }
            if (!cmp.get("v.type") || oppchanged) {
                cmp.set("v.type", cmp.get("v.oppRec")['Type']);
            }
            if (!cmp.get("v.rsm") || oppchanged) {
                cmp.set("v.rsm", cmp.get("v.oppRec")['Owner']['Name']);
            }
            if (!cmp.get("v.tcv") || oppchanged) {
                cmp.set("v.tcv", cmp.get("v.oppRec")['TCV__c']);
            }
            if (!cmp.get("v.acv") || oppchanged) {
                cmp.set("v.acv", cmp.get("v.oppRec")['Amount']);
            }
            if (!cmp.get("v.closedate") || oppchanged) {
                cmp.set("v.closedate", cmp.get("v.oppRec")['CloseDate']);
            }
            
            if(cmp.get('v.isEdit') == false){
                cmp.set("v.products1",cmp.get('v.prodnames'));
            }else{
                cmp.set("v.products2",cmp.get('v.prodnames'));
            }
            if (!cmp.find('prods').get("v.value")){
                cmp.find('prods').set("v.value", cmp.get('v.prodnames'));
            }
            if (!cmp.find('exonomicbuyer').get("v.value") || oppchanged) {
                console.log(cmp.get('v.econbuyerId'));
                cmp.find('exonomicbuyer').set("v.value", cmp.get('v.econbuyerId'));
            }
            if (!cmp.find('champion').get("v.value") || oppchanged) {
                console.log(cmp.get('v.championId'));
                cmp.find('champion').set("v.value", cmp.get('v.championId'));
            }
        }

        
    },
    changecontactfilter: function (cmp, event, helper, accId) {
        let contactfiltercriteria = 'Active__c = false and ';
        contactfiltercriteria += ' AccountId = \'' + accId + '\'';
        cmp.set("v.contactfiltercriteria", contactfiltercriteria);
    },
    
    
})