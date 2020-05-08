/* eslint-disable no-console */
import { LightningElement, api, track } from "lwc";
export default class MultiPickList extends LightningElement {
  @api label = ""; //Name of the dropDown
  @api maxselected = 2; //Max selected item display
  @api options; // List of items to display
  @api showfilterinput = false; //show filterbutton
  @api showrefreshbutton = false; //show the refresh button
  @api showclearbutton = false; //show the clear button
  @api comboplaceholder = "Select a value";

  @track _initializationCompleted = false;
  @track _selectedItems = "Select a value";
  @track _filterValue;
  @track _mOptions = [];

  connectedCallback() {
    //this.initArray (this);
  }

  initArray(context) {
    this._mOptions.forEach(function(eachItem) {
      eachItem.selected = false;
      return;
    });
    this.options = this._mOptions;
  }

  get _mOptionsAvailable() {
    //console.log("--_mOptionsAvailable--");
    //console.log("--_mOptionsAvailable--options--", this.options);
    let opts = new Array();
    this.options.forEach(function(eachItem) {
      opts.push(JSON.parse(JSON.stringify(eachItem)));
    });
    this._mOptions = opts;
    return opts;
  }

  constructor() {
    super();
    this._filterValue = "";
    //this.showfilterinput = true;
    //this.showrefreshbutton = true;
    //this.showclearbutton = true;
  }
  renderedCallback() {
    let self = this;
    if (!this._initializationCompleted) {
      this.template
        .querySelector(".ms-input")
        .addEventListener("click", function(event) {
          //console.log ('multipicklist clicked');
          self.onDropDownClick();
          event.stopPropagation();
        });
      this.template.addEventListener("click", function(event) {
        //console.log ('multipicklist-1 clicked');
        event.stopPropagation();
      });
      document.addEventListener("click", function() {
        //console.log ('document clicked');
        self.closeAllDropDown();
      });
      this._initializationCompleted = true;
      this.setPickListName();
    }
  }

  handleItemSelected(event) {
    this._mOptions.forEach(function(eachItem) {
      if (eachItem.key == event.detail.item.key) {
        eachItem.selected = event.detail.selected;
        return;
      }
    });
    this.options = this._mOptions;
    this.setPickListName();
    this.onItemSelected();
  }

  filterDropDownValues(event) {
    this._filterValue = event.target.value;
    this.updateListItems(this._filterValue);
  }
  closeAllDropDown() {
    Array.from(this.template.querySelectorAll(".ms-picklist-dropdown")).forEach(
      function(node) {
        node.classList.remove("slds-is-open");
      }
    );
  }

  onDropDownClick() {
    let classList = Array.from(
      this.template.querySelectorAll(".ms-picklist-dropdown")
    );
    if (!classList.includes("slds-is-open")) {
      this.closeAllDropDown();
      Array.from(
        this.template.querySelectorAll(".ms-picklist-dropdown")
      ).forEach(function(node) {
        node.classList.add("slds-is-open");
      });
    } else {
      this.closeAllDropDown();
    }
  }
  onRefreshClick() {
    this._filterValue = "";
    this.initArray(this);
    this.updateListItems("");
    this.onItemSelected();
  }
  onClearClick() {
    this._filterValue = "";
    this.updateListItems("");
  }

  updateListItems(inputText) {
    Array.from(this.template.querySelectorAll("c-pick-list-item")).forEach(
      function(node) {
        if (!inputText) {
          node.style.display = "block";
        } else if (
          node.item.value
            .toString()
            .toLowerCase()
            .indexOf(
              inputText
                .toString()
                .trim()
                .toLowerCase()
            ) != -1
        ) {
          node.style.display = "block";
        } else {
          node.style.display = "none";
        }
      }
    );
    this.setPickListName();
  }
  setPickListName() {
    let selecedItems = this.getSelectedItems();
    let selections = "";
    if (selecedItems.length < 1) {
      selections = this.comboplaceholder;
    } else if (selecedItems.length > this.maxselected) {
      selections = selecedItems.length + " Options Selected";
    } else {
      selecedItems.forEach(option => {
        selections += option.value + ",";
      });
    }
    this._selectedItems = selections;
  }
  @api
  getSelectedItems() {
    let resArray = new Array();
    this._mOptions.forEach(function(eachItem) {
      if (eachItem.selected) {
        resArray.push(eachItem);
      }
    });
    return resArray;
  }

  onItemSelected() {
    const evt = new CustomEvent("itemselected", {
      detail: this.getSelectedItems()
    });
    this.dispatchEvent(evt);
  }
}