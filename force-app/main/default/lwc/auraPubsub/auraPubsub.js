import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {
    registerListener,
    unregisterListener,
    unregisterAllListeners,
    fireEvent
} from 'c/pubsub';

export default class AuraPubsub extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.dispatchEvent(new CustomEvent('ready'));
    }

    @api
    registerListener(eventName, callback) {
        registerListener(eventName, callback, this);
    }

    @api
    unregisterListener(eventName, callback) {
        unregisterListener(eventName, callback, this);
    }

    @api
    unregisterAllListeners() {
        unregisterAllListeners(this);
    }

    @api
    fireEvent(eventName, data) {
        fireEvent(this.pageRef, eventName, data);
    }
}