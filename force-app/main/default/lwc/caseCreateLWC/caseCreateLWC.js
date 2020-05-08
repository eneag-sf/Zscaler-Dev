import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import USER_ID from '@salesforce/user/Id';
import Case_Object from '@salesforce/schema/Case';
import { getRecord } from 'lightning/uiRecordApi';

import saveFile from '@salesforce/apex/CreateCaseController.saveFile';
import saveCaseRecord from '@salesforce/apex/CreateCaseController.saveCaseRecord';
const userfieldstoQuery = ['User.ContactId', 'User.Service_Level__c', 'User.AccountId', 'User.TimeZoneSidKey', 'User.Phone'];


export default class caseCreateLWC extends LightningElement {
    //file upload
    @api recordId;
    @api showAccount;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track loading = true;
    @track isSubmitted = false;
    @track errmsg = '';
    @track accountId = '';
    @track ContactId = '';
    @track phonenum = '';
    @track timezone = '';
    @track recordTypeId = '';
    @track showPriorityMessage = false;
    @track remChars = '9950 characters remaining';
    @track userId = USER_ID;
    @track contentIds = [];

    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;
    @track caseRecord = {};

    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    handleFieldChange(e) {
        this.caseRecord[e.currentTarget.fieldName] = e.target.value;
    }

    get loadData() {
        // Returns a map of record type Ids 
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.recordTypeInfos) {
            const rtis = this.objectInfo.data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
        } else if (this.objectInfo && this.objectInfo.data) {
            this.recordTypeId = '$objectInfo.data.defaultRecordTypeId';
        }
        this.caseRecord['RecordTypeId'] = this.recordTypeId;
        if (this.recordTypeId && (this.accountId || this.phonenum || this.timezone) && !this.isSubmitted) {
            this.loading = false;
        }
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        if (portalname == 'partners') {
            this.showAccount = true;
        }
        return (this.recordTypeId && (this.accountId || this.phonenum || this.timezone));

    }

    @wire(getRecord, { recordId: USER_ID, fields: userfieldstoQuery })
    wireuser({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Logged in User Request',
                    message: '' + message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.usrinfo = data;
            if (this.usrinfo.fields.AccountId.value) {
                this.accountId = this.usrinfo.fields.AccountId.value;
            }
            if (this.usrinfo.fields.ContactId.value) {
                this.ContactId = this.usrinfo.fields.ContactId.value;
            }
            if (this.usrinfo.fields.Phone.value) {
                this.phonenum = this.usrinfo.fields.Phone.value;
                this.caseRecord['Preferred_Contact_Number__c'] = this.phonenum;
            }
            if (this.usrinfo.fields.TimeZoneSidKey.value) {
                this.timezone = this.usrinfo.fields.TimeZoneSidKey.value;
                this.caseRecord['Preferred_Contact_Time_Zone__c'] = this.timezone;
            }

        }

    }

    handleSubmit(event) {
        if(this.errmsg){
            window.scrollTo(0, 0);
            event.preventDefault();  
            return;
        }
        this.loading = true;
        this.isSubmitted = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;

        this.caseRecord['ContactId'] = this.ContactId;
        if (!this.showAccount) {
            this.caseRecord['AccountId'] = this.accountId;
        }
        if (!fields.AccountId) {
            this.caseRecord['AccountId'] = this.accountId;
        }
        let Origin = '';
        if (!this.showAccount) {
            Origin = 'Support Portal';
        } else {
            Origin = 'Partner Portal';
        }
        this.caseRecord['Origin'] = Origin;
        saveCaseRecord({ objCase: this.caseRecord, contDocIds: this.contentIds })
            .then(result => {
                this.loading = true;
                this.recordId = result;
                //this.handleFileSave();
                this.cancelCase();
                this.navigateToRecordViewPage();
            })
            .catch(error => {
                // Showing errors if any while inserting the files
                console.log(error);
                if (error) {
                    let message = 'Error: ';
                    if (Array.isArray(error.body)) {
                        message += error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        message += error.body.message;
                    }else if (error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message  && error.body.pageErrors[0].message.indexOf("INVALID_MARKUP") != -1) {
                        message += 'HTML Tags are not supported in Description';
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Saving Case',
                            message : ''+ message,
                            variant: 'error',
                        }),
                    );
                }
                this.loading = false;
            });
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        
    }
    handleError(event) {
        this.loading = false;
    }
    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Submitted!',
                message: '' + mes,
                variant: 'success',
            }),
        );
    }
    cancelCase() {
        
        this.contentIds = [];
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

    handleCancel() {
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        window.location = '/' + portalname + '/s/';
    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }
    handleFileSave() {

        if (this.filesUploaded.length > 0) {
            this.uploadHelper();
        } else {
            this.showtoast('Case created successfully');
            this.cancelCase();
            this.navigateToRecordViewPage();
        }
    }
    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log('File Size is too long');
            return;
        }
        // create a FileReader object 
        this.fileReader = new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);

            // call the uploadProcess method 
            this.saveToFile();
        });

        this.fileReader.readAsDataURL(this.file);
    }

    saveToFile() {
        saveFile({ idParent: this.recordId, strFileName: this.file.name, base64Data: encodeURIComponent(this.fileContents) })
            .then(result => {
                this.fileName = this.fileName + ' - Uploaded Successfully';
                this.UploadFile = 'File Uploaded Successfully';
                // Showing Success message after file insert
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Case created successfully',
                        variant: 'success',
                    }),
                );
                this.cancelCase();
                this.fileName = '';
                this.navigateToRecordViewPage();
            })
            .catch(error => {
                // Showing errors if any while inserting the files
                if (error) {
                    let message = 'Error: ';
                    if (Array.isArray(error.body)) {
                        message = error.body.map(e => e.message).join(', ');
                    } else if (typeof error.body.message === 'string') {
                        message = error.body.message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while uploading File',
                            message : ''+ message,
                            variant: 'error',
                        }),
                    );
                }
            });
    }
    navigateToRecordViewPage() {
        // View a custom object record.
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        window.location = '/' + portalname + '/s/case/' + this.recordId;
    }
    changeProduct(event) {
        if (event.detail.value == 'Urgent (P1)') {
            this.showPriorityMessage = true;
        } else {
            this.showPriorityMessage = false;
        }
        this.handleFieldChange(event);
    }
    handleDescchange(event){
        let desc = event.detail.value;
        
        if(event.detail.value){
            desc = '';
            event.detail.value.split("\n").forEach(function(el){
                if(el){
                    desc += '<p>'+el+'</p>';
                }else{
                    desc += '<p>&nbsp;</p>';
                }
                
            });
            if(desc.length > 9950){
                this.errmsg = 'Description cannot be more than 9950 characters.';
                this.remChars = 'Description cannot be more than 9950 characters.';
            }else{
                this.errmsg = '';
                this.remChars = 9950 - desc.length + ' characters remaining.';
                this.caseRecord['Description'] = desc;
            }
        }else{
            this.remChars = '9950 characters remaining';
            this.caseRecord['Description'] = desc;
        }
    }
    handleUploadFinish(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            uploadedFiles.forEach(file => {
                this.contentIds.push(file.documentId);
            });
        }
    }
}