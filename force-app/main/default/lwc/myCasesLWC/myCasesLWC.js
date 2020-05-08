import { LightningElement, track, wire, api } from 'lwc';
// importing apex class and method to retrive accounts
import retriveCases from '@salesforce/apex/CaseLWCController.fetchCases';
import { refreshApex } from '@salesforce/apex';

export default class myCasesLWC extends LightningElement {
    @track headerName = 'Existing Case Summary'
    @api allcases = false;
    @track caseData;
    @track caseDataTotal;
    @track allData;
    @track caseDataTemp;
    @track error;
    @track mapOfValues = [];
    @track loading = true;
    @track pcCases = 0;
    @track myCases = 0;
    @track openCases = 0;
    @track closedCases = 0;
    @track searchValue = '';
    @track searchResult = [];
    @track displaydiv = false;
    @track value = 'MyOpenCases';
    @track accvalue = '';
    @track selectedAccount = '';
    @track myopencasecss = 'zs-my-open-case-card highlight';
    @track allopencasecss = 'zs-all-open-case-card';
    @track pendingcss = 'zs-pending-case-card';
    @track closedcss = 'zs-closed-case-card';
    @api item;
    accountMap;
    accOptions = [];
    wiredResult;
    @track searchVal;
    @track sortOrder = 'ASC';
    @track sortfield;

    @track showpagination = false;
    @track showprevious = false;
    @track currentpage = 1;
    @track pageoptions;
    @track shownext = false;
    MAX_NO_OF_RECORDS = 10;

