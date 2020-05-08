import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';


const casefieldstoQuery = ['Case.Status','Case.RecordTypeId'];

export default class CaseStatusUpdateComponent extends LightningElement {
    @api recordId;
    @track usrinfo;
    @track showCaseDetails;
    @track isPortalUser = false;
    @track showclosedetails = false;
    @track loading = false;
    @track objectInfo;
    @track showcommentmandatorymessage = false;
    @track errmsg = '';
    @track loadData  = false;

    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    /*get recordTypeId() {
        // Returns a map of record type Ids 
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.recordTypeInfos) {
            const rtis = this.objectInfo.data.recordTypeInfos;
            return Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
        }
    }*/

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
            if (data.fields.RecordTypeId.value) {
                this.recordTypeId = data.fields.RecordTypeId.value;
                this.loadData = true;
            }
        }
    }


    savecase(event) {
        this.errmsg = '';
        if (this.showclosedetails) {
            if (!this.template.querySelector('.Case_Category__c').value) {
                this.errmsg += 'Case Category'
            }
            if (!this.template.querySelector('.Case_Sub_Category__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Case Sub Category'
            }
            if (!this.template.querySelector('.Resolution_Summary__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Resolution Summary'
            }
            if (!this.template.querySelector('.Resolution_Type__c').value) {
                if (this.errmsg) {
                    this.errmsg += ', ';
                }
                this.errmsg += 'Resolution Type'
            }
            if (this.errmsg) {
                this.errmsg = 'Please fill the following fields: ' + this.errmsg;
                this.showcommentmandatorymessage = true;
                return;
            }
        }
        this.showcommentmandatorymessage = false;
        this.errmsg = '';
        this.loading = true;
        this.template.querySelector('lightning-record-edit-form').submit();

    }

    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        this.showtoast('Save is Successful');
        this.cancelCase();
    }
    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Status Updated!',
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
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
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

}