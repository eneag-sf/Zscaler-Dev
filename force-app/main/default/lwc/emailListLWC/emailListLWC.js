import { LightningElement, track, wire, api } from 'lwc';
import retriveCase from '@salesforce/apex/CaseDetailLWCController.fetchCase';
import getDomainstoExcludeList from '@salesforce/apex/CaseDetailLWCController.getDomains';
import COMMENTBODY_FIELD from '@salesforce/schema/CaseComment.CommentBody';
import PARENTID_FIELD from '@salesforce/schema/CaseComment.ParentId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContact from '@salesforce/apex/CaseDetailLWCController.createContact';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import ID_FIELD from '@salesforce/schema/Contact.Id';
import retriveEmailList from '@salesforce/apex/CaseDetailLWCController.fetchEmailList';
import updateContactDetails from '@salesforce/apex/CaseDetailLWCController.updateContact';
import deleteContactDetails from '@salesforce/apex/CaseDetailLWCController.deleteContact';
import getAccountContacts from '@salesforce/apex/CaseDetailLWCController.fetchAccountContacts';
import addMultiContactToCaseTeamMember1 from '@salesforce/apex/CaseDetailLWCController.addMultiContactToCaseTeamMember';
import addMultiUserToCaseTeamMember1 from '@salesforce/apex/CaseDetailLWCController.addMultiUserToCaseTeamMember';
import getCaseMember from '@salesforce/apex/CaseDetailLWCController.fetchUserCaseTeamMember';

import getUsers from '@salesforce/apex/CaseDetailLWCController.fetchUsers';
import addContactToCTM from '@salesforce/apex/CaseDetailLWCController.addContactToCaseTeamMember';
import addUserToCTM from '@salesforce/apex/CaseDetailLWCController.addUserToCaseTeamMember';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_TYPE_FIELD from '@salesforce/schema/Contact.Contact_Type__c';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import fetchUserDetails from '@salesforce/apex/CaseDetailLWCController.getUserDetails';




import { refreshApex } from '@salesforce/apex';