    get options() {
        return [
            { label: 'My Open Cases', value: 'MyOpenCases' },
            { label: 'All Open Cases', value: 'AllOpenCases' },
            { label: 'Pending Action', value: 'PendingAction' },
            { label: 'Closed Cases', value: 'ClosedCases' }
        ];
    }
    handleMyOpenCases() {
        this.loading = true;
        this.value = 'MyOpenCases'
        this.handleChange();
        this.myopencasecss += ' highlight';
        this.allopencasecss = 'zs-all-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handleAllOpenCases() {
        this.loading = true;
        this.value = 'AllOpenCases'
        this.handleChange();
        this.allopencasecss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handlePendingAction() {
        this.loading = true;
        this.value = 'PendingAction'
        this.handleChange();
        this.pendingcss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.allopencasecss = 'zs-all-open-case-card';
        this.closedcss = 'zs-closed-case-card';
    }
    handleClosedCases() {
        this.loading = true;
        this.value = 'ClosedCases'
        this.handleChange();
        this.closedcss += ' highlight';
        this.myopencasecss = 'zs-my-open-case-card';
        this.allopencasecss = 'zs-all-open-case-card';
        this.pendingcss = 'zs-pending-case-card';
    }
    handleListView(event) {
        this.loading = true;
        this.value = event.detail.value;
        this.handleChange();
    }
    handleChange() {
        this.searchVal = '';
        this.searchResult = [];
        //this.caseData = this.caseDataTemp;
        // eslint-disable-next-line guard-for-in
        if (this.value == 'MyOpenCases') {
            this.caseData = this.allData.myCases;
            this.caseDataTemp = this.allData.myCases;
        }
        if (this.value == 'AllOpenCases') {
            this.caseData = this.allData.openCases;
            this.caseDataTemp = this.allData.openCases;
        }
        if (this.value == 'PendingAction') {
            this.caseData = this.allData.pendingCases;
            this.caseDataTemp = this.allData.pendingCases;
        }
        if (this.value == 'ClosedCases') {
            this.caseData = this.allData.closedCases;
            this.caseDataTemp = this.allData.closedCases;
        }
        this.caseDataTotal = this.caseData;
        this.calculatepaginationparameters();
        this.loading = false;

    }
    redirectToCreateCase() {
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        window.location = '/' + portalname + '/s/create-case';
    }
    handleSearchChange(event) {
        this.searchValue = event.detail.value;
        this.searchResult = [];
        this.caseData = [...this.caseDataTemp];
        for (let key in this.caseData) {
            
            if (this.searchValue && this.caseData && this.caseData[key] && this.caseData[key].cs && ((this.caseData[key].cs.Subject && this.caseData[key].cs.Subject.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.CaseNumber && this.caseData[key].cs.CaseNumber.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Zendesk_Reference_Id__c && this.caseData[key].cs.Zendesk_Reference_Id__c.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Account && this.caseData[key].cs.Account.Name && this.caseData[key].cs.Account.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Contact && this.caseData[key].cs.Contact.Name && this.caseData[key].cs.Contact.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Owner && this.caseData[key].cs.Owner.Name && this.caseData[key].cs.Owner.Name.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Priority && this.caseData[key].cs.Priority.toLowerCase().includes(this.searchValue.toLowerCase())) 
                || (this.caseData[key].cs.Status && this.caseData[key].cs.Status.toLowerCase().includes(this.searchValue.toLowerCase()))
                )){
                this.searchResult = [...this.searchResult, this.caseData[key]];
            }
        }
        //if(this.searchResult.length >0){
        if (this.searchValue) {
            this.caseData = [...this.searchResult];
        }
        this.caseDataTotal = [...this.caseData];
        this.calculatepaginationparameters();

        //}

    }
    @wire(retriveCases, { showallCases: '$allcases', AccountId: '$accvalue' })
    cases(results) {
        this.wiredResult = results;
        if (results.data) {
            this.allData = results.data;
            if (this.value == 'MyOpenCases') {
                this.caseData = results.data.myCases;
                this.caseDataTemp = results.data.myCases;
            }
            if (this.value == 'AllOpenCases') {
                this.caseData = results.data.openCases;
                this.caseDataTemp = results.data.openCases;
            }
            if (this.value == 'PendingAction') {
                this.caseData = results.data.pendingCases;
                this.caseDataTemp = results.data.pendingCases;
            }
            if (this.value == 'ClosedCases') {
                this.caseData = results.data.closedCases;
                this.caseDataTemp = results.data.closedCases;
            }
            this.caseDataTotal = this.caseData;
            this.myCases = results.data.myCasecount;
            this.selectedAccount = results.data.selectedAccountName;
            this.openCases = results.data.openCasecount;
            this.pcCases = results.data.pendingCasecount;
            this.closedCases = results.data.closedCasecount;
            this.error = undefined;
            this.loading = false;
            this.calculatepaginationparameters();
            if (!this.accvalue) {
                this.accountMap = results.data.accMap;
                this.accOptions = [];
                this.accvalue = this.accountMap[this.selectedAccount];
                for (let key in this.accountMap) {
                    if (key) {
                        this.accOptions.push({ label: key, value: this.accountMap[key] });
                    }
                }
            }

        }
        else if (results.error) {
            this.caseData = undefined;
            this.error = results.error;
            window.console.log(results.error);
            this.loading = false;
        }
    }

    calculatepaginationparameters() {
        this.showprevious = false;
        this.currentpage = 1;
        let records = [...this.caseDataTotal];
        let numofpages = records.length / this.MAX_NO_OF_RECORDS;
        this.pageoptions = [];
        if (numofpages > 1) {
            this.showpagination = true;
            this.shownext = true;
            for (let i = 1; i <= Math.ceil(numofpages); i++) {
                this.pageoptions.push({ label: '' + i, value: i });
            }
            this.slicepage(this.currentpage, records);
        } else {
            this.showpagination = false;
        }
    }

    slicepage(pagenum, records) {
        let totrec = [...records];
        this.caseData = totrec.slice((pagenum - 1) * this.MAX_NO_OF_RECORDS, pagenum * this.MAX_NO_OF_RECORDS);
    }

    gonext() {
        this.currentpage += 1;
        if (Math.ceil(this.caseDataTotal.length / this.MAX_NO_OF_RECORDS) == this.currentpage) {
            this.shownext = false;
        }
        this.showprevious = true;
        this.slicepage(this.currentpage, this.caseDataTotal);
    }
    goback() {
        this.currentpage -= 1;
        if (this.currentpage == 1) {
            this.showprevious = false;
        }
        this.shownext = true;
        this.slicepage(this.currentpage, this.caseDataTotal);
    }
    handlepagechange(event) {
        this.currentpage = event.detail.value ? Number(event.detail.value) : this.currentpage;
        if (this.currentpage == 1) {
            this.showprevious = false;
        } else {
            this.showprevious = true;
        }
        if (Math.ceil(this.caseDataTotal.length / this.MAX_NO_OF_RECORDS) == this.currentpage) {
            this.shownext = false;
        } else {
            this.shownext = true;
        }
        this.slicepage(this.currentpage, this.caseDataTotal);
    }


    handleaccchange(event) {
        this.searchVal = '';
        this.loading = true;
        if(event.detail.value){
            this.headerName = 'Existing Case Summary for ' + event.target.options.find(opt => opt.value === event.detail.value).label;
        }else{
            this.headerName = 'Existing Case Summary';
        }
        
        this.accvalue = event.detail.value;
        return refreshApex(this.wiredResult);
    }

    sortdata(event) {
        let column = event.target.title;
        
        if (this.sortfield != column) {
            this.sortOrder = '';
            this.sortfield = column;
        }

        this.caseData = this.sort(column, this.sortOrder == 'ASC' ? 'DESC' : 'ASC');
        this.caseDataTotal = this.caseData;
        this.calculatepaginationparameters();
    }
    sort(field, sortOrder) {
        this.sortOrder = sortOrder;
        let records = [...this.caseDataTotal];
        records.sort(function (a, b) {
            let t1 = a['cs'][field] == b['cs'][field],
                t2 = (!a['cs'][field] && b['cs'][field]) || (a['cs'][field] < b['cs'][field]);
            return t1 ? 0 : (sortOrder == 'ASC' ? -1 : 1) * (t2 ? 1 : -1);
        });
        return records;
    }

}