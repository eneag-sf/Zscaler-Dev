import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import saveCaseComment from '@salesforce/apex/CaseCommentController_LWC.saveCaseComment';
import { fireEvent } from 'c/pubsub'


const userfieldstoQuery = ['User.ContactId', 'User.Service_Level__c'];

export default class CaseCommentComponent extends LightningElement {
    @api recordId;
    @track usrinfo;
    @track comment = '';
    @track sendtoCust = false;
    @track showCaseDetails;
    @track isPortalUser = false;
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
                this.isPortalUser = true;
            } else if (this.usrinfo.fields.Service_Level__c.value != null) {
                this.isPortalUser = false;
            }
        }

    }

    assigncasecomment(event) {
        this.comment = event.target.value;
    }
    assignpublic(event) {
        this.sendtoCust = event.target.checked;
    }

    savecase(event) {
        if (this.comment == null || this.comment == undefined || this.comment == '') {
            this.errmsg = 'Case Comment cannot be blank.';
            this.showcommentmandatorymessage = true;
            return;
        }
        this.showcommentmandatorymessage = false;
        this.errmsg = '';
        this.loading = true;
        let contentIdsToSend;
        console.log(this.contentIds);
        if(this.contentIds){
            contentIdsToSend = this.contentIds;
        }
        console.log(this.recordId);
        
        
        saveCaseComment({ caseId: this.recordId, comment: this.comment, ispublic: this.isPortalUser, contDocIds: contentIdsToSend })
            .then(result => {

                this.showtoast('Save is Successful');
                this.cancelCase();
                fireEvent(null, 'casecommentposted', null);
            })
            .catch(error => {
                console.log(error);
                let message = error;
                if (error && error.body && error.body.pageErrors && error.body.pageErrors[0] && error.body.pageErrors[0].message) {
                    message = error.body.pageErrors[0].message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Saving Case Comment!',
                        message: '' + message,
                        variant: 'error',
                    }),
                );
                this.loading = false;
            });
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
        if(this.isPortalUser){
            const textarea = this.template.querySelectorAll(
                'lightning-input-rich-text'
            );
            if (textarea) {
                textarea.forEach(field => {
                    field.value = '';
                });
            }
        }else{
            const textarea = this.template.querySelectorAll(
                'lightning-textarea'
            );
            if (textarea) {
                textarea.forEach(field => {
                    field.value = '';
                });
            }
        }
        

    }

    //method added by Puneeth
    handleUploadFinish(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles) {
            uploadedFiles.forEach(file => {
                this.contentIds.push(file.documentId);
            });
        }
    }
}