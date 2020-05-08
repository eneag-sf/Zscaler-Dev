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
import getUsers from '@salesforce/apex/CaseDetailLWCController.fetchUsers';
import addContactToCTM from '@salesforce/apex/CaseDetailLWCController.addContactToCaseTeamMember';
import addUserToCTM from '@salesforce/apex/CaseDetailLWCController.addUserToCaseTeamMember';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_TYPE_FIELD from '@salesforce/schema/Contact.Contact_Type__c';
import TITLE_FIELD from '@salesforce/schema/Contact.Title';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';


import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Title', fieldName: 'Title' }
];
let i=0;
export default class emailListLWC extends LightningElement {
    @track caseId;
    @track caseData;
    @track contactData;
    @track contactNameMap=[];
    @track emailList;
    @track contactTeamMember = [];
    @track userTeamMember = [];
    @track contactList;
    @track contactId;
    @track selectedContact;
    @track selectedUser;
    @track selectedOptionsList1;
    @track error;
    @track commentBody = COMMENTBODY_FIELD;
    @track parId = PARENTID_FIELD;
    @track loading = true;
    rec = {
        CommentBody: this.commentBody,
        ParentId: this.parId
    }
    //file upload
    @api recordId;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track firstName;
    @track lastName;
    @track email;
    @track errormsg = '';
    @track items = [];
    @track useritems = [];
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    emailRefreshData;
    MAX_FILE_SIZE = 1500000;
    @track openColla = false;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;
    @track showcommentmandatorymessage = false;
    @track blockedemails = [];
    @track zsValue;
    @track str;
    @track
    listOptions = [];
    
    @track
    defaultOptions = [];

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
            this.zsValue = this.caseData[0].Account.Id;
            console.log(JSON.stringify(this.caseData));
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
            
            for(var cntMember in this.emailList)  {
                console.log(this.emailList[cntMember].Id);
                if(this.emailList[cntMember].Id && this.emailList[cntMember].Id != null && this.emailList[cntMember].Id != undefined && this.emailList[cntMember].Id != '' )  {
                    this.contactTeamMember.push(this.emailList[cntMember].Id);
                }
            }
            this.defaultOptions = this.contactTeamMember;
            console.log('emailist:-'+JSON.stringify(data));
            this.error = undefined;
            this.loading = false;
        }
        else if (error) {
            this.emailList = undefined;
            this.error = error;
            this.loading = false;
        }
    }

    //TODO : Get list of all CaseMember with teamrole as Internal.


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

    handleZscalerChange(event) {
        this.zsValue = event.detail.value;
        if(this.zsValue == 'Zscaler')  {
            this.listOptions =this.useritems;
            this.defaultOptions = this.userTeamMember;
        }else  {
            this.listOptions =this.items;
            this.defaultOptions = this.contactTeamMember;
        }
        console.log(this.zsValue);
    }

    get options() {
        return [
            { label: 'Zscaler', value: 'Zscaler' },
            { label: this.caseData[0].Account.Name, value: this.caseData[0].Account.Id}
        ];
    }
    get userOptions() {
        return this.useritems;
    }
    get roleOptions() {
        return this.items;
    }
    addContact(event){
        console.log('addContact:-'+this.selectedContact);
        this.loading = true;
        addContactToCTM({ objCtId: this.selectedContact, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact Added',
                        variant: 'success'
                    })
                );
                this.loading = false;
                refreshApex(this.emailRefreshData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding Contact',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    addUser(event){
        console.log('addContact:-'+this.selectedUser);
        this.loading = true;
        addUserToCTM({ objCtId: this.selectedUser, caseId: this.caseId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'User Added',
                        variant: 'success'
                    })
                );
                this.loading = false;
                refreshApex(this.emailRefreshData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding User',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleContactTypeChange(event) {
        console.log(event.detail.value);
        this.ctRecord.Contact_Type__c = event.detail.value;
    }
    handleSelectedValue(event){
        this.selectedContact = event.target.value;
        console.log('contact:-'+event.target.value);
    }
    handleUserSelectedValue(event){
        this.selectedUser = event.target.value;
        console.log('contact:-'+event.target.value);
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
        console.log(this.zsValue);
        console.log(this.selectedOptionsList1);
        console.log(JSON.stringify(this.selectedOptionsList1));
        if(this.zsValue == 'Zscaler')  {
            //TODO : Save UserTeamMember
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
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Adding Contact',
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
                    // Clear the user enter values
                    this.ctRecord = {};
                    // Show success messsage
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Contact Created Successfully!!',
                        variant: 'success'
                    }));
                    this.openmodel = false;
                    this.loading = false;
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
                    // Clear the user enter values
                    this.ctRecord = {};
                    // Show success messsage
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
        // Get the list of the "value" attribute on all the selected options
        const selectedOptionsList = event.detail.value;
        this.selectedOptionsList1 = event.detail.value;
        console.log(`Options selected: ${selectedOptionsList}`);
    }
    openmodal() {
        console.log('Openmodal');
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