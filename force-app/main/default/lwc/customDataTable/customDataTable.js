/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import TIMEZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";

export default class CustomDataTable extends LightningElement {
  @track refresh;
  @api tableforlookup = false;  
  @api showRowNumber = false;
  @api showCheckBox = false;
  @api showPagination = false;

  @api isSearchable = false;
  
  @api rowSize = 10;

  @api sortData = "asc";

  @api values = [
    {
      Owner: "Hannah Cronen1",
      Name: "Test Record1",
      OpportunityName: "Test Record1",
      ContractEndDate: "12/17/2019",
      CloseDate: "12/17/2019",
      Amount: "66813.36",
      RenewalACV: "46813.36",
      DaysPastDue: "4",
      Status: "Test",
      "ContractExtended To": "",
      NumberofExtensions: "0",
      SendNotification: "yes",
      isRequestApprovalButtonDisable: false,
      isRequestApprovalButtonVisible: true,
      oppIdUrl: "0060g00000weMI3AAM1",
      imageHeader : "'Simon Legg1';",
      addContactImageURL : "/resource/1575613756000/Renewal_Notification/img/download.png",
    },
    {
      Owner: "Hannah Cronen2",
      Name: "Test Record2",
      OpportunityName: "Test Record2",
      ContractEndDate: "12/19/2019",
      CloseDate: "12/20/2019",
      Amount: "67813.36",
      RenewalACV: "66813.36",
      DaysPastDue: "6",
      Status: "tes",
      "ContractExtended To": "",
      NumberofExtensions: "0",
      SendNotification: "yes",
      isRequestApprovalButtonDisable: false,
      isRequestApprovalButtonVisible: true,
      oppIdUrl: "0060g00000weMI3AAM1",
      imageHeader : "'Simon Legg2';",
      addContactImageURL : "/resource/1575613756000/Renewal_Notification/img/download.png",
    },
    {
      Owner: "Hannah Cronen3",
      Name: "Test Record3",
      OpportunityName: "Test Record3",
      ContractEndDate: "12/20/2019",
      CloseDate: "12/20/2020",
      Amount: "56813.36",
      RenewalACV: "66813.36",
      DaysPastDue: "11",
      Status: "",
      "ContractExtended To": "",
      NumberofExtensions: "0",
      SendNotification: "yes",
      isRequestApprovalButtonDisable: false,
      isRequestApprovalButtonVisible: true,
      oppIdUrl: "0060g00000weMI3AAM1",
      imageHeader : "'Simon Legg3';",
      addContactImageURL : "/resource/1575613756000/Renewal_Notification/img/download-error.png",
    }
  ];

  //api
  @api columns = [
    {
      label: "Action",
      fieldName: "Id",
      type: "customButton",
      typeAttributes: {
        label: "Request Approval",
        disable: "isRequestApprovalButtonDisable",
        visible: "isRequestApprovalButtonVisible",
        style:
          "font-size: 11px;padding: 0px 5px;border-radius: 0.em;margin: 0px;color: #333;border: 1px solid #b5b5b5;border-bottom-color: #7f7f7f;background: #e8e8e9 url(/img/alohaSkin/btn_sprite.png) repeat-x right top;-moz-border-radius: 3px;-webkit-border-radius: 3px;",
        class: ""
      },
      sortable: false
    },
    {
      label: "Add Partner Contacts",
      fieldName: "Id",
      type: "customImageLink",
      typeAttributes: {
        label: "Add Partner Contacts",
        header: "imageHeader",
        headerCSS: "text-align:center;",
        imageURL: "/resource/1575613756000/Renewal_Notification/img/download.png",
        imageURLfld : "addContactImageURL",
        imageCSS: "text-align:center;",
        height:"18",
        width : "18",
        disable: "isRequestApprovalButtonDisable",
        visible: "isRequestApprovalButtonVisible",
        style: "",
        class: "",
        alttext: "Save"
      },
      sortable: false
    },
    { width: null, type: "text", fieldName: "Owner", label: "Owner" },
    {
      label: "Opportunity name",
      fieldName: "oppIdUrl",
      type: "recordLink",
      initialWidth: 300,
      typeAttributes: { label: { fieldName: "Name" }, target: "_blank" },
      sortable: true
    },
    {
      label: "Name",
      fieldName: "Name",
      type: "text",
      width: null
    },
    {
      label: "Contract End Date",
      fieldName: "ContractEndDate",
      type: "date",
      width: null,
      sortable: true
    },
    { label: "Close Date", fieldName: "CloseDate", type: "date", width: null },
    { label: "Amount", fieldName: "Amount", type: "currency", width: null },
    {
      label: "Renewal ACV",
      fieldName: "Amount",
      type: "currency",
      width: null,
      sortable: true
    },
    {
      label: "Days Past Due",
      fieldName: "Days Past Due",
      type: "number",
      width: null
    },
    { label: "Status", fieldName: "Status", type: "text", width: null },
    {
      label: "Contract Extended To",
      fieldName: "ContractExtendedTo",
      type: "date",
      width: null,
      sortable: true
    },
    {
      label: "Number of Extensions",
      fieldName: "NumberofExtensions",
      type: "number",
      width: null,
      sortable: true
    },
    {
      label: "Send Notification",
      fieldName: "SendNotification",
      type: "picklist",
      options: [
        { label: "yes", value: "yes" },
        { label: "no", value: "no" }
      ],
      width: null,
      sortable: true
    }
  ];