let i=0;
export default class emailListLWC extends LightningElement {
    @track caseId;
    @track caseData;
    @track contactData;
    @track emailList;
    @track userMemberList;
    @track contactTeamMember = [];
    @track userTeamMember = [];
    @track contactId;
    @track selectedOptionsList1;
    @track error;
    @track commentBody = COMMENTBODY_FIELD;
    @track parId = PARENTID_FIELD;
    @track loading = true;
    rec = {
        CommentBody: this.commentBody,
        ParentId: this.parId
    }
    @track userLicense;
    @track isUserLicense = false;
    @track data;
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track firstName;
    @track lastName;
    @track email;
    @track errormsg = '';
    @track items = [];
    @track useritems = [];
    emailRefreshData;
    @track openColla = false;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;
    @track showcommentmandatorymessage = false;
    @track blockedemails = [];
    @track zsValue;
    @track listOptions = [];
    @track defaultOptions = [];
    @track ctRecord = {
        FirstName: FIRSTNAME_FIELD,
        LastName: LASTNAME_FIELD,
        Email: EMAIL_FIELD,
        Id: ID_FIELD,
        Contact_Type__c: CONTACT_TYPE_FIELD,
        Title: TITLE_FIELD
    };
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CONTACT_TYPE_FIELD})
    contactTypeValues;

    @wire(retriveCase, { strObjectName: '$caseId' })
    cases({ data, error }) {
        if (data) {
         
            this.caseData = data;
            if(this.caseData[0].Account)
            this.zsValue = this.caseData[0].Account.Id;
            this.error = undefined;
        }
        else if (error) {
            this.caseData = undefined;
            this.error = error;
        }
    }
    
    @wire(getDomainstoExcludeList)
    domainstoExclude({ data, error }) {
        if (data) {
            this.blockedemails = data;
            this.error = undefined;
        }
        else if (error) {
            this.blockedemails = undefined;
            this.error = error;
        }
    }

    @wire(retriveEmailList, { csId: '$caseId' })
    emailListData(value) {
        this.emailRefreshData = value;
        const { data, error } = value;
        if (data) {
            this.emailList = data;
            // eslint-disable-next-line guard-for-in
            this.contactTeamMember = [];
            for(var cntMember in this.emailList)  {
                if(this.emailList[cntMember].Id && this.emailList[cntMember].Id != null && this.emailList[cntMember].Id != undefined && this.emailList[cntMember].Id != '' )  {
                    this.contactTeamMember.push(this.emailList[cntMember].Id);
                }
            }
            console.log('this.contactTeamMember:-'+JSON.stringify(this.contactTeamMember));
            if(this.zsValue != 'Zscaler')  {
            this.defaultOptions = this.contactTeamMember;
            }
            console.log('this.defaultOptions:-'+JSON.stringify(this.defaultOptions));

          //  console.log('emailist:-'+JSON.stringify(defaultOptions));
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.emailList = undefined;
            this.error = error;
            this.loading = false;
        }
    }
    @wire(getCaseMember, { csId: '$caseId' })
    caseMemberData(value) {
        const { data, error } = value;
        if (data) {
            this.userMemberList = data;
            // eslint-disable-next-line guard-for-in
            this.userTeamMember = [];
            for(var cntMember in this.userMemberList)  {
                if(this.userMemberList[cntMember].MemberId && this.userMemberList[cntMember].MemberId != null && this.userMemberList[cntMember].MemberId != undefined && this.userMemberList[cntMember].MemberId != '' )  {
                    this.userTeamMember.push(this.userMemberList[cntMember].MemberId);
                }
            }
           // this.defaultOptions = this.userTeamMember;
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.userMemberList = undefined;
            this.error = error;
            this.loading = false;
        }
    }
    @wire(getAccountContacts, { csId: '$caseId' })
    contactListData(value) {
        this.contactData = value;
        const { data, error } = value;
        if (data) {
            for(i=0; i<data.length; i++)  {
                
                this.items = [...this.items ,{value: data[i].Id , label: data[i].Name + ' ( '+data[i].Email+' )' } ];                                   
            } 
            this.listOptions =this.items;
           
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.items = undefined;
            this.error = error;
            this.loading = false;
        }
    }
    @wire(getUsers, { csId: '$caseId' })
    userListData(value) {
        const { data, error } = value;
        if (data) {
            for(i=0; i<data.length; i++)  {
                this.useritems = [...this.useritems ,{value: data[i].Id , label: data[i].Name  + ' ( '+data[i].Email+' )' } ];                                   
            } 
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.useritems = undefined;
            this.error = error;
            this.loading = false;
        }
    }
    @wire(fetchUserDetails, { csId: '$caseId' })
    userLicenseData(value) {
        const { data, error } = value;
        if (data) {
            console.log('license Name:-'+JSON.stringify(data));
            this.userLicense = data;
            if(this.userLicense == 'Customer Community Login'){
                this.isUserLicense = true;
            }else{
                this.isUserLicense = false;
            }
        }
        else if (error) {
            console.log('Error:-'+JSON.stringify(error));

            this.useritems = undefined;
            this.error = error;
            this.loading = false;
        }
    }
    

    handleZscalerChange(event) {
        this.zsValue = event.detail.value;
        if(this.zsValue == 'Zscaler')  {
            this.listOptions =this.useritems;
            this.defaultOptions = this.userTeamMember;
        }else  {
            this.listOptions =this.items;
            this.defaultOptions = this.contactTeamMember;
        }
    }


    get options() {
        if(this.userLicense == 'Customer Community Login'){
            if(this.caseData[0].Account) {
                return [
                    { label: this.caseData[0].Account.Name, value: this.caseData[0].Account.Id}
                    ];
            }else  {
                return [];
            }
        }

        if(this.caseData[0].Account) {
            return [
                { label: 'Zscaler', value: 'Zscaler' },
                { label: this.caseData[0].Account.Name, value: this.caseData[0].Account.Id}
            ];
        } else  {
            return [
                { label: 'Zscaler', value: 'Zscaler' }
             
            ];  
         }
    }
    get userOptions() {
        return this.useritems;
    }
    get roleOptions() {
        return this.items;
    }
   
    handleContactTypeChange(event) {
        this.ctRecord.Contact_Type__c = event.detail.value;
    }
    handleFirstNameChange(event) {
        this.ctRecord.FirstName = event.target.value;
    }
    handleLastNameChange(event) {
        this.ctRecord.LastName = event.target.value;
    }
    handleTitleChange(event){
        this.ctRecord.Title = event.target.value;
    }
    handleEmailChange(event) {
        let reg = /^([A-Za-z0-9_\-\.\&])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (reg.test(event.target.value)) {
            if (event.target.value) {
                let publicemail = false;
                for (let i = 0; i < this.blockedemails.length; i++) {
                    if (event.target.value.indexOf(this.blockedemails[i]) != -1) {
                        this.errormsg = 'Public Email domains cannot be entered';
                        this.showcommentmandatorymessage = true;
                        publicemail = true;
                    }
                }
                if (!publicemail) {
                    this.errormsg = '';
                    this.showcommentmandatorymessage = false;
                    this.ctRecord.Email = event.target.value;
                }
            }

        } else {
            this.errormsg = 'Invalid Email';
            this.showcommentmandatorymessage = true;
        }
    }
    saveMultiTeamMember(event)  {
        if(this.zsValue == 'Zscaler')  {
            addMultiUserToCaseTeamMember1({ objCtId: this.selectedOptionsList1, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case Team Members Added',
                        variant: 'success'
                    })
                );
                this.loading = false;
                refreshApex(this.emailRefreshData);
                this.userTeamMember = [];
                for(var k1 in this.selectedOptionsList1)  {
                    this.userTeamMember.push(this.selectedOptionsList1[k1]);
                }
                this.defaultOptions = this.userTeamMember;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding Case Team Members',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }else  {
            addMultiContactToCaseTeamMember1({ objCtId: this.selectedOptionsList1, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case Team Members Added',
                        variant: 'success'
                    })
                );
                this.loading = false;
                refreshApex(this.emailRefreshData);
            })
            .catch(error => {
                console.log('error:-'+error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding Case Team Members',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }

    handleContactSave(event) {
        if(!this.ctRecord.LastName || !this.ctRecord.Email){
            this.errormsg = 'Email and Last Name fields are Mandatory';
            this.showcommentmandatorymessage = true;
            return;
        }
        if(this.errormsg){
            return;
        }
        this.loading = true;
        if (this.addMode) {
            this.ctRecord.Id = null;
            createContact({ objCt: this.ctRecord, caseId: this.caseId })
                .then(result => {
                    this.ctRecord = {};
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Contact Created Successfully!!',
                        variant: 'success'
                    }));
                    //this.openmodel = false;
                    this.loading = false;

                    this.items.push({value: result.Id , label: result.FirstName +' '+ result.LastName + ' ( '+result.Email+' )' } ); 
                    this.listOptions = this.items;  
                    this.contactTeamMember.push(result.Id);
                    this.defaultOptions = this.contactTeamMember;
                    refreshApex(this.emailRefreshData);
                })
                .catch(error => {
                    this.error = error.message;
                    this.openmodel = false;
                });
        }
        if (this.editMode) {
            this.ctRecord.Id = this.contactId;
            this.loading = true;
            updateContactDetails({ objCt: this.ctRecord, caseId: this.caseId })
                .then(result => {
                    this.ctRecord = {};
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Contact Updated Successfully!!',
                        variant: 'success'
                    }));
                    this.openmodel = false;
                    this.loading = false;
                    refreshApex(this.emailRefreshData);
                })
                .catch(error => {
                    this.error = error.message;
                    this.openmodel = false
                });
        }
    }
    handleEditEmail(event1) {
        this.ctRecord.FirstName = event1.target.dataset.fname;
        this.ctRecord.LastName = event1.target.dataset.lname;
        this.ctRecord.Email = event1.currentTarget.dataset.email;
        this.contactId = event1.currentTarget.dataset.contactid;
        this.addMode = false;
        this.editMode = true;
        this.openmodel = true;
    }
    handleDeleteEmail(event) {
        this.contactId = event.currentTarget.dataset.contactid;
        this.loading = true;
        deleteContactDetails({ objCtId: this.contactId, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email deleted',
                        variant: 'success'
                    })
                );
                refreshApex(this.emailRefreshData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting Email',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleDualListChange(event) {
        this.selectedOptionsList1 = event.detail.value;
    }
    openmodal() {
        this.ctRecord = {};
        this.addMode = true;
        this.editMode = false;
        this.openmodel = true;
        this.openColla = false;
    }
    openCollaborator(){
        this.openColla = true;
    }
    closeCollaborator(){
        this.openColla = false;
    }
    closeModal() {
        this.addMode = false;
        this.editMode = false;
        this.openmodel = false
    }
    connectedCallback() {
        var str = window.location.href;
        var extracted = str.split("/").find(function (v) {
            return v.indexOf("500") > -1;
        });
        this.caseId = extracted;
    }
    parId = this.caseId;
}