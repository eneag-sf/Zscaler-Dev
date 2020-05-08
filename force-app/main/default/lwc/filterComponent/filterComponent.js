/* eslint-disable no-console */
import { LightningElement, api, track } from "lwc";


export default class FilterComponent extends LightningElement {
  //Input
  @api fldorigin;
  @api fldlabel;
  @api fldname;
  @api fldtype;
  @api labelvarint = "label-stacked";

  //For range
  @api fldisrange = false;

  //For multiPickList type
  @api fldoptions;
  @api showclearbutton = "true";
  @api showfilterinput = "true";
  @api showrefreshbutton = "true";


  //Computed values
  @track showLabel = true;
  
  @track isPickList = false;
  @track isMulti = false;

  @track isDate = false;
  @track isDateTime = false;
  @track isText = false;
  @track isRange = false;
  
  @track placeholder;

  //Output
  @track filterValue;
  @track selecttedValue;
  @track selecttedValueFrom;
  @track selecttedValueTo;


  connectedCallback() {
    console.log("---FilterComponent connectedCallback called---");
    //console.log("fldorigin ::", this.fldorigin);
    //console.log("fldlabel ::", this.fldlabel);
    //console.log("fldname ::", this.fldname);
    //console.log("fldtype ::", this.fldtype);
    //console.log("fldisrange ::", this.fldisrange);
    //console.log("fldoptions ::", JSON.stringify(this.fldoptions));

    if (this.fldisrange) {
      this.isRange = true;
    } else {
      this.isRange = false;
    }

    switch (this.fldtype) {
      case "PickList": {
        this.isPickList = true;
        this.isMulti = true;
        let allFLDoptions = new Array();
        this.fldoptions.forEach(function(item, index) {
          let obj = { key: index, value: item };
          allFLDoptions.push(obj);
        });
        this.filteroptions = allFLDoptions;
        break;
      }
      case "Date": {
        this.isDate = true;
        this.isMulti = false;
        break;
      }
      case "DateTime": {
        this.isDateTime = true;
        this.isMulti = false;
        break;
      }
      case "Text": {
        this.isText = true;
        this.isMulti = false;
        this.placeholder = this.fldlabel;
        break;
      }
      default: {
        this.isPickList = false;
        this.isDate = false;
        this.isDateTime = false;
        this.isText = false;
        this.isMulti = false;
      }
    }
  }


  get filterOptions(){
    console.log('-filterOptions called--');
    let allFLDoptions = [];
    this.fldoptions.forEach(function(item, index) {
      let obj = { key: index, value: item };
      allFLDoptions.push(obj);
    });
    
    //console.log('-filterOptions fldlabel--',this.fldlabel);
    //console.log('-filterOptions allFLDoptions--',allFLDoptions);
    return allFLDoptions;
  }



  @api
  getFiltervalue() {
    var ret;
    if (this.isRange) {
      ret = {
        fldorigin: this.fldorigin,
        fieldName: this.fldname,
        fieldType: this.fldtype,
        isMulti: false,
        isRange: true,
        valFrom: this.selecttedValueFrom,
        valTo: this.selecttedValueTo
      };
    } else {
      ret = {
        fldorigin: this.fldorigin,
        fieldName: this.fldname,
        fieldType: this.fldtype,
        fieldValue: this.filterValue,
        isRange: false,
        isMulti: this.isMulti
      };
    }
    return ret;
  }

  handleOnMultiSelectItemSelected(event) {
    console.log("handleOnMultiSelectItemSelected :: called");
    if (event.detail) {
      this.filterValue = "";
      let self = this;
      event.detail.forEach(function(eachItem) {
        self.filterValue += eachItem.value + ", ";
      });

      //Fire Event here
      this.despatchChangeEvent();
    }
  }

  /* Without Range */
  //value change
  handleValueChange(event) {
    console.log("handleValueChange :: called");
    event.preventDefault();
    const val = event.target.value;
    this.filterValue = val;
   
    //Fire Event here
    this.despatchChangeEvent();
  }

  //Fire Custom event filtervaluechange
  despatchChangeEvent() {
    const eventDetail = {
      fldorigin: this.fldorigin,
      fieldName: this.fldname,
      fieldType: this.fldtype,
      isRange: false,
      isMulti: true,
      fieldValue: this.filterValue
    };
    const changeEvent = new CustomEvent("filtervaluechange", {
      detail: eventDetail
    });
    this.dispatchEvent(changeEvent);
  }


  /* For Range */
  //value change for FROM
  handleRangeValueChangeFrom(event) {
    console.log("handleRangeValueChangeFrom :: called");
    event.preventDefault();
    const val = event.target.value;
    const type =  event.target.type;
    this.selecttedValueFrom = val;
    
    //Dispach Range Event here
    this.despatchRangeChangeEvent();
  }


  //value change for TO
  handleRangeValueChangeTo(event) {
    console.log("handleRangeValueChangeTo :: called");
    event.preventDefault();
    const val = event.target.value;
    const type =  event.target.type;
    this.selecttedValueTo = val;
    //Dispach Range Event here
    this.despatchRangeChangeEvent();
  }

   //Fire Custom event filtervaluechange
  despatchRangeChangeEvent() {
    const eventDetail = {
      fldorigin: this.fldorigin,
      fieldName: this.fldname,
      fieldType: this.fldtype,
      isMulti: false,
      isRange: true,
      valFrom: this.selecttedValueFrom,
      valTo: this.selecttedValueTo
    };
    const changeEvent = new CustomEvent("filtervaluechange", {
      detail: eventDetail
    });
    this.dispatchEvent(changeEvent);
  }
}