  @track data = [];
  @track updatedColumns = [];
  @track unfilteredData;
  @track currentCount = 0;
  @track searchKey = "";

  @track noDataFound;
  @track currentpagenumber = 1;
  @track dataSize;
  @track DataGridStyle = "table-layout: fixed;";
  @track showCell = true;
  selectAll = false;

  get customScrollClass() {
    return this.dataSize > this.rowSize
      ? "slds-scrollable_y datagrid-table"
      : "datagrid-table";
  }

  get isDataGridSearchable() {
    return this.isSearchable &&
      this.updatedColumns &&
      this.unfilteredData &&
      this.updatedColumns.length > 0 &&
      this.unfilteredData.length > 0
      ? true
      : false;
  }

  get isDisablePagination() {
    return this.showPagination &&
      this.updatedColumns &&
      this.unfilteredData &&
      this.updatedColumns.length > 0 &&
      this.unfilteredData.length > 0
      ? false
      : true;
  }

  get isFooter() {
    return this.showPagination === true ||
      this.isDataGridSearchable === true
      ? true
      : false;
  }

  get maxPageNumber() {
    if (this.data !== undefined && this.data !== null && this.dataSize > 0) {
      return Math.ceil(this.dataSize / this.rowSize);
    }
    return 1;
  }

  handlePagination(event) {
    try {
      let detail = event.detail;
      if (detail.name === "currentpagenumber") {
        this.currentpagenumber = parseInt(detail.value, 10);
      } else if (detail.name === "currentpagesize") {
        this.rowSize = parseInt(detail.value, 10);
        this.currentpagenumber = 1;
      }
      this.currentCount = (this.currentpagenumber - 1) * this.rowSize;
    } catch (error) {
      console.error(
        "Error in Custom Data Table->handlePagination" + error.stack
      );
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
    }
  }
 

  connectedCallback() {
    console.log("::CustomDataTable connectedCallback called ::");

    this.showCheckBox = this.showCheckBox ==="true" ? true : false;
    this.showRowNumber = this.showRowNumber ==="true" ? true : false;
    this.isSearchable = this.isSearchable ==="true" ? true : false;
    
    console.log("::CustomDataTable::hideCheckBox::",this.showCheckBox);
    console.log("::CustomDataTable::showRowNumber::",this.showRowNumber);
    console.log("::CustomDataTable::isSearchable::",this.isSearchable);
    
    try {
      this.data = JSON.parse(JSON.stringify(this.values));
      if (!this.unfilteredData) {
        this.unfilteredData = this.data;
      }
      if (this.columns !== null && this.columns.length > 0) {
        this.updatedColumns = JSON.parse(JSON.stringify(this.columns));
        for (let i = 0; i < this.updatedColumns.length; i++) {
          if (
            this.updatedColumns[i].typeAttributes &&
            this.updatedColumns[i].typeAttributes.label &&
            this.updatedColumns[i].typeAttributes.label.fieldName
          ) {
            this.updatedColumns[i].alternativeText = this.updatedColumns[
              i
            ].typeAttributes.label.fieldName;
          }
        }
      }
      
      //this.rowSize = 10;
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
    }
  }

  get currentRecords() {
    try {
      var currentRecords = [];
      console.log('before>>>>'+ new Date() );
      this.data = JSON.parse(JSON.stringify(this.values));
      //console.log('--currentRecords--',this.data);
      console.log('after>>>>'+ new Date() );
      if (!this.unfilteredData) {
        this.unfilteredData = this.data;
      }
      this.dataSize = this.data.length;
      if (this.data != null && this.dataSize > 0) {
        // this.noDataFound = null;
        if (this.showPagination) {
          if (this.currentCount === this.dataSize) {
            this.currentpagenumber -= 1;
            this.currentCount = (this.currentpagenumber - 1) * this.rowSize;
          }
          let rowSize = parseInt(this.rowSize, 10);
          var endIndex =
            this.currentCount + rowSize < this.dataSize
              ? this.currentCount + rowSize
              : this.dataSize;
          let rowNum;
          let srNo;
          this.data.forEach((record, ind) => {
            if (ind < endIndex) {
              rowNum = ind;
              srNo = ind + 1;
              currentRecords.push({ ...record, rowNum, srNo });
            }
          });
        } else {
          let rowNum;
          let srNo;
          this.data.forEach((record, index) => {
            rowNum = index;
            srNo = index + 1;
            currentRecords.push({ ...record, rowNum, srNo });
          });
        }
      } else {
        this.noDataFound = "No record found";
      }
      return currentRecords;
    } catch (error) {
      console.error(
        "Error in Custom Data Table -> getCurrentRecords()" + error.stack
      );
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
      return null;
    }
  }

  onRowSelection(event) {
    try {
      this.select = event.target.checked;
      this.rowNum = event.target.value;
      setTimeout(() => {
        let selectedRecord = [];
        if (isNaN(this.rowNum)) {
          this.selectAll = this.select;
          for (let index = 0; index < this.data.length; index++) {
            this.data[index].isSelected = this.select;

            if (this.data[index].isSelected) {
              selectedRecord.push(this.data[index]);
            }
          }
        } else {
          this.data[this.rowNum].isSelected = this.select;
          if (this.data && this.data.length > 0) {
            for (let index = 0; index < this.data.length; index++) {
              if (this.data[index].isSelected) {
                selectedRecord.push(this.data[index]);
              } else {
                this.selectAll = false;
              }
            }
            if (selectedRecord.length === this.data.length) {
              this.selectAll = true;
            }
          }
        }
      }, 0);
    } catch (error) {
      console.error("Error in Custom Data Table->onSelection" + error.stack);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
    }
  }

  onSelection(event){
    if(this.tableforlookup){
      const selectEvent = new CustomEvent('rowaction', {
        detail: {
            'row': event.detail.row,   
        }
      });
      this.dispatchEvent(selectEvent);
    }
  }

  clearSearchText(event) {
    this.searchKey = event.target.value;
    if (this.searchKey === "" || this.searchKey === null) {
      this.currentpagenumber = 1;
      this.filterData(false);
    }
  }

  handleKeyUp(evt) {
    const isEnterKey = evt.keyCode === 13;
    this.searchKey = evt.target.value;
    if (isEnterKey === true) {
      this.filterData(false);
    }
  }

  searchDataOnClick() {
    this.currentpagenumber = 1;
    this.filterData(false);
  }

  filterData(refreshUnfilterData) {
    try {
      var searchKey = this.searchKey;
      console.log("inside->filterData:" + searchKey);
      if (
        this.unfilteredData &&
        this.unfilteredData.length > 0 &&
        this.updatedColumns &&
        this.updatedColumns.length > 0
      ) {
        var filteredData = [];
        this.unfilteredData.forEach(record => {
          for (let index = 0; index < this.updatedColumns.length; index++) {
            const column = this.updatedColumns[index];
            var pass = null;
            if (column.type === "date") {
              if (record[column.fieldName]) {
                pass = new Date(record[column.fieldName]);
                pass = pass.toLocaleDateString(LOCALE, {
                  dateStyle: "short"
                });
              } else {
                pass = "";
              }
            } else if (column.type === "datetime") {
              if (record[column.fieldName]) {
                pass = new Date(record[column.fieldName]);
                pass = pass.toLocaleString(LOCALE, {
                  timeZone: TIMEZONE,
                  dateStyle: "short",
                  timeStyle: "short"
                });
              } else {
                pass = "";
              }
            } else {
              pass = record[column.fieldName];
            }
            if (column.fieldName && pass) {
              if (
                pass
                  .toString()
                  .toUpperCase()
                  .includes(searchKey.toUpperCase())
              ) {
                filteredData.push(record);
                break;
              }
            }
          }
        });
        console.log("filteredData:" + filteredData);
        this.showCell = false;
        setTimeout(() => {
          this.showCell = true;
        }, 0);

        if (filteredData) {
          if (Array.isArray(filteredData)) {
            this.data = JSON.parse(JSON.stringify(filteredData));
          } else {
            if (!this.isEmptyObject(filteredData)) {
              this.data.push(JSON.parse(JSON.stringify(filteredData)));
            }
          }
          this.dataSize = this.data.length;
          if (
            !this.unfilteredData ||
            refreshUnfilterData === undefined ||
            refreshUnfilterData
          ) {
            this.unfilteredData = this.data;
          }
        }
      }
    } catch (error) {
      console.error("Error in Custom Data Table->filterData()" + error.stack);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
    }
  }

  // The method onsort event handler

  onSort(event) {
    try {
      event.stopPropagation();
      if (event.target) {
        let eventData = JSON.parse(JSON.stringify(event.target.dataset));

        console.log("eventData--", JSON.stringify(eventData));

        this.sortedBy = eventData.fieldname;
        this.sortedDirection = eventData.sorteddirection;
        var type = eventData.type;
        if (type === "html") {
          this.data = JSON.parse(
            JSON.stringify(
              this.sortArrayOfObjects(
                this.data,
                eventData.alternativetext,
                this.sortData,
                type
              )
            )
          );
        } else if (type === "recordLink") {
          this.data = JSON.parse(
            JSON.stringify(
              this.sortArrayOfObjects(
                this.data,
                eventData.alternativetext,
                this.sortData,
                type
              )
            )
          );
        } else {
          this.data = JSON.parse(
            JSON.stringify(
              this.sortArrayOfObjects(
                this.data,
                eventData.fieldname,
                this.sortData,
                type
              )
            )
          );
        }

        if (this.sortedDirection === "asc") {
          this.sortData = "desc";
        } else if (this.sortedDirection === "desc") {
          this.sortData = "asc";
        }
        for (let i = 0; i < this.updatedColumns.length; i++) {
          if (this.updatedColumns[i].fieldName === eventData.fieldname) {
            if (this.sortedDirection === "asc") {
              this.updatedColumns[i].isASC = true;
              this.updatedColumns[i].isDESC = false;
            } else {
              this.updatedColumns[i].isASC = false;
              this.updatedColumns[i].isDESC = true;
            }
          } else {
            this.updatedColumns[i].isASC = false;
            this.updatedColumns[i].isDESC = false;
          }
        }
      }
      this.showCell = true;
      this.values = this.data;
    } catch (error) {
      console.error("Error in Custom Data Table -> onSort" + error.stack);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.message,
          variant: "error",
          mode: "dismissable"
        })
      );
    }
  }

  sortArrayOfObjects = (arr, key, sortOrder, type) => {
    return arr.sort((a, b) => {
      var aVal = "";
      var bVal = "";
      if (type === "text") {
        aVal =
          a[key] !== undefined && a[key] !== "" ? a[key].toUpperCase() : "";
        bVal =
          b[key] !== undefined && b[key] !== "" ? b[key].toUpperCase() : "";
      } else if (
        type === "number" ||
        type === "currency" ||
        type === "percent"
      ) {
        aVal = a[key] !== undefined && a[key] !== "" ? a[key] : 0;
        bVal = b[key] !== undefined && b[key] !== "" ? b[key] : 0;
      } else if (type === "date" || type === "date-local") {
        aVal =
          a[key] !== undefined && a[key] !== ""
            ? Date.parse(a[key])
            : undefined;
        bVal =
          b[key] !== undefined && b[key] !== ""
            ? Date.parse(b[key])
            : undefined;
      } else {
        aVal =
          a[key] !== undefined && a[key] !== "" ? a[key].toUpperCase() : "";
        bVal =
          b[key] !== undefined && b[key] !== "" ? b[key].toUpperCase() : "";
      }

      let comparison = 0;
      if (sortOrder === "asc") {
        if (aVal === undefined && bVal === undefined) {
          comparison = 0;
        } else if (aVal === undefined && bVal !== undefined) {
          comparison = -1;
        } else if (aVal !== undefined && bVal === undefined) {
          comparison = 1;
        } else if (aVal > bVal) {
          comparison = 1;
        } else if (aVal < bVal) {
          comparison = -1;
        }
      } else {
        if (aVal === undefined && bVal === undefined) {
          comparison = 0;
        } else if (aVal === undefined && bVal !== undefined) {
          comparison = 1;
        } else if (aVal !== undefined && bVal === undefined) {
          comparison = -1;
        } else if (aVal < bVal) {
          comparison = 1;
        } else if (aVal > bVal) {
          comparison = -1;
        }
      }
      return comparison;
    });
  };

  keepCloning = objectpassed => {
    if (objectpassed === null || typeof objectpassed !== "object") {
      return objectpassed;
    }
    return null;
  };

  isEmptyObject = obj => {
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) return false;
    }
    return true;
  };

  handlePickListValueChangeEvent(event) {
    console.log("--handlePickListValueChangeEvent--");
    let recordVal = event.detail;
    console.log("--recordVal--", JSON.stringify(recordVal));
    const selectEvent = new CustomEvent("recordvaluechange", {
      detail: recordVal
    });
    this.dispatchEvent(selectEvent);
  }

  generateRandomNumber = len => {
    console.log();
    let str = (Date.now() + Math.random()).toString().replace(".", "");
    str = str.split("").reverse();
    str = str.join("").substr(0, len);
    console.log("randomnumber:" + str);
    return str;
  };
}