import { LightningElement, track, api } from 'lwc';

export default class LegacyCaseCommentsViewer extends LightningElement {
    @track openmodel = false;
    @api recordId;
    
    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    } 
    saveMethod() {
        this.closeModal();
    }

    @track fullUrl
    renderedCallback()
    {
        this.fullUrl='/customers/apex/LegacyCaseComments?Id='+this.recordId+'&isCommunityUser=true';
    }

}