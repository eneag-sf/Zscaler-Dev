import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import Account_Id from '@salesforce/schema/User.AccountId';
import Contact_Id from '@salesforce/schema/User.ContactId';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';


export default class createNewCase extends NavigationMixin(LightningElement) {
    @api recordId;
    @track accountId;
    @track contactId;
    @track caseId;
    @track showMod = false;
    @track loading = false;
    @api objectApiName;

    @track objectInfo;

    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Support');
    }

    @wire(getRecord, { recordId: USER_ID, fields: [Account_Id, Contact_Id] })
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
            this.accountId = data.fields.AccountId.value;
            this.contactId = data.fields.ContactId.value;
        }

    }
    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.AccountId = this.accountId;
        fields.ContactId = this.contactId;
        this.loading = true;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        this.caseId = updatedRecord;
        console.log('onsuccess: ', updatedRecord);
        this.navigateToRecordViewPage();
    }
    navigateToRecordViewPage() {
        // View a custom object record.
        this.loading = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: '' + this.caseId,
                actionName: 'view'
            }
        });
    }
    showModal(){
        this.showMod = true;
    }
    cancelCase(){
        this.showMod = false;
    }
}