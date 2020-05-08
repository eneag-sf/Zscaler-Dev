import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCloseReason from '@salesforce/apex/CaseEscalationController_LWC.closeCs';
import { fireEvent } from 'c/pubsub'


export default class caseCloseCustomerComponent extends LightningElement {
    @track showMod = false;
    @track reason = '';
    @track errormsg = '';
    @api caseId;

    @api
    showModal() {
        this.showMod = true;
    }

    assignreason(event) {
        this.reason = event.target.value;
    }

    closeModal() {
        this.showMod = false;
        this.reason = '';
    }

    savereasonforEsc() {
        if(!this.reason){
            this.errormsg = 'Please fill in the reason for closing the case';
            return;
        }
        this.errormsg = '';
        saveCloseReason({
            recId: this.caseId,
            reason: this.reason,
        }).then(result => {
            console.log(this.caseId);
            console.log(this.reason);
            console.log(result);
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
                    message: 'Case is Closed!',
                    variant: 'success'
                }));
            }
            this.showMod = false;
            this.reason = '';
            fireEvent(null, 'customerupdatedcase', null);
        })
            .catch(error => {
                let err = '' + error.message;
                this.showMod = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!!',
                    message: err,
                    variant: 'error'
                }));
                console.log(err);
                this.reason = '';
            });
    }
}