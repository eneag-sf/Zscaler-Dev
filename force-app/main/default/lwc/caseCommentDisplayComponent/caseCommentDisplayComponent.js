import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCaseComments from '@salesforce/apex/CaseCommentController_LWC.getCaseComments';
import { refreshApex } from '@salesforce/apex';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';


export default class CaseCommentDisplayComponent extends LightningElement {
    @api recordId;
    @track loading = false;
    @track limit = 2;
    @track sortOrder = 'DESC';
    @track putlimit = true;
    @track records;
    @track currentState;
    wiredCommentsResult;
    @wire(CurrentPageReference) pageRef
    pathArray = window.location.pathname.split('/');
    portalname = this.pathArray[1];

    @wire(getCaseComments, { caseId: '$recordId', lim: '$limit', sortorder : '$sortOrder' , portal: '$portalname'})
    wiredComments(result) {
        this.wiredCommentsResult = result;
        if (result.error) {
            let message = 'Unknown error';
            if (Array.isArray(result.error.body)) {
                message = result.error.body.map(e => e.message).join(', ');
            } else if (typeof result.error.body.message === 'string') {
                message = result.error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Case Comments',
                    message,
                    variant: 'error',
                }),
            );
        } else if (result.data) {
            this.records = JSON.parse(JSON.stringify(result.data));
            this.records = this.records.map(res => {
                res.createddate = new Date(res.createddate);
                res.comment = res.comment ? res.comment.replace(/<img[^>]*>/g,"") : res.comment;
                return res;
            });
        }

    }

    loadmore(event) {
        this.putlimit = false;
        this.limit = null;
        //this.getCommentsList(this.putlimit);
        return refreshApex(this.wiredCommentsResult);
    }

    sortdata(event) {
        this.sortOrder = this.sortOrder == 'ASC' ? 'DESC' : 'ASC';
        //this.getCommentsList(this.putlimit);
        return refreshApex(this.wiredCommentsResult);
    }
    contract(event) {
        this.putlimit = true;
        this.limit = 2;
        //this.getCommentsList(this.putlimit);
        return refreshApex(this.wiredCommentsResult);
    }
    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('casecommentposted', this.refreshdata, this);
    }
    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }

    /*getCommentsList(enforcelimit) {

        if (enforcelimit) {
            this.limit = 2;
        } else {
            this.limit = null;
        }
        getCaseComments({ caseId: this.recordId, lim: this.limit })
            .then(result => {
                if (result) {
                    this.records = result.map(res => {
                        res.createddate = new Date(res.createddate);
                        return res;
                    });
                }
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Getting Case Comments!',
                        error,
                        variant: 'error',
                    }),
                );
            });
    }
    */
    showtoast(mes) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Comment Updated!',
                mes,
                variant: 'success',
            }),
        );
    }

    refreshdata() {
        return refreshApex(this.wiredCommentsResult);
    }
}