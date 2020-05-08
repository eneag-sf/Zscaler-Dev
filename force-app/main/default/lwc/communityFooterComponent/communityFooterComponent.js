import { LightningElement, track } from 'lwc';

export default class CommunityFooterComponent extends LightningElement {
    @track currentyear = new Date().getFullYear();
}