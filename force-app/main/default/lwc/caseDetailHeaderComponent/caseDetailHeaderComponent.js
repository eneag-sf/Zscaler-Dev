import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { refreshApex } from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';

const casefieldstoQuery = ['Case.Status', 'Case.Subject', 'Case.IsEscalated', 'Case.CaseNumber', 'Case.ClosedDate', 'Case.IsClosed'];

export default class CaseDetailHeaderComponent extends LightningElement {
    @api recordId;
    @track showclosedetails = false;
    @track isClosed = false;
    @track statuscss;
    @track caseSubject;
    @track caseHeader;
    @track caseStatus;
    @track escalatedCase;
    wiredResult;
    @wire(CurrentPageReference) pageRef

    @wire(getRecord, { recordId: '$recordId', fields: casefieldstoQuery })
    wireCase(results) {
        this.wiredResult = results;
        if (results.error) {
            let message = 'Unknown error';
            if (Array.isArray(results.error.body)) {
                message = results.error.body.map(e => e.message).join(', ');
            } else if (typeof results.error.body.message === 'string') {
                message = results.error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details',
                    message: '' + message,
                    variant: 'error',
                }),
            );
        } else if (results.data) {
            let todaydate = new Date();
            let relativedate = this.addDays(todaydate, -15);
            let casecloseddate = new Date(results.data.fields.ClosedDate.value);
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request') && casecloseddate >= relativedate) {
                this.showclosedetails = true;
            }else{
                this.showclosedetails = false;
            }
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request')) {
                this.isClosed = true;
            }else{
                this.isClosed = false;
            }
            this.caseHeader = 'Case: ' + results.data.fields.CaseNumber.value;
            this.caseSubject = results.data.fields.Subject.value;
            this.caseStatus = results.data.fields.Status.value;
            this.escalatedCase = results.data.fields.IsEscalated.value;
            if ((results.data.fields.IsClosed.value || results.data.fields.Status.value == 'Customer Close Request')) {
                this.statuscss = 'zs-closed-status';
            } else if (results.data.fields.Status.value == 'Pending Customer' || results.data.fields.Status.value == 'Pending Fix Verification') {
                this.statuscss = 'zs-pending-status';
            } else {
                this.statuscss = 'zs-open-status';
            }
        }
    }
    escalateCase() {
        this.template.querySelector('c-customer-escalation-l-w-c').showModal();
    }
    closeCase() {
        this.template.querySelector('c-case-close-customer-component').showModal();
    }
    reOpenCase() {
        this.template.querySelector('c-customer-case-reopen-component').showModal();
    }
    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('customerupdatedcase', this.refreshdata, this);
    }
    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }
    refreshdata() {
        return refreshApex(this.wiredResult);
    }
    addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }
}