import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';
import saveCaseComment from '@salesforce/apex/MasterCaseFlow.saveCaseComment';
import { fireEvent } from 'c/pubsub'


const userfieldstoQuery = ['User.ContactId', 'User.Service_Level__c'];
const casefieldstoQuery = ['Case.Status'];

export default class MasterCaseComponent extends LightningElement {
    @api recordId;
    @track usrinfo;
    @track comment = '';
    @track sendtoCust = false;
    @track pushcommenttochildcases = 'No';
    @track sharewithcustomers = 'No';
    @track showCaseDetails;
    @track showclosedetails = false;
    @track loading = false;
    @track contentIds = [];
    @track objectInfo;
    @track showcommentmandatorymessage = false;
    @track errmsg = '';
    @track formats = ['font', 'size', 'bold', 'italic', 'underline', 'strike', 
    'list', 'indent', 'align', 'link', 
    'image', 'clean', 'table', 'header',
    'code', 'script', 'blockquote', 'direction', 'code-block'];
    

    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.recordTypeInfos) {
            const rtis = this.objectInfo.data.recordTypeInfos;
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Master Case');
        }
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
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.usrinfo = data;
            if (this.usrinfo.fields.ContactId.value != null) {
                this.showCaseDetails = false;
            } else if (this.usrinfo.fields.Service_Level__c.value != null) {
                this.showCaseDetails = true;
            }
        }

    }
    @wire(getRecord, { recordId: '$recordId', fields: casefieldstoQuery })
    wirecontact({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            if (data.fields.Status.value == 'Closed') {
                this.showclosedetails = true;
            }
        }
    }
    assigncasecomment(event) {
        this.comment = event.target.value;
    }
    assignpublic(event) {
        //this.sendtoCust = event.target.checked;
        this.sendtoCust = event.target.value;
    }
    
    assignchildcases(event)
    {
        this.pushcommenttochildcases  = event.target.value;
    
    }
    assigntocustomeremails(event)
    {
        this.sharewithcustomers = event.target.value;
    }

    savecase(event) {
        if(this.comment == null || this.comment == undefined || this.comment == ''){
            this.errmsg = 'Case Comment cannot be blank.';
            this.showcommentmandatorymessage = true;
            return;
        }
       
        this.showcommentmandatorymessage = false;
        this.errmsg = '';
        this.loading = true;
        console.log(this.comment);
        console.log(this.sendtoCust);
        console.log(this.pushcommenttochildcases);
        console.log(this.sharewithcustomers);

        let contentIdsToSend;
        if(this.showCaseDetails === false || this.sendtoCust === true){
            contentIdsToSend = this.contentIds;
        }
        saveCaseComment({ caseId: this.recordId, pushComments: this.pushcommenttochildcases, pushEmails: this.sharewithcustomers, comment: this.comment, ispublic: this.sendtoCust, contDocIds: contentIdsToSend })
            .then(result => {
                if (this.showCaseDetails) {
                    this.template.querySelector('lightning-record-edit-form').submit();
                } else {
                    this.showtoast('Save is Successful');
                    this.cancelCase();
                    fireEvent(null, 'casecommentposted', null);
                }
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Saving Case Comment!',
                        error,
                        variant: 'error',
                    }),
                );
            });
    }

    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
        this.showtoast('Save is Successful');
        this.cancelCase();
        fireEvent(null, 'casecommentposted', null);
    }
    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Comment Updated!',
                mes,
                variant: 'success',
            }),
        );
    }
    cancelCase() {
        this.loading = false;
        this.sendtoCust = false;
        this.contentIds = [];
        console.log('inside cancel case');
        if (this.showCaseDetails) {
            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );
            if (inputFields) {
                inputFields.forEach(field => {
                    field.reset();
                });
            }

            const checkboxes = this.template.querySelectorAll(
                'lightning-input'
            );
            if (checkboxes) {
                checkboxes.forEach(field => {
                    field.checked = false;
                });
            }
        }

        const textarea = this.template.querySelectorAll(
            'lightning-input-rich-text'
        );
        if (textarea) {
            textarea.forEach(field => {
                field.value = '';
            });
        }

    }
    statuschange(event) {
        if (event.detail.value == 'Closed') {
            this.showclosedetails = true;
        } else {
            this.showclosedetails = false;
        }
    }
    
    //method added by Puneeth
    handleUploadFinish(event){
        const uploadedFiles = event.detail.files;
        if(uploadedFiles){
            uploadedFiles.forEach(file => {
                this.contentIds.push(file.documentId);                
            });            
        }   
    }
}