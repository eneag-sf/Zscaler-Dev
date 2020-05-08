import { LightningElement, wire, track, api } from 'lwc';
import getPortalContent from '@salesforce/apex/CreateCaseController.getPortalContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseCreateRelatedLWC extends LightningElement {
    @track content = '';
    pathArray = window.location.pathname.split('/');
    portalname = this.pathArray[1];

    @wire(getPortalContent, {type: '$portalname'})
    wiredResult(results) {
        if (results.data) {
            this.content = results.data;
        }else{
            this.content = '';
            if (results.error) {
                let message = 'Unknown error';
                if (Array.isArray(results.error.body)) {
                    message = results.error.body.map(e => e.message).join(', ');
                } else if (typeof results.error.body.message === 'string') {
                    message = results.error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Portal Content',
                        message: '' + message,
                        variant: 'error',
                    }),
                );
            } 
        }
    }
}