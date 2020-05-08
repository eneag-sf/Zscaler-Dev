import { LightningElement, track, wire } from 'lwc';
import getAccountTeamMembers from '@salesforce/apex/AccountTeamController.getAccountTeamList';
export default class AccountTeamLWC extends LightningElement {
    @track accountTeamMembers;
    @wire(getAccountTeamMembers)
    accountMemberData({data, error}) {
        if(data) {
            this.accountTeamMembers = data;
            for(let key in data) {
                console.log(JSON.stringify(data[key]));
            }
        }
        else if(error) {
            window.console.log(error);
        }
    }
}