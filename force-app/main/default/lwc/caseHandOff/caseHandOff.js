import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCaseHandoff from '@salesforce/apex/CaseEscalationController_LWC.caseHandoff';
import initcaseHandoff from '@salesforce/apex/CaseEscalationController_LWC.initcaseHandoff';
import { refreshApex } from '@salesforce/apex';


export default class CaseHandOff extends LightningElement {
    @api recordId;
    @track loading = false;
    @track showCaseDetails = false;

    @track errmsg = '';
    wiredResult;
    @track errmsgclass = '';


    @wire(initcaseHandoff, { recId: '$recordId' })
    caseDetails(results) {
        this.wiredResult = results;
        if (results.data) {
            this.showCaseDetails = results.data.showhandoff;
            this.errmsg = '';
            this.errmsgclass = '';
            if(results.data.showEscalated){
                this.errmsg = 'Case has been successfully Escalated';
                this.errmsgclass = 'slds-box slds-theme--success';
            }else if(results.data.showInsuff){
                this.errmsg = 'You do not have the privilege to Escalate Case';
                this.errmsgclass = 'slds-box slds-theme--warning';
            }
        }
        else if (results.error) {
            let error = results.error;
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Details in Case Escalation Component',
                    message: '' + message,
                    variant: 'error',
                }),
            );
        }
    }

    savecase(event) {

        if (this.showCaseDetails) {
            if (!this.reason) {
                this.errmsg = 'Please fill the reason for Case Escalation';
                this.errmsgclass = 'slds-box slds-theme--error';
                return;
            }
            this.errmsg = '';
            this.errmsgclass = '';
            console.log(this.errmsg);
            console.log(this.errmsgclass);
            saveCaseHandoff({
                recId: this.recordId,
                reason: this.reason,
            }).then(result => {
                let message = '' + result;
                if (result != 'Success') {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!!',
                        message: message,
                        variant: 'error'
                    }));
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Case is Escalated!',
                        variant: 'success'
                    }));
                }
                this.reason = '';
                this.cancelCase();
            })
                .catch(error => {
                    let err = '' + error.message;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!!',
                        message: err,
                        variant: 'error'
                    }));
                    console.log(err);
                    this.reason = '';
                    this.cancelCase();
                });
        }
    }


    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Case Status Updated!',
                message: '' + mes,
                variant: 'success',
            }),
        );
    }
    cancelCase() {
        this.loading = false;
        console.log('inside cancel case');
        const inputFields = this.template.querySelectorAll(
            'lightning-textarea'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = '';
            });
        }
        this.refreshdata();

    }
    assignreason(event) {
        this.reason = event.target.value;
    }
    refreshdata() {
        return refreshApex(this.wiredResult);
    }
}