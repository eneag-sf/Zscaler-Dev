import { LightningElement, track, wire, api } from 'lwc';
import retriveCaseFiles from '@salesforce/apex/CaseAttachmentController.fetchCaseFiles';
import pdfResource from '@salesforce/resourceUrl/PdfIcon';
import { refreshApex } from '@salesforce/apex';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import {CurrentPageReference} from 'lightning/navigation';

export default class CaseAttachmentsDetails extends LightningElement {
    @api caseId;
    @track caseAttachments;
    @track caseFiles;
    @track caseFilesAll;
    @track error;
    @track pdfIcon = pdfResource;
    @track attachmentId;
    @track limit = 4;
    @track putlimit = true;
    wiredResults;
    @wire(CurrentPageReference) pageRef

    @wire(retriveCaseFiles, { strObjectName: '$caseId' })
    casesFiles(results) {
        this.wiredResults = results;
        if (results.data) {
            let pathArray = window.location.pathname.split('/');
            let portalname = pathArray[1];
            this.caseFilesAll = JSON.parse(JSON.stringify(results.data));
            this.caseFilesAll = this.caseFilesAll.map(res => {
                res.urltodownload = '/' + portalname + res.urltodownload;
                return res;
            });
            this.caseFiles = [...this.caseFilesAll];
            this.caseFiles = this.caseFiles.slice(0, this.limit);
            this.error = undefined;
        }
        else if (results.error) {
            this.caseFiles = undefined;
            this.error = results.error;
        }
    }
    loadmore(event) {
        this.putlimit = false;
        this.caseFiles = [...this.caseFilesAll];
        this.caseFiles = this.caseFiles.slice(0, this.caseFilesAll.length);
    }

    contract(event) {
        this.putlimit = true;
        this.caseFiles = [...this.caseFilesAll];
        this.caseFiles = this.caseFiles.slice(0, this.limit);
    }

    refreshdata() {
        return refreshApex(this.wiredResults);
    }
    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('casecommentposted', this.refreshdata, this);
    }
    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }
}