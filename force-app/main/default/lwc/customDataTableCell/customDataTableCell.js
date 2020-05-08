/* eslint-disable no-console */
import { LightningElement, track, api, wire } from "lwc";

import { CurrentPageReference } from "lightning/navigation";
import TIMEZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";
import { NavigationMixin } from "lightning/navigation";
import { fireEvent } from "c/pubsub";

export default class CustomDataTableCell extends NavigationMixin(
  LightningElement
) {
  @api columndata;
  @api value;

  //for lookup component
  @api tableforlookup = false;

  //For PickList type
  @track isEditPicklist = false;
  @track selectPickListValue;

  //For Record Link
  @track navigateRecordID;
  @track navigareRecordURL;

  @track fldLabel;
  @track fldDataVal;

  //For Custom Button
  @track buttonVisible; //Visibility
  @track buttonDisable; //Disability
  @track buttonCSS;
  @track buttonClass;

  //For Custom Image Link

  @track imageLinkLabel;
  @track imageLinkVisible;
  @track imageLinkDisable;
  @track imageHeader;
  @track imageHeaderCSS;

  @track imageURL;
  @track imageAlt;
  @track imageURLStatic;

  @track imageCSS;
  @track imageHeight;
  @track imageWidth;

  @wire(CurrentPageReference) pageRef;

  connectedCallback() {
    let fieldValue = this.value[this.columndata.fieldName];
    this.fldDataVal = fieldValue;

    if (this.isRecordLink) {
      //get navigato record ID
      this.navigateRecordID = fieldValue;
      //generate navigatoRecord URL
      this.generatenavigateURL();
    } else if (this.isCustomButton) {

      if(this.columndata.typeAttributes.label){
        this.fldLabel = this.columndata.typeAttributes.label;
      }

      //Set Custom Button properties
      if (this.columndata.typeAttributes.visible) {
        this.buttonVisible = this.value[this.columndata.typeAttributes.visible];
      }

      if (this.columndata.typeAttributes.disable) {
        this.buttonDisable = this.value[this.columndata.typeAttributes.disable];
      }

      if (this.columndata.typeAttributes.style) {
        this.buttonCSS = this.columndata.typeAttributes.style;
      }
      if (this.columndata.typeAttributes.class) {
        this.buttonClass = this.columndata.typeAttributes.class;
      }
    } 
    else if (this.isCustomImageLink) {
      this.fldLabel = this.columndata.typeAttributes.label;

      if(this.columndata.typeAttributes.label){
        this.fldLabel = this.columndata.typeAttributes.label;
      }
      //Set Custom image link properties
      if (this.columndata.typeAttributes.visible) {
        this.imageLinkVisible = this.value[
          this.columndata.typeAttributes.visible
        ];
      }
      if (this.columndata.typeAttributes.disable) {
        this.imageLinkDisable = this.value[
          this.columndata.typeAttributes.disable
        ];
      }
      if (this.columndata.typeAttributes.header) {
        this.imageHeader = this.value[this.columndata.typeAttributes.header];
      }
      if (this.columndata.typeAttributes.headerCSS) {
        this.imageHeaderCSS = this.columndata.typeAttributes.headerCSS;
      }
      if (this.columndata.typeAttributes.height) {
        this.imageHeight = this.columndata.typeAttributes.height;
      }
      if (this.columndata.typeAttributes.width) {
        this.imageWidth = this.columndata.typeAttributes.width;
      }
      if (this.columndata.typeAttributes.alttext) {
        this.imageAlt = this.columndata.typeAttributes.alttext;
      }

      if (this.columndata.typeAttributes.imageURLfld) {
        this.imageURL = this.value[this.columndata.typeAttributes.imageURLfld];
      } else {
        if (this.columndata.typeAttributes.imageURL) {
          this.imageURL = this.columndata.typeAttributes.imageURL;
        }
      }

      if (this.columndata.typeAttributes.imageCSS) {
        this.imageCSS = this.columndata.typeAttributes.imageCSS;
      }
    }
  }

  
  get custombuttonVisibility(){
    if (this.columndata.typeAttributes.label) {
      this.fldLabel = this.columndata.typeAttributes.label;
    }
    //Set Custom Button properties
    if (this.columndata.typeAttributes.visible) {
      this.buttonVisible = this.value[this.columndata.typeAttributes.visible];
    }

    if (this.columndata.typeAttributes.disable) {
      this.buttonDisable = this.value[this.columndata.typeAttributes.disable];
    }

    if (this.columndata.typeAttributes.style) {
      this.buttonCSS = this.columndata.typeAttributes.style;
    }
    if (this.columndata.typeAttributes.class) {
      this.buttonClass = this.columndata.typeAttributes.class;
    }
    return this.buttonVisible;
  }



  get imageLinkVisibility() {
    this.fldLabel = this.columndata.typeAttributes.label;

    if (this.columndata.typeAttributes.label) {
      this.fldLabel = this.columndata.typeAttributes.label;
    }
    //Set Custom image link properties
    if (this.columndata.typeAttributes.visible) {
      this.imageLinkVisible = this.value[
        this.columndata.typeAttributes.visible
      ];
    }
    if (this.columndata.typeAttributes.disable) {
      this.imageLinkDisable = this.value[
        this.columndata.typeAttributes.disable
      ];
    }
    if (this.columndata.typeAttributes.header) {
      this.imageHeader = this.value[this.columndata.typeAttributes.header];
    }
    if (this.columndata.typeAttributes.headerCSS) {
      this.imageHeaderCSS = this.columndata.typeAttributes.headerCSS;
    }
    if (this.columndata.typeAttributes.height) {
      this.imageHeight = this.columndata.typeAttributes.height;
    }
    if (this.columndata.typeAttributes.width) {
      this.imageWidth = this.columndata.typeAttributes.width;
    }
    if (this.columndata.typeAttributes.alttext) {
      this.imageAlt = this.columndata.typeAttributes.alttext;
    }

    if (this.columndata.typeAttributes.imageURLfld) {
      this.imageURL = this.value[this.columndata.typeAttributes.imageURLfld];
    } else {
      if (this.columndata.typeAttributes.imageURL) {
        this.imageURL = this.columndata.typeAttributes.imageURL;
      }
    }

    if (this.columndata.typeAttributes.imageCSS) {
      this.imageCSS = this.columndata.typeAttributes.imageCSS;
    }
    return this.imageLinkVisible;
  }


  get selectedOption() {
    for (let option in this.columndata.options) {
      if (
        this.columndata.options[option].value ===
        this.value[this.columndata.fieldName]
      ) {
        return JSON.parse(
          JSON.stringify(this.columndata.options[option].value)
        );
      }
    }
    return "";
  }

  get cellData() {
    let fieldValue = this.value[this.columndata.fieldName];
    if (this.isDateTime) {
      if (fieldValue) {
        const date = new Date(fieldValue);
        return date.toLocaleString(LOCALE, {
          timeZone: TIMEZONE,
          dateStyle: "short",
          timeStyle: "short"
        });
      }
      return "";
    } else if (this.isDate) {
      if (fieldValue) {
        const date = new Date(fieldValue);
        return date.toLocaleDateString(LOCALE, {
          dateStyle: "short"
        });
      }
      return "";
    } else if (this.isPercent) {
      return fieldValue / 100;
    } else if (this.isPicklist) {
      let pickListOption = [];
      let isSelected = false;
      this.columndata.options.forEach(option => {
        if (fieldValue === option.value) {
          isSelected = true;
        } else {
          isSelected = false;
        }
        pickListOption.push({
          label: option.label,
          value: option.value,
          selected: isSelected
        });
      });
      return pickListOption;
    } else if (this.isRecordLink) {
      //get Field label
      if (this.columndata.typeAttributes.label.fieldName) {
        return this.value[this.columndata.typeAttributes.label.fieldName];
      }
      return fieldValue;
    } else if (this.isCustomButton) {
      //get Field label
      if (this.columndata.typeAttributes.label) {
        this.fldLabel = this.columndata.typeAttributes.label;
        return this.columndata.typeAttributes.label;
      }
      return fieldValue;
    }
    return fieldValue;
  }

  //handle PickList value Changes
  handlePickListValueChange() {
    this.isEditPicklist = false;
    if (this.isPicklist) {
      if (this.selectPickListValue !== this.value[this.columndata.fieldName]) {
        const selectEvent = new CustomEvent("picklistvaluechange", {
          detail: {
            id: this.value.Id,
            field: this.columndata.fieldName,
            record: this.value,
            value: this.selectPickListValue
          }
        });
        this.dispatchEvent(selectEvent);
      }
    }
  }

  //handle Custom button Click
  handleCustomButtonClick() {
    if (this.isCustomButton && !this.buttonDisable) {
      let message = {
        Id: this.fldDataVal,
        label: this.fldLabel,
        buttonColumn: this.columndata,
        record: this.value
      };
      fireEvent(this.pageRef, "customCellButtonClick", message);
    }
  }

  //handle Custom button Click
  handleCustomImageLink() {
    console.log("handleCustomImageLink :: called");
    console.log("imageLinkDisable ::", this.imageLinkDisable);
    if (this.imageLinkDisable === false) {
      let message = {
        Id: this.fldDataVal,
        label: this.fldLabel,
        buttonColumn: this.columndata,
        record: this.value
      };
      fireEvent(this.pageRef, "customCellButtonClick", message);
    }
  }

  //For Pick list Value
  onSelectPickListValueChange(event) {
    this.selectPickListValue = event.target.value;
  }

  checkIsEditable() {
    this.isEditPicklist = this.isEditPicklist ? false : true;
  }

  //to generate the NavigateToSObject record URL
  generatenavigateURL() {
    // Generate a URL to a User record page
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.navigateRecordID,
        actionName: "view"
      }
    }).then(url => {
      this.navigareRecordURL = url;
    });
  }

  navigateToRecord() {
    if (this.navigateRecordID) {
      // Navigate to the Record View Page
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: this.navigateRecordID,
          actionName: "view"
        }
      });
    }
  }

  handleValueChange() {
    if (this.tableforlookup) {
      const selectEvent = new CustomEvent("rowaction", {
        detail: {
          row: this.value
        }
      });
      this.dispatchEvent(selectEvent);
    }
  }

  //getters

  get isBoolean() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "boolean"
      ? true
      : false;
  }

  get isButton() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "button"
      ? true
      : false;
  }

  get isButtonIcon() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "button-icon"
      ? true
      : false;
  }

  get isCurrency() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "currency"
      ? true
      : false;
  }

  get isDate() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "date"
      ? true
      : false;
  }

  get isDateTime() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "datetime"
      ? true
      : false;
  }

  get isEmail() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "email"
      ? true
      : false;
  }

  get isLocation() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "location"
      ? true
      : false;
  }

  get locationLatitude() {
    return this.columndata &&
      this.columndata.fieldName &&
      this.value[this.columndata.fieldName] &&
      this.value &&
      this.value[this.columndata.fieldName].latitude
      ? this.value[this.columndata.fieldName].latitude
      : 0;
  }
  get locationLongitude() {
    return this.columndata &&
      this.columndata.fieldName &&
      this.value[this.columndata.fieldName] &&
      this.value &&
      this.value[this.columndata.fieldName].longitude
      ? this.value[this.columndata.fieldName].longitude
      : 0;
  }

  get isNumber() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "number"
      ? true
      : false;
  }

  get isPercent() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "percent"
      ? true
      : false;
  }

  get isPhone() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "phone"
      ? true
      : false;
  }

  get isText() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "text"
      ? true
      : false;
  }

  get isLink() {
    return this.columndata.type === "link" ? true : false;
  }

  get isRecordLink() {
    return this.columndata.type === "recordLink" ? true : false;
  }

  get isCustomButton() {
    return this.columndata.type === "customButton" ? true : false;
  }

  get isCustomImageLink() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "customImageLink"
      ? true
      : false;
  }

  get isCustomLink() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "customLink"
      ? true
      : false;
  }

  get isURL() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "url"
      ? true
      : false;
  }
  get isPicklist() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "picklist"
      ? true
      : false;
  }
  get picklistValue() {
    return this.columndata &&
      this.columndata.type &&
      this.columndata.type === "picklist" &&
      this.value &&
      this.value[this.columndata.fieldName]
      ? this.value[this.columndata.fieldName]
      : "";
  }

  get isHTML() {
    if (
      this.columndata &&
      this.columndata.type &&
      this.columndata.type === "html"
    ) {
      let that = this;
      setTimeout(function() {
        let container = that.template.querySelector(".html-container");
        if (that.cellData) {
          container.innerHTML = that.cellData;
        }
      }, 100);
      return true;
    }
    return false;
  }
  get currencyCode() {
    return this.value && this.value.CurrencyISOCode
      ? this.value.CurrencyISOCode
      : null;
  }
}