import { LightningElement, track, wire, api } from 'lwc';
import retriveCase  from '@salesforce/apex/CaseDetailLWCController.fetchCase';
import COMMENTBODY_FIELD from '@salesforce/schema/CaseComment.CommentBody';
import PARENTID_FIELD from '@salesforce/schema/CaseComment.ParentId';
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import ID_FIELD from '@salesforce/schema/Contact.Id';
const columns = [
    {label: 'Title', fieldName: 'Title'}
];

export default class CaseDetailLWC extends LightningElement {
    @track caseId;
    @track caseData;
    @track emailList;
    @track contactId;
    @track error;
    @track commentBody = COMMENTBODY_FIELD;
    @track parId = PARENTID_FIELD;
    rec = {
        CommentBody : this.commentBody,
        ParentId : this.parId
    }
    //file upload
    @api recordId;
    @track columns = columns;
    @track data;
    @track fileName = '';
    @track UploadFile = 'Upload File';
    @track showLoadingSpinner = false;
    @track isTrue = false;
    @track firstName;
    @track lastName;
    @track email;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    emailRefreshData;
    MAX_FILE_SIZE = 1500000;
    @track openmodel = false;
    @track addMode = false;
    @track editMode = false;

    @track ctRecord = {
        FirstName : FIRSTNAME_FIELD,
        LastName : LASTNAME_FIELD ,
        Email : EMAIL_FIELD,
        Id : ID_FIELD
    };

    @wire(retriveCase, {strObjectName : '$caseId'})
    cases({data, error}) {
        if(data) {
            this.caseData = data;
            this.error = undefined;
        }
        else if(error) {
            this.caseData = undefined;
            this.error = error;
        }
    }
    /*
    openmodal() {
        this.ctRecord = {};
        this.addMode = true;
        this.editMode = false;
        this.openmodel = true;
    }
    closeModal() {
        this.addMode = false;
        this.editMode = false;
        this.openmodel = false
    }

    handleCloseCase(){
        updateCaseDetails({ caseDetailId: this.caseId})
        .then(result => {
            this.caseData = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Case Closed Successfully!!!',
                    variant: 'success',
                }),
            );
            window.location.reload();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while Closing Case',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }
    showEscCmp(){
        this.template.querySelector('c-customer-escalation-l-w-c').showModal();
    }
    */
    connectedCallback() {
        var str = window.location.href;
        var extracted = str.split("/").find(function(v){
        return v.indexOf("500") > -1;
        });
        this.caseId = extracted;
    }
    parId = this.caseId;
    
}