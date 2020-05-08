/* eslint-disable vars-on-top */
/* eslint-disable radix */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

export default class CustomPagination extends LightningElement {

    @api currentpagenumber;
    @api maxpagenumber;
    @api currentpagesize;
    @api refresh;
    @track options = [];
    @api additionalAttributes;
    className = 'slds-button-group';
    connectedCallback() {
        var pagesize = [10, 20, 30, 50, 100];
        for (var rowCount of pagesize) {
            var option = new Option();
            option.value = rowCount;
            option.label = rowCount;
            if (option.value === this.currentpagesize) {
                option.selected = true;
            }
            this.options.push(option);
        }

    }
    get pageDisplay() {
        return this.currentpagenumber + '/' + this.maxpagenumber;
    }
    firstPage() {
        this.currentpagenumber = 1;
        this.changePage("currentpagenumber", this.currentpagenumber);
    }
    prevPage() {
        this.currentpagenumber = Math.max(this.currentpagenumber - 1, 1);
        this.changePage("currentpagenumber", this.currentpagenumber);

    }
    nextPage() {
        this.currentpagenumber = Math.min(this.currentpagenumber + 1, this.maxpagenumber);
        this.changePage("currentpagenumber", this.currentpagenumber);

    }
    lastPage() {
        this.currentpagenumber = this.maxpagenumber;
        this.changePage("currentpagenumber", this.currentpagenumber);

    }
    changePageSize(event) {
        this.currentpagesize = parseInt(event.target.value);
        this.changePage("currentpagesize", this.currentpagesize);
    }

    changePage(name, value) {
        const selectEvent = new CustomEvent('valchange', {
            detail: {
                'name': name,
                'value': value,
            }
        });
        this.dispatchEvent(selectEvent);
    }
}