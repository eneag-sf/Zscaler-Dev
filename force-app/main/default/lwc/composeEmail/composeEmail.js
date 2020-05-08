import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getOrgWideId from '@salesforce/apex/ComposeEmailController.getOrgWideId';
import getTemplateBody from '@salesforce/apex/ComposeEmailController.getTemplateBody';
import sendEmail from '@salesforce/apex/ComposeEmailController.sendEmail';

export default class ComposeEmail extends LightningElement {
    @api fromAddress;
    @api toAddress;
    @api additionalTo;
    @api ccAddress;
    @api bccAddress;
    @api templateId = '';
    @api relatedId='';
    @track fromResults;
    @track subject;
    @track emailBody = '';
    @track isBodyReadOnly = false;

    connectedCallback() {
        console.log('Connected Callback called');
        // get org wide email address
        getOrgWideId().then(result => {
            var tempresult = JSON.parse(JSON.stringify(result));
            var resultOption = [{ 'label': 'Select', 'value': '' }];
            this.fromResults = resultOption.concat(tempresult);
            console.log('this.fromResults>>>>'+this.fromResults);
        }).catch(error => {
            console.error('Error in ComposeEmail.getOrgWideId' + error);
        });

        //for getting template
        getTemplateBody({
            templateId: this.templateId,
            relatedId: this.relatedId,
        }).then(result => {
            result = JSON.parse(JSON.stringify(result));
            debugger;
            if (result.htmlBody !== undefined && result.htmlBody !== null && result.htmlBody !== '') {
                this.emailBody = result.htmlBody;
                this.isBodyReadOnly = true;
            }
            if (result.subject !== undefined && result.subject !== null && result.subject !== '') {
                this.subject = result.subject;
            }
        }).catch(error =>{
            console.error('Error in ComposeEmail.getTemplateBody' + error);
        })        
    }
    
    sendMail(){
        console.log('send emauil called');
        var sendEmailRef = {};
        sendEmailRef.fromAddress = this.fromAddress;
        sendEmailRef.toAddress = this.toAddress;
        sendEmailRef.ccAddress = this.ccAddress;
        sendEmailRef.bccAddress = this.bccAddress;
        sendEmailRef.additionalTo = this.additionalTo;
        sendEmailRef.subject = this.subject;
        sendEmailRef.emailBody = this.emailBody;
        sendEmailRef.templateId = this.templateId;
        sendEmailRef.relatedId = this.relatedId;
         
        sendEmail({
            sendEmailRef: sendEmailRef
        }).then(result => {
            console.log('result--',JSON.stringify(result));
            if(result.isSuccess){
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Mail has been sent successfully.!',
                    variant: "success"
                });
                this.dispatchEvent(event);
                const evt = new CustomEvent ('emailsent', { detail : {'result' :'Success'}});
                this.dispatchEvent (evt);
            }
        }).catch(error =>{
            console.error('Error in ComposeEmail.getTemplateBody' + error);
        })
    }

    handleChange(event){
        console.log('from changed called');
        var targetVal = event.target;
        var targetDetail = event.detail;
        if(targetVal.dataset && targetVal.dataset.type){
            if(targetVal.dataset.type === 'fromAddress'){
                this.fromAddress = targetVal.value;
            }
            if(targetVal.dataset.type === 'toAddress'){
                 this.toAddress = targetVal.value;
             }
            if(targetVal.dataset.type === 'ccAddress'){
                this.ccAddress = targetVal.value;
            }
            if( targetVal.dataset.type === 'bccAddress'){
                this.bccAddress = targetVal.value;
            }
            if( targetVal.dataset.type === 'additionalTo'){
                this.additionalTo = targetVal.value;
            }
            if( targetVal.dataset.type === 'subject'){
                this.subject = targetVal.value;
            }
            if( targetVal.dataset.type === 'emailBody'){
                this.emailBody = targetVal.value;
            }
        } else if(targetDetail){
            this.toAddress = targetDetail.value.Email;
        }
        
    }   

}