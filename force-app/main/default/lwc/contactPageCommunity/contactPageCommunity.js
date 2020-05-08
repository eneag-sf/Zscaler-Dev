import { LightningElement, wire, api, track} from 'lwc';
import strUserId from '@salesforce/user/Id';
import findContact from '@salesforce/apex/getContactListController.getContactList';

export default class getContactListController extends LightningElement {
    userId = strUserId;
    @track contacts;
    customernametitle = 'Zscaler Team';
    @track showContacts = false;
   
    @wire(findContact)
    wiredContact({ error, data }) {
        if (data) {
            this.contacts = data.accteamlst;
            this.customernametitle += ' for ' + data.accname;
            this.showContacts = data.showaccteam;
            this.error = undefined;
            console.log(data);
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
}