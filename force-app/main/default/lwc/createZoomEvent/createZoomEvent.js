import { LightningElement,api, track, wire} from 'lwc';

// Importing Apex Class method
import saveAccount from '@salesforce/apex/CreateZoomMeeting_LWCcontroller.saveZoomEventRecord'; 

// importing to show toast notifictions
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_Object from '@salesforce/schema/Case';
import Case_OBJECT from '@salesforce/schema/Case';
import NAME_FIELD from '@salesforce/schema/Case.CaseNumber';
import Contact_FIELD from '@salesforce/schema/Case.ContactId';
import ContactName_FIELD from '@salesforce/schema/Case.Contact.Name';

// importing Event fields
import Subject_FIELD from '@salesforce/schema/Event.Subject';
import StartDateTime_FIELD from '@salesforce/schema/Event.StartDateTime';   
import EndDateTime_FIELD from '@salesforce/schema/Event.EndDateTime';

const FIELDS = [
    'Case.CaseNumber',
    'Case.ContactId',
];

export default class CreateRecordInLWC extends LightningElement {
    @api recordId;
    @track error;
    @track CaseContactid='';
    @track comment = '';
    @track StartTime = '';
    @track EndTime = '';
    @api objectApiName;
    @track showclosedetails = false;
    @track CaseRecordid='';
    
    /* Expose schema objects/fields to the template. */
    Caseobject = Case_OBJECT;

    @wire(getObjectInfo, { objectApiName: Case_Object })
    objectInfo;

    /* Load Account.Name for custom rendering */
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD,Contact_FIELD,ContactName_FIELD]
    })
    record;
 
    /** Gets the Account.Name value. */
    get CaseNumber() {
        return this.record.data ? getFieldValue(this.record.data, NAME_FIELD) : '';
    }
    get Contact(){
        //CaseContactid=this.record.data ? getFieldValue(this.record.data, Contact_FIELD) : '';
        return this.record.data ? getFieldValue(this.record.data, ContactName_FIELD) : '';
    }

   /* @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    Case;

    get ContactId() {
        return this.Case.data.fields.ContactId.value;
    } */


    // this object have record information
    @track EventRecord = {
        StartDateTime : StartDateTime_FIELD,
        EndDateTime : EndDateTime_FIELD,
        Subject : Subject_FIELD,
    };

    handleSubjectChange(event) {
        this.EventRecord.Subject = event.target.value;
        window.console.log('Subject ==> '+this.EventRecord.Subject);
    }
	
	handleStartDateTimeChange(event) {
        this.EventRecord.zoom_app__Customer_Start_Time__c = event.target.value;
        window.console.log('zoom_app__Customer_Start_Time__c ==> '+this.EventRecord.zoom_app__Customer_Start_Time__c);
    }
	
	handleEndDateTimeChange(event) {
        this.EventRecord.EndDateTime = event.target.value;
        window.console.log('EndDateTime ==> '+this.EventRecord.EndDateTime);
    }

    assigncasecomment(event) {
        this.comment = event.target.value;
        this.CaseRecordid=this.recordId;
    }

    assignStartTime(event) {
        this.StartTime = event.target.value;
    }

    assignEndTime(event) {
        this.EndTime = event.target.value;
    }
    handleSave(event) {     
        window.console.log('objectApiName '+this.recordId);
        window.console.log('objectApiName '+this.objectApiName);
        let Caserecid;
        Caserecid=this.recordId;
        window.console.log('CaseRecordid '+Caserecid);
        saveAccount({caseId: Caserecid,comment: this.comment,StartTime: this.StartTime, EndTime: this.EndTime})
        .then(result => {
            // Clear the user enter values
            this.EventRecord = {};

            window.console.log('result ===> '+result);
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Zoom Meeting is Created Successfully!!',
                variant: 'success'
            }),);
        })
        .catch(error => {
            this.error = error.message;
        });
    }
}