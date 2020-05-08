/* eslint-disable no-console */
import { LightningElement, api, wire, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// importing to get the record details based on record id
import { getRecord } from "lightning/uiRecordApi";

import { registerListener, unregisterAllListeners } from "c/pubsub";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
// impoting USER id
import USER_ID from "@salesforce/user/Id";
import getOpportunityRecords from "@salesforce/apex/LWCRenewalNotificationController.getOpportunityRecords";
import updateOpportunityRecord from "@salesforce/apex/LWCRenewalNotificationController.updateOpportunityRecord";
import getOpportunityRecordsUnCached from "@salesforce/apex/LWCRenewalNotificationController.getOpportunityRecordsUnCached";
import getFieldSetMember from "@salesforce/apex/LWCRenewalNotificationController.getFieldSetMember";
import getcontactlist from "@salesforce/apex/LWCRenewalNotificationController.getcontactlist";
import savecontacts from "@salesforce/apex/LWCRenewalNotificationController.savecontacts";
import getTerminationTemplateId from "@salesforce/apex/LWCRenewalNotificationController.getTerminationTemplateId";
import getPastdueTemplateId from "@salesforce/apex/LWCRenewalNotificationController.getPastdueTemplateId";
import getFuturenotificationTemplateId from "@salesforce/apex/LWCRenewalNotificationController.getFuturenotificationTemplateId";
import additionalemailtoTerminate from "@salesforce/apex/LWCRenewalNotificationController.additionalemailtoTerminate";
import getGeoAndRepPicklistValues from "@salesforce/apex/LWCRenewalNotificationController.getGeoAndRepPicklistValues";
import createAndAddExtension from "@salesforce/apex/LWCRenewalNotificationController.createAndAddExtension";

//Columns For Upcoming Renewals
const columnsUR = [
  {
    label: "Owner name",
    fieldName: "ownerIdUrl",
    type: "recordLink",
    typeAttributes: { label: { fieldName: "Owner_Name" }, target: "_blank" },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 7.2rem;",
    cellClass: "slds-truncate",
    sortable: true
  },
  {
    label: "Opportunity name",
    fieldName: "oppIdUrl",
    type: "recordLink",
    initialWidth: 300,
    typeAttributes: { label: { fieldName: "Name" }, target: "_blank" },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 22rem;",
    cellClass: "slds-cell-wrap slds-text-align_center",
    sortable: true
  },
  {
    label: "Contract End Date",
    fieldName: "Contract_End_Date_New__c",
    type: "date",
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 9rem;",
    cellClass: "slds-truncate slds-text-align_center",
    sortable: true
  },
  {
    label: "Close Date",
    fieldName: "CloseDate",
    type: "date",
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: center;width: 7rem;",
    cellClass: "slds-truncate slds-text-align_center",
    sortable: true
  },
  {
    label: "Renewal ACV",
    fieldName: "Renewable_ACV__c",
    type: "currency",
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: center;width: 8rem;",
    cellClass: "slds-truncate ",
    sortable: true
  },
  {
    label: "Remaining days in contract",
    fieldName: "daystocontractdate",
    type: "number",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: left;width: 8rem;",
    cellClass: "slds-truncate",
    cellStyle: "",
    sortable: true
  },
  {
    label: "Send Notification",
    fieldName: "Renewal_Notification_Status__c",
    type: "picklist",
    options: [
      {
        label: "Yes",
        value: "Yes"
      },
      {
        label: "No",
        value: "No"
      }
    ],
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 9rem;",
    cellClass: "slds-truncate slds-text-align_center",
    editable: true
  },
  {
    label: "Next Notification Date",
    fieldName: "Next_Renewal_Notification_Date__c",
    type: "date",
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 12rem;",
    cellClass: "slds-truncate slds-text-align_center",
    sortable: true
  },
  {
    label: "Add Partner Contacts",
    fieldName: "Id",
    type: "customImageLink",
    typeAttributes: {
      label: "Add Partner Contacts",
      header: "partnercontactname",
      headerCSS: "text-align:center;",
      imageURLfld: "addPartnerContactImageURL",
      imageCSS: "text-align:center;",
      height: "18",
      width: "18",
      disable: "isAddPartnerContactDisable",
      visible: "isAddPartnerContactVisible",
      alttext: "Add Partner Contacts"
    },
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    sortable: false
  },
  {
    label: "Add Customer Contacts",
    fieldName: "Id",
    type: "customImageLink",
    typeAttributes: {
      label: "Add Customer Contacts",
      header: "customercontactname",
      headerCSS: "text-align:center;",
      imageURLfld: "addCustomerContactImageURL",
      imageCSS: "text-align:center;",
      height: "18",
      width: "18",
      disable: "isAddCustomerContactDisable",
      visible: "isAddCustomerContactVisible",
      alttext: "Add Customer Contacts"
    },
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    sortable: false
  },
  {
    label: "Amount",
    fieldName: "Amount",
    type: "currency",
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-truncate",
    sortable: true
  },
  {
    label: "",
    fieldName: "Id",
    type: "customButton",
    typeAttributes: {
      label: "Notify Now",
      disable: "isNotifyNowDisabled",
      visible: "isNotifyNowVisible",
      style:
        "font-size: 11px;padding: 0px 5px;border-radius: 0.em;margin: 0px;color: #333;border: 1px solid #b5b5b5;border-bottom-color: #7f7f7f;background: #e8e8e9 url(/img/alohaSkin/btn_sprite.png) repeat-x right top;-moz-border-radius: 3px;-webkit-border-radius: 3px;",
      class: ""
    },
    customClass: "slds-truncate",
    cellClass: "slds-truncate",
    sortable: false
  }
];

//Columns For Manage Extentions
const columnsME = [
  {
    label: "Action",
    fieldName: "Id",
    type: "customButton",
    typeAttributes: {
      label: "Request Approval",
      disable: "isRequestApprovalButtonDisable",
      visible: "isRequestApprovalButtonVisible",
      style:
        "font-size: 9px;padding: 0px 5px;border-radius: 0.em;margin: 0px;color: #333;border: 1px solid #b5b5b5;border-bottom-color: #7f7f7f;background: #e8e8e9 url(/img/alohaSkin/btn_sprite.png) repeat-x right top;-moz-border-radius: 3px;-webkit-border-radius: 3px;"
    },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;width: 6rem;",
    cellClass: "slds-truncate",
    sortable: false
  },
  {
    label: "Owner name",
    fieldName: "ownerIdUrl",
    type: "recordLink",
    typeAttributes: {
      label: { fieldName: "Owner_Name" },
      target: "_blank",
      style: "font-size: x-small;"
    },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: left;width: 6rem;",
    cellClass: "slds-truncate",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Opportunity name",
    fieldName: "oppIdUrl",
    type: "recordLink",
    initialWidth: 300,
    typeAttributes: {
      label: { fieldName: "Name" },
      target: "_blank",
      style: "font-size: x-small;"
    },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;text-align: center;width: 16rem;",
    cellClass: "slds-cell-wrap slds-text-align_center",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Contract End Date",
    fieldName: "Contract_End_Date_New__c",
    type: "date",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small; text-align: center;width: 5rem;",
    cellClass: "slds-truncate slds-text-align_center",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Close Date",
    fieldName: "CloseDate",
    type: "date",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 5rem;",
    cellClass: "slds-truncate slds-text-align_center",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Renewal ACV",
    fieldName: "Renewable_ACV__c",
    type: "currency",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 7rem;",
    cellClass: "slds-cell-wrap ",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Days Past Due",
    fieldName: "daystocontractdate",
    type: "number",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Status",
    fieldName: "Extension_Approval_Status__c",
    type: "text",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    cellStyle: "font-size: 12px;text-align: center;",
    sortable: true
  },
  {
    label: "Contract Extended To",
    fieldName: "New_Extended_Contract_Date__c",
    type: "date",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-truncate",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Number of Extensions",
    fieldName: "Number_of_Extension_Requests__c",
    type: "number",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-truncate ",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Send Notification",
    fieldName: "Past_Due_Notification_Status__c",
    type: "picklist",
    options: [
      {
        label: "Yes",
        value: "Yes"
      },
      {
        label: "No",
        value: "No"
      }
    ],
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 7rem;",
    cellClass: "slds-truncate slds-text-align_center",
    cellStyle: "font-size: 12px;",
    editable: true
  },

  {
    label: "Terminate Subscription",
    fieldName: "Id",
    type: "customButton",
    typeAttributes: {
      label: "Terminate Subscription",
      disable: "isTerminateSubscriptionDisabled",
      visible: "isTerminateSubscriptionVisible",
      style:
        "font-size: xx-small;padding: 0px 5px;border-width: 1px;border-style: solid;border-radius: 3px;background: firebrick;color: white;",
      class: ""
    },
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 8rem;",
    cellClass: "slds-truncate",
    cellStyle: "font-size: 12px;",
    sortable: false
  },

  {
    label: "Next Notification Date",
    fieldName: "Next_Renewal_Notification_Date__c",
    type: "date",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 7rem;",
    cellClass: "slds-truncate slds-text-align_center",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Amount",
    fieldName: "Amount",
    type: "currency",
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;width: 7rem;",
    cellClass: "slds-truncate",
    cellStyle: "font-size: 12px;",
    sortable: true
  },
  {
    label: "Add Partner Contacts",
    fieldName: "Id",
    type: "customImageLink",
    typeAttributes: {
      label: "Add Partner Contacts",
      header: "partnercontactname",
      headerCSS: "text-align:center;",
      imageURLfld: "addPartnerContactImageURL",
      imageCSS: "text-align:center;",
      height: "18",
      width: "18",
      disable: "isAddPartnerContactDisable",
      visible: "isAddPartnerContactVisible",
      alttext: "Add Partner Contacts"
    },
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    cellStyle: "font-size: 12px;",
    sortable: false
  },
  {
    label: "Add Customer Contacts",
    fieldName: "Id",
    type: "customImageLink",
    typeAttributes: {
      label: "Add Customer Contacts",
      header: "customercontactname",
      headerCSS: "text-align:center;",
      imageURLfld: "addCustomerContactImageURL",
      imageCSS: "text-align:center;",
      height: "18",
      width: "18",
      disable: "isAddCustomerContactDisable",
      visible: "isAddCustomerContactVisible",
      alttext: "Add Customer Contacts"
    },
    customClass: "slds-cell-wrap",
    customStyle: "font-size: x-small;text-align: center;",
    cellClass: "slds-cell-wrap",
    cellStyle: "font-size: 12px;",
    sortable: false
  },
  {
    label: "",
    fieldName: "Id",
    type: "customButton",
    typeAttributes: {
      label: "Notify Now",
      disable: "isNotifyNowDisabled",
      visible: "isNotifyNowVisible",
      style:
        "font-size: x-small;padding: 0px 5px;border-radius: 0.em;margin: 0px;color: #333;border: 1px solid #b5b5b5;border-bottom-color: #7f7f7f;background: #e8e8e9 url(/img/alohaSkin/btn_sprite.png) repeat-x right top;-moz-border-radius: 3px;-webkit-border-radius: 3px;",
      class: ""
    },
    customClass: "slds-truncate",
    customStyle: "font-size: x-small;",
    cellClass: "slds-truncate",
    cellStyle: "font-size: 12px;",
    sortable: false
  }
];

export default class Renewal_Notification_Console extends NavigationMixin(
  LightningElement
) {
  @api sendnotification = ["Yes", "No"];
  @api fcvals = [
    "Omitted",
    "Pipeline",
    "Most Likely",
    "Best Case",
    "Commit",
    "Closed"
  ];
  @api dealband = [
    "< $25K",
    "$25K - $50K",
    "$50K - $100K",
    "$100K - $250K",
    "$250K - $1M",
    "> $1M"
  ];

  @api dayspastduevals = ["1-10", "11-20", "21-30", "30+"];

  @track noOfExtensionvals = [];
  @track geovals = [];
  @track repvals = [];

  @track geoMap;

  @track objUser = {};

  // Api considered as a reactive public property.
  @api totalrecords;
  @api currentpageUR = 1;
  @api currentpageME = 1;

  @api pagesize = 20;

  @track futurenotificationTemplateId;
  @track pastDueTemplateId;

  //termination template ID
  @track terminationTemplateId;
  @track additionalTerminateEmail;

  //For opportunity List
  @track wiredRecordList = [];
  @track recordList = [];
  @track recordListUR = [];
  @track recordListME = [];
  @track urfldList = columnsUR;
  @track mefldList = columnsME;

  //For Sorting
  @track sortBy = "daystocontractdate";
  @track sortDirection = "asc";

  //Spinner
  @track isLoaded = false;

  //Error Handling
  @track hasError = false;
  @track errorMessage;

  @wire(CurrentPageReference) pageRef;

  //get Filter Details
  @track filterStrUR = "";
  @track filterStrME = "";

  //Open Request Approval Modal
  @track openExtentionModal = false;
  @track addExtentionLoaded = false;
  @track addExtentionHasError = false;
  @track addExtentionRequestCalled = false;
  @track addExtentionErrorMessage;
  @track extentionfldWrapper;

  //App partner/Customer Contact
  @track addPartnerContcat = false;
  @track addContactType;
  @track addContactfldWrapper;
  @track contactListWrapper;
  @track openAddContact = false;
  @track addContactLoaded = false;
  @track addContactHasError = false;
  @track addContactErrorMessage = false;
  @track addContactSuccess = false;
  @track addContactSuccessMessage;
  @track addNewContactfldWrapper;
  @track addNewContactLoaded = false;
  @track addNewContactRequestCalled = false;
  @track addNewContactErrorMessage;
  @track addNewContactSuccess = false;
  @track addNewContactSuccessMessage;
  @track showAddNewContact = false;
  @track addNewContactAccountID;

  //Terminate Subscription Modal
  @track openTerminateSubscription = false;

  //Notify Now
  @track openNotifyNow = false;
  @track fromAdd;
  @track toAdd;
  @track additionalTo;
  @track ccAdd;
  @track bccAdd;
  @track emailTemplateId;
  @track relatedTmplateId;

  //Add Extention Request [Request Approval]
  @track selectedOpportunityId;

  //Default Tab
  @track currentTab = "Upcoming Renewals";

  disconnectedCallback() {
    unregisterAllListeners(this);
  }

  connectedCallback() {
    console.log("::Renewal_Notification_Console connectedCallback called ::");
    registerListener("customCellButtonClick", this.pubsubEventhandler, this);
  }

  //using wire service getting current user data
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [
      "User.FirstName",
      "User.LastName",
      "User.Name",
      "User.Alias",
      "User.IsActive",
      "User.Level__c",
      "User.Email",
      "User.Show_Rep_Filter_on_Renewal_Console__c"
    ]
  })
  userData({ error, data }) {
    if (data) {
      //window.console.log("data ====> " + JSON.stringify(data));
      let objCurrentData = data.fields;
      this.objUser = {
        FirstName: objCurrentData.FirstName.value,
        LastName: objCurrentData.LastName.value,
        Name: objCurrentData.Name.value,
        Alias: objCurrentData.Alias.value,
        Email: objCurrentData.Email.value,
        IsActive: objCurrentData.IsActive.value,
        Show_Rep_Filter_on_Renewal_Console__c:
          objCurrentData.Show_Rep_Filter_on_Renewal_Console__c.value
      };
    } else if (error) {
      window.console.log("error ====> " + JSON.stringify(error));
    }
  }

  //using Wire service for getting Email template for Terminate Email
  @wire(getTerminationTemplateId)
  getEmailTemplate(result) {
    if (result.data) {
      this.terminationTemplateId = result.data;
    } else if (result.error) {
      this.terminationTemplateId = "";
    }
  }

  //using Wire service for getting Email template for Past Due
  @wire(getPastdueTemplateId)
  getEmailTemplatePastDue(result) {
    if (result.data) {
      this.pastDueTemplateId = result.data;
    } else if (result.error) {
      this.pastDueTemplateId = "";
    }
  }

  //using Wire service for getting Email template Future notification
  @wire(getFuturenotificationTemplateId)
  getFuturenotificationTemplateId(result) {
    if (result.data) {
      this.futurenotificationTemplateId = result.data;
    } else if (result.error) {
      this.pastDueTemplateId = "";
    }
  }

  //using Wire service for getting Email template
  @wire(additionalemailtoTerminate)
  getadditionalemailtoTerminate(result) {
    if (result.data) {
      this.additionalTerminateEmail = result.data;
    } else if (result.error) {
      this.additionalTerminateEmail = "";
    }
  }

  //using wire service getting current user data
  @wire(getFieldSetMember, {
    objectName: "Contract_Extension_Request__c",
    fieldSetName: "Contract_Extension_Creation_Renewal_Noti"
  })
  getFieldsetData({ error, data }) {
    if (data) {
      console.log("getFieldSetMember data::", data);
      this.extentionfldWrapper = JSON.parse(data);
      this.extentionfldWrapper.forEach((wrap, index) => {
        wrap.fieldIndex = "fld_" + index;
      });
    } else if (error) {
      window.console.log("error ====> ", JSON.stringify(error));
    }
  }

  //using Wire service for getting opportunity Records
  @wire(getOpportunityRecords, {
    filterStr: "",
    selectedTab: "$currentTab",
    offset: 0
  })
  opportunityRecordListWrapper(result) {
    this.wiredRecordList = result;
    if (result.data) {
      this.parseOpportunityListdata(result.data);
    } else if (result.error) {
      this.isLoaded = true;
      console.log("error ====> " + JSON.stringify(error));
    }
  }

  //using Wire service for getting Geo And Rep Filters
  @wire(getGeoAndRepPicklistValues)
  getALLGeoAndRepPicklistValues(result) {
    if (result.data) {
      let geoParsedMap = JSON.parse(result.data);
      console.log("getGeoAndRepPicklistValues data ====> ", geoParsedMap);
      this.geoMap = geoParsedMap;
      let geos = [];
      let reps = [];
      for (var key in geoParsedMap) {
        geos.push(key);
        for (var rep in geoParsedMap[key]) {
          if (!reps.includes(geoParsedMap[key][rep])) {
            reps.push(geoParsedMap[key][rep]);
          }
        }
      }
      //console.log("getGeoAndRepPicklistValues geos ====> ", geos);
      //console.log("getGeoAndRepPicklistValues reps ====> ",reps);
      this.geovals = geos;
      this.repvals = reps;
    } else if (result.error) {
      this.isLoaded = true;
      console.log("error ====> " + JSON.stringify(error));
    }
  }

  //handle Geo Value Changes
  handleOnGeoFilterValueChange(event) {
    console.log("----handleOnGeoFilterValueChange called----");
    if (event.detail) {
      console.log(JSON.stringify(event.detail));
      let geoParsedMap = this.geoMap;
      let reps = [];
      let fltr = event.detail;
      if (fltr.fieldValue) {
        fltr.fieldValue.split(",").forEach(function (geo) {
          let geoVal = geo.trim();
          if (geoVal && geoVal.length > 0) {
            for (var rep in geoParsedMap[geoVal]) {
              if (!reps.includes(geoParsedMap[geoVal][rep])) {
                reps.push(geoParsedMap[geoVal][rep]);
              }
            }
          }
        });
      } else {
        for (var key in geoParsedMap) {
          for (var rep in geoParsedMap[key]) {
            if (!reps.includes(geoParsedMap[key][rep])) {
              reps.push(geoParsedMap[key][rep]);
            }
          }
        }
      }
      this.repvals = reps;
    }
  }

  //handle PUBSUB Event
  pubsubEventhandler(event) {
    console.log("::pubsubEvent called ::");
    console.log("--event--", JSON.stringify(event));
    let data = event;

    this.selectedOpportunityId = data.Id;
    if (data.label === "Request Approval") {
      this.openAddExtentionModal();
    } else if (data.label === "Add Partner Contacts") {
      this.addContactType = "Partner";
      this.openAddContactModal();
    } else if (data.label === "Add Customer Contacts") {
      this.addContactType = "Customer";
      this.openAddContactModal();
    } else if (data.label === "Terminate Subscription") {
      console.log("--open--TerminateSubscriptionModal--");
      this.openTerminateSubscriptionModal();
    } else if (data.label === "Notify Now") {
      console.log("--open--Notify Now--");
      this.openNotifyModal();
    }
  }

  //on Click of Filter Button
  getFilterItems() {
    this.isLoaded = false;

    console.log("----getFilterItems called----");
    let filterListUR = new Array();
    let filterListME = new Array();

    this.template.querySelectorAll("c-filter-component").forEach((element) => {
      let filterVal = element.getFiltervalue();
      console.log("---FilterVal---", JSON.stringify(filterVal));

      if (filterVal.fldorigin === "UpcomingRenewals") {
        if (filterVal.fieldValue) {
          filterListUR.push(element.getFiltervalue());
        } else {
          if (filterVal.isRange) {
            if (filterVal.valFrom) {
              filterListUR.push(element.getFiltervalue());
            } else if (filterVal.valTo) {
              filterListUR.push(element.getFiltervalue());
            }
          }
        }
      } else if (filterVal.fldorigin === "ManageExtentions") {
        if (filterVal.fieldValue) {
          filterListME.push(element.getFiltervalue());
        } else {
          if (filterVal.isRange) {
            if (filterVal.valFrom) {
              filterListME.push(element.getFiltervalue());
            } else if (filterVal.valTo) {
              filterListME.push(element.getFiltervalue());
            }
          }
        }
      }
    });

    this.filterStrUR = JSON.stringify(filterListUR);
    this.filterStrME = JSON.stringify(filterListME);
    console.log("filterStrUR :", this.filterStrUR);
    console.log("filterStrME :", this.filterStrME);

    //get all opportunities from APEX
    let filterStr;
    console.log("--this.currentTab--", this.currentTab);
    if (this.currentTab === "Upcoming Renewals") {
      filterStr = this.filterStrUR;
    } else if (this.currentTab === "Manage Extensions") {
      filterStr = this.filterStrME;
    } else {
      filterStr = this.filterStrUR;
    }
    console.log("--filterStr--", filterStr);
    getOpportunityRecords({
      filterStr: filterStr,
      offset: 0,
      selectedTab: this.currentTab
    })
      .then((result) => {
        console.log("--result--", JSON.stringify(result));
        this.parseOpportunityListdata(result);
      })
      .catch((error) => {
        this.isLoaded = true;
        this.hasError = true;
        this.errorMessage = error;
      });
  }

  //if filter Value changes
  handleOnFilterValueChange(event) {
    console.log("----handleOnFilterValueChange called----");
    if (event.detail) {
      //console.log(JSON.stringify(event.detail));
    }
  }

  //On Change of Page Number
  handleOnselectedPageValueChangeUR(event) {
    this.isLoaded = false;
    console.log("----handleOnselectedPageValueChangeUR called----");
    if (
      event.detail &&
      this.currentpageUR !== event.detail &&
      event.detail > 0
    ) {
      console.log("this.currentpageUR ::", this.currentpageUR);
      console.log("event.detail ::", event.detail);
      this.currentpageUR = event.detail;
      this.getOpportunityRecordsWithFilter();
    } else {
      this.isLoaded = true;
    }
  }

  //On Change of Page Number
  handleOnselectedPageValueChangeME(event) {
    this.isLoaded = false;
    console.log("----handleOnselectedPageValueChangeME called----");
    if (
      event.detail &&
      this.currentpageME !== event.detail &&
      event.detail > 0
    ) {
      console.log("this.currentpageME ::", this.currentpageME);
      console.log("event.detail ::", event.detail);
      this.currentpageME = event.detail;
      this.getOpportunityRecordsWithFilter();
    } else {
      this.isLoaded = true;
    }
  }

  //get all opportunities from APEX
  getOpportunityRecordsWithFilter() {
    console.log("--getOpportunityRecordsWithFilter called--");
    try {
      let filterStr;
      let pageNum;
      console.log("--this.currentTab--", this.currentTab);
      if (this.currentTab === "Upcoming Renewals") {
        filterStr = this.filterStrUR;
        pageNum = this.currentpageUR;
      } else if (this.currentTab === "Manage Extensions") {
        filterStr = this.filterStrME;
        pageNum = this.currentpageME;
      } else {
        filterStr = this.filterStrUR;
        pageNum = this.currentpageUR;
      }
      console.log("--filterStr--", filterStr);
      console.log("--pageNum--", pageNum);

      getOpportunityRecordsUnCached({
        filterStr: filterStr,
        offset: pageNum,
        selectedTab: this.currentTab
      })
        .then((result) => {
          console.log("--result--", JSON.stringify(result));
          this.parseOpportunityListdata(result);
        })
        .catch((error) => {
          this.isLoaded = true;
          this.hasError = true;
          this.errorMessage = error;
        });
    } catch (error) {
      this.isLoaded = true;
      this.hasError = true;
      this.errorMessage = error;
    }
  }

  //Parse Data
  parseOpportunityListdata(data) {
    console.log("parseOpportunityListdata :: called");
    this.recordList = [];

    try {
      let recordListWrap = data;

      console.log("parseOpportunityListdata :: data", data);

      if (recordListWrap.hasError) {
        this.hasError = true;
        this.errorMessage = recordListWrap.errorMessage;
      } else {
        if (this.currentTab === "Upcoming Renewals") {
          this.recordListUR = [];
        } else if (this.currentTab === "Manage Extensions") {
          this.recordListME = [];
        } else {
          this.recordListUR = [];
        }

        console.log(" this.recordListUR ::", this.recordListUR);
        console.log(" this.recordListME ::", this.recordListME);

        this.hasError = false;
        this.errorMessage = "";
        this.totalrecords = recordListWrap.totalRecords;

        if (this.currentTab === "Upcoming Renewals") {
          this.currentpageUR = recordListWrap.pageNumber;
        } else if (this.currentTab === "Manage Extensions") {
          this.currentpageME = recordListWrap.pageNumber;
        } else {
          this.currentpageUR = recordListWrap.pageNumber;
        }

        //Set Number of Extentions
        if (data.NumberofExtensionsArray) {
          console.log(" --setting NumberofExtensionsArray--");
          this.noOfExtensionvals = data.NumberofExtensionsArray;
        }
        //Set DaysPasDue
        if (data.DaysPastDueArray) {
          //this.dayspastduevals = data.DaysPastDueArray;
        }

        //set from parent wrapper
        recordListWrap.oppWrapList.forEach((ele) => {
          let daystocontractdate;
          let haspartner;
          let showredpartner;
          let showordinarypartner;
          let hasaccount;
          let showredcustomer;
          let showordinarycustomer;
          let customercontactname;
          let partnercontactname;
          let customercontactemail;
          let partnercontactemail;
          if (ele.opp) {
            daystocontractdate = ele.daystocontractdate;
            haspartner = ele.haspartner;
            showredpartner = ele.showredpartner;
            showordinarypartner = ele.showordinarypartner;
            hasaccount = ele.hasaccount;
            showredcustomer = ele.showredcustomer;
            showordinarycustomer = ele.showordinarycustomer;
            customercontactname = ele.customercontactname;
            partnercontactname = ele.partnercontactname;
            customercontactemail = ele.customercontactemail;
            partnercontactemail = ele.partnercontactemail;
            let eleUpdated = {
              ...ele.opp,
              daystocontractdate,
              haspartner,
              showredpartner,
              showordinarypartner,
              hasaccount,
              showredcustomer,
              showordinarycustomer,
              customercontactname,
              customercontactemail,
              partnercontactname,
              partnercontactemail
            };
            this.recordList.push(eleUpdated);
          }
        });

        console.log(" --this.recordList--", this.recordList);

        //set from existing values
        let oppIdUrl;
        let ownerIdUrl;
        let Owner_Name;
        this.recordList = this.recordList.map((opp) => {
          ownerIdUrl = `${opp.OwnerId}`;
          oppIdUrl = `${opp.Id}`;
          Owner_Name = opp.Owner.Name;
          return { ...opp, oppIdUrl, ownerIdUrl, Owner_Name };
        });

        //Nitify Me
        this.recordList = this.recordList.map((opp) => {
          let isNotifyNowDisabled = false;
          let isNotifyNowVisible = true;
          return {
            ...opp,
            isNotifyNowDisabled,
            isNotifyNowVisible
          };
        });

        //Request Terminate Subscription
        this.recordList = this.recordList.map((opp) => {
          let isTerminateSubscriptionDisabled = false;
          let isTerminateSubscriptionVisible = true;
          return {
            ...opp,
            isTerminateSubscriptionDisabled,
            isTerminateSubscriptionVisible
          };
        });

        //Request Approval Action button
        this.recordList = this.recordList.map((opp) => {
          let isRequestApprovalButtonVisible = true;
          let isRequestApprovalButtonDisable = false;
          if (
            opp.Extension_Approval_Status__c &&
            opp.Extension_Approval_Status__c === "Pending Approval"
          ) {
            isRequestApprovalButtonDisable = true;
            isRequestApprovalButtonVisible = false;
          }
          return {
            ...opp,
            isRequestApprovalButtonDisable,
            isRequestApprovalButtonVisible
          };
        });
      }

      //Add Partner Contact
      this.recordList = this.recordList.map((opp) => {
        let isAddPartnerContactDisable = true;
        let isAddPartnerContactVisible = false;
        let addPartnerContactImageURL;
        if (opp.haspartner && opp.haspartner === true) {
          isAddPartnerContactVisible = true;
          isAddPartnerContactDisable = false;
          if (opp.showredpartner && opp.showredpartner === true) {
            addPartnerContactImageURL =
              "/resource/1575613756000/Renewal_Notification/img/download-error.png";
          }
          if (opp.showordinarypartner && opp.showordinarypartner === true) {
            addPartnerContactImageURL =
              "/resource/1575613756000/Renewal_Notification/img/download.png";
          }
        }
        return {
          ...opp,
          isAddPartnerContactDisable,
          isAddPartnerContactVisible,
          addPartnerContactImageURL
        };
      });

      //Add Customer Contact
      this.recordList = this.recordList.map((opp) => {
        let isAddCustomerContactDisable = true;
        let isAddCustomerContactVisible = false;
        let addCustomerContactImageURL;
        if (opp.hasaccount && opp.hasaccount === true) {
          isAddCustomerContactVisible = true;
          isAddCustomerContactDisable = false;
          if (opp.showredcustomer && opp.showredcustomer === true) {
            addCustomerContactImageURL =
              "/resource/1575613756000/Renewal_Notification/img/download-error.png";
          }
          if (opp.showordinarycustomer && opp.showordinarycustomer === true) {
            addCustomerContactImageURL =
              "/resource/1575613756000/Renewal_Notification/img/download.png";
          }
        }
        return {
          ...opp,
          isAddCustomerContactDisable,
          isAddCustomerContactVisible,
          addCustomerContactImageURL
        };
      });

      if (this.currentTab === "Upcoming Renewals") {
        this.recordListUR = this.recordList;
      } else if (this.currentTab === "Manage Extensions") {
        this.recordListME = this.recordList;
      }

      console.log(" --this.recordList--", this.recordList);

      //Set Spinner to false
      this.isLoaded = true;
    } catch (error) {
      this.isLoaded = true;
      this.hasError = true;
      this.errorMessage = error;
    }
  }

  // in order to refresh your data, execute this function:
  resetOpportunityData() {
    console.log(":: refreshData :: called");
    if (this.currentTab === "Upcoming Renewals") {
      this.filterStrUR = "";
      this.currentpageUR = 0;
    } else if (this.currentTab === "Manage Extensions") {
      this.filterStrME = "";
      this.currentpageME = 0;
    } else {
      this.filterStrUR = "";
      this.currentpageUR = 0;
    }
    this.getOpportunityRecordsWithFilter();
  }

  //handle DataTable value Change event
  handleDataTableRecordValueChangeEvent(event) {
    console.log(":: handleDataTableRecordValueChangeEvent :: called");
    try {
      let recordVal = event.detail;
      console.log("--recordVal--", JSON.stringify(recordVal));
      if (recordVal) {
        this.isLoaded = false;
        updateOpportunityRecord({
          recorId: recordVal.id,
          field: recordVal.field,
          value: recordVal.value
        })
          .then((result) => {
            console.log(":: result ::", JSON.stringify(result));
            if (result.isSuccess) {
              //Refresh Data from Apex
              refreshApex(this.wiredRecordList);

              //Show Toast message
              this.showToastMsg(
                "Sucess",
                result.successMsg,
                "success",
                "dismissable"
              );
            } else {
              this.showToastMsg(
                "Error",
                result.errorMessage,
                "error",
                "dismissable"
              );
            }

            this.isLoaded = true;
          })
          .catch((error) => {
            this.hasError = true;
            this.isLoaded = true;
            this.errorMessage = error;
          });
      }
    } catch (error) {
      this.isLoaded = true;
      this.hasError = true;
      this.errorMessage = error;
    }
  }

  changeActiveTabtoUR() {
    console.log("-changeActiveTabtoUR--called");
    if (this.currentTab !== "Upcoming Renewals") {
      this.isLoaded = false;
      this.currentTab = "Upcoming Renewals";
      this.getOpportunityRecordsWithFilter();
    }
  }

  changeActiveTabtoME() {
    console.log("-changeActiveTabtoME--called");
    if (this.currentTab !== "Manage Extensions") {
      this.isLoaded = false;
      this.currentTab = "Manage Extensions";
      this.getOpportunityRecordsWithFilter();
    }
  }

  /*Add Contact record Section Starts here*/

  //Reset Error Details
  resetAddContactError() {
    this.addContactHasError = false;
    this.addContactErrorMessage = "";
  }

  resetAddContactSuccessDetails() {
    this.addContactSuccess = false;
    this.addContactSuccessMessage = "";
  }

  resetAddNewContactError() {
    this.addNewContactLoaded = false;
    this.addNewContactErrorMessage = false;
  }

  //Open AddContact Partner/Customer Modal
  openAddContactModal() {
    this.isLoaded = false;
    this.resetAddContactError();
    this.resetAddContactSuccessDetails();
    if (this.selectedOpportunityId) {
      this.getContactWrapperList();
    } else {
      this.isLoaded = true;
    }
  }

  //Close AddContact Partner/Customer Modal
  closeAddContactModal() {
    this.openAddContact = false;
    this.showAddNewContact = false;
  }

  //get Contcat Wrapper List
  getContactWrapperList() {
    console.log("getContactWrapperList called");
    let opp;
    let ContactAddtionaccId;
    console.log("--getContactWrapperList--", this.recordList);
    this.recordList.forEach((record) => {
      if (record.Id === this.selectedOpportunityId) {
        opp = record;
        ContactAddtionaccId =
          record.APTS_Primary_Proposal_Lookup__r
            .Apttus_QPConfig__BillToAccountId__c;
      }
    });

    console.log("--opp--", opp);
    console.log("--ContactAddtionaccId--", ContactAddtionaccId);
    //get Contact List
    getcontactlist({
      opp: opp,
      ContactAddtionaccId: ContactAddtionaccId,
      ispartorcust: this.addContactType
    })
      .then((result) => {
        this.addContactLoaded = true;
        this.contactListWrapper = result;
        this.openAddContact = true;
        this.isLoaded = true;
        console.log("--contactListWrapper--", this.contactListWrapper);
      })
      .catch((error) => {
        this.isLoaded = true;
        this.hasError = true;
        this.addContactLoaded = true;
        this.errorMessage = error;
      });
  }

  //Update selected Recipent in Contact wrapper
  updateRecipientIsSelcted(event) {
    console.log("updateRecipientIsSelcted called");
    let detail = event.target.dataset;
    console.log("detail --", JSON.stringify(detail));

    if (detail.type === "Renewal") {
      this.contactListWrapper.RenewalRecipientList.forEach((ele) => {
        if (ele.con.Id === detail.id) {
          ele.checked = ele.checked === true ? false : true;
        }
      });
    } else if (detail.type === "NonRenewal") {
      this.contactListWrapper.NonRenewalRecipientList.forEach((ele) => {
        if (ele.con.Id === detail.id) {
          ele.checked = ele.checked === true ? false : true;
        }
      });
    }
    console.log("detail --", JSON.stringify(this.contactListWrapper));
  }

  //Promise after gettting all record
  promisegetAllopportunityRecords() {
    return new Promise((resolve, reject) => {
      getOpportunityRecordsUnCached({
        filterStr: "",
        selectedTab: this.currentTab,
        offset: 0
      })
        .then((result) => {
          this.parseOpportunityListdata(result);
          resolve("done");
        })
        .catch((error) => {
          reject("NotDone");
          this.isLoaded = true;
          this.addContactLoaded = true;
          this.addContactHasError = true;
          this.addContactErrorMessage = error.body.message;
        });
    });
  }

  saveAddContact() {
    this.isLoaded = false;
    this.addContactLoaded = false;
    if (this.selectedOpportunityId) {
      let opp;
      this.recordList.forEach((record) => {
        if (record.Id === this.selectedOpportunityId) {
          opp = record;
        }
      });
      console.log("--saveAddContact--opp--", JSON.stringify(opp));

      if (opp) {
        savecontacts({
          acw: this.contactListWrapper,
          opp: opp,
          ispartorcust: this.addContactType
        })
          .then((result) => {
            console.log("--saveAddContact--result--", JSON.stringify(result));
            if (result.isSuccess) {
              this.addContactSuccess = true;
              this.addContactSuccessMessage = result.successMsg;

              this.promisegetAllopportunityRecords().then((result) => {
                console.log(
                  "--promisegetAllopportunityRecords--result--",
                  result
                );
                this.getContactWrapperList();
              });

              this.resetAddContactError();
            } else {
              this.isLoaded = true;
              this.addContactHasError = true;
              this.addContactErrorMessage = result.errorMessage;
            }
          })
          .catch((error) => {
            this.isLoaded = true;
            this.addContactLoaded = true;
            this.addContactHasError = true;
            this.addContactErrorMessage = error.body.message;
            console.log("--ERROR--", JSON.stringify(error));
          });
      } else {
        this.addContactLoaded = true;
        this.addContactHasError = true;
        this.addContactErrorMessage =
          "Kindly select valid opportunity to Add Contact.";
      }
    } else {
      this.addContactLoaded = true;
      this.isLoaded = true;
    }
  }

  openNewContactModal() {
    this.showAddNewContact = true;
    this.addNewContactLoaded = false;

    //using wire service getting current user data
    getFieldSetMember({
      objectName: "Contact",
      fieldSetName: "NewContactForAttendees"
    })
      .then((result) => {
        //console.log("--addNewContact--result--", result);
        this.addNewContactfldWrapper = JSON.parse(result);
        this.addNewContactfldWrapper.forEach((wrap, index) => {
          wrap.isAccountID = wrap.fieldAPIName === "AccountId" ? true : false;
          wrap.fieldIndex = "fld_" + index;
        });
        this.addNewContactLoaded = true;
        console.log(
          "--addNewContact--addNewContactfldWrapper--",
          this.addNewContactfldWrapper
        );
      })
      .catch((error) => {
        console.log("--ERROR--", JSON.stringify(error));
        this.addNewContactLoaded = true;
        this.addNewContactHasError = true;
        this.addNewContactErrorMessage = error.body.message;
      });
  }

  closeNewContactModal() {
    this.showAddNewContact = false;
  }

  handleAddNewContactLoad(data) {
    console.log("--handleAddNewContactLoad --");
    let fields = data.detail.record.fields;
    if (this.selectedOpportunityId) {
      let opp;
      this.recordList.forEach((record) => {
        if (record.Id === this.selectedOpportunityId) {
          opp = record;
        }
      });
      //console.log("--handleAddNewContactLoad--opp--", JSON.stringify(opp));
      if (opp) {
        this.addNewContactAccountID =
          opp.APTS_Primary_Proposal_Lookup__r.Apttus_QPConfig__BillToAccountId__c;
      }
    }
    if (this.addNewContactRequestCalled) {
      this.addNewContactLoaded = false;
    } else {
      this.addNewContactLoaded = true;
    }
    //console.log("fields---", JSON.stringify(fields));
  }

  handleAddNewContactSubmit(event) {
    event.preventDefault(); // stop the form from submitting
    this.addNewContactRequestCalled = true;
    this.addNewContactLoaded = false;
    const fields = event.detail.fields;
    console.log("fields---", JSON.stringify(fields));
    this.template.querySelector("lightning-record-edit-form").submit(fields);
  }

  handleAddNewContactSuccess(event) {
    this.addNewContactRequestCalled = false;
    //Refresh Data from Apex
    this.showAddNewContact = false;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: event.detail.apiName + " created.",
        variant: "success"
      })
    );
    this.isLoaded = false;
    this.addContactLoaded = false;
    this.getContactWrapperList();
  }

  isContactlistAvailable() {
    return this.contactListWrapper != undefined ? true : false;
  }

  hasRenewalContactList() {
    return this.contactListWrapper.RenewalRecipientList != undefined &&
      this.contactListWrapper.RenewalRecipientList.length > 0
      ? true
      : false;
  }
  hasNonRenewalContactList() {
    return this.contactListWrapper.NonRenewalRecipientList != undefined &&
      this.contactListWrapper.NonRenewalRecipientList.length > 0
      ? true
      : false;
  }

  /*Add Contact record Section Ends here*/

  //Add Extention Record Methods Starts here
  resetAddExtentionError() {
    this.addExtentionHasError = false;
    this.addExtentionErrorMessage = "";
  }

  openAddExtentionModal() {
    this.openExtentionModal = true;
    resetAddExtentionError();
  }

  closeAddExtentionModal() {
    this.openExtentionModal = false;
  }

  handleAddExtentionLoad() {
    console.log("handleAddExtentionLoad---called");
    if (this.addExtentionRequestCalled) {
      this.addExtentionLoaded = false;
    } else {
      this.addExtentionLoaded = true;
    }
  }

  //Promise after gettting all record
  promiseAddNewExtention(opp, fields) {
    return new Promise((resolve, reject) => {
      createAndAddExtension({
        opp: opp,
        newExtension: fields
      })
        .then((result) => {
          console.log(
            "promiseAddNewExtention result---",
            JSON.stringify(result)
          );
          resolve(result);
        })
        .catch((error) => {
          new ShowToastEvent({
            title: "Error",
            message: "Add extensions failed, please try agian",
            variant: "Error"
          });
          this.addContactErrorMessage = error.body.message;
        });
    });
  }

  handleAddExtentionSubmit(event) {
    event.preventDefault();
    // stop the form from submitting
    this.addExtentionRequestCalled = true;
    this.addExtentionLoaded = false;
    const fields = event.detail.fields;
    console.log(
      "handleAddExtentionSubmit :: selectedOpportunityId---",
      JSON.stringify(this.selectedOpportunityId)
    );

    if (this.selectedOpportunityId) {
      //Set opportunity ID
      fields.Opportunity__c = this.selectedOpportunityId;
      //fields.Opportunity__c = 'fdgdfkkg';

      let opp;
      this.recordList.forEach((record) => {
        if (record.Id === this.selectedOpportunityId) {
          opp = record;
        }
      });

      console.log("handleAddExtentionSubmit opp---", opp);

      if (opp) {
        this.promiseAddNewExtention(opp, fields).then((result) => {
          console.log(
            "handleAddExtentionSubmit result---",
            JSON.stringify(result)
          );
          if (result) {
            if (result.isSuccess) {
              this.openExtentionModal = false;
              this.addExtentionRequestCalled = false;
              this.isLoaded = false;
              this.refreshPage();
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: "Extention Request has been created.",
                  variant: "success"
                })
              );
            } else {
              this.addExtentionLoaded = true;
              this.addExtentionHasError = true;
              this.addExtentionRequestCalled = false;
              this.addExtentionErrorMessage = result.errorMessage;
            }
          }
        });
      }
      //this.template.querySelector("lightning-record-edit-form").submit(fields);
    } else {
      this.addExtentionLoaded = true;
    }
  }

  handleAddExtentionSuccess(event) {
    //Refresh Data from Apex
    this.openExtentionModal = false;
    this.addExtentionRequestCalled = false;
    this.isLoaded = false;
    //refreshApex(this.wiredRecordList);
    this.refreshPage();
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: event.detail.apiName + " created.",
        variant: "success"
      })
    );
  }

  handleAddExtentionError(event) {
    this.addExtentionLoaded = true;
    this.addExtentionHasError = true;
    this.addExtentionRequestCalled = false;
    console.log("--handleAddExtentionError called--");
    const errMessage = event.detail.message;
    const errDet = event.detail.detail;
    console.log("--handleAddExtentionError--", JSON.stringify(event.detail));
    console.log("--handleAddExtentionError errMessage--", errMessage);
    console.log("--handleAddExtentionError errDet--", errDet);
    this.addExtentionErrorMessage = errMessage;
  }
  //Add Extention Record Methods Ends here

  //terminate Subscription Modal Starts here
  openTerminateSubscriptionModal() {
    this.openTerminateSubscription = true;
  }

  closeTerminateSubscriptionModal() {
    this.openTerminateSubscription = false;
  }

  terminateSubscription() {
    console.log("--terminateSubscription called--");
    if (this.selectedOpportunityId) {
      let sub = "Zscaler Subscription Termination for the Customer";

      let opp;
      this.recordList.forEach((record) => {
        if (record.Id === this.selectedOpportunityId) {
          opp = record;
        }
      });

      //Customer Email
      let custemails = opp.customercontactemail ? opp.customercontactemail : "";
      //Partner Email
      custemails = opp.partnercontactemail
        ? custemails + opp.partnercontactemail
        : custemails;
      //Additional Email
      custemails = this.additionalTerminateEmail
        ? custemails + this.additionalTerminateEmail
        : custemails;
      //Owner Email
      custemails = opp.Owner.Email ? custemails + opp.Owner.Email : custemails;

      let url =
        "/apex/OppLossReasonFormPage?oppId=" +
        this.selectedOpportunityId +
        "&custpartowneremails=" +
        custemails +
        "&terminationTemplateId=" +
        this.terminationTemplateId +
        "&subject=" +
        sub;

      this.gotoWebPage(url);
    } else {
      console.log("--terminateSubscription invalid selectedOpportunityId--");
    }
  }
  //terminate Subscription Modal Ends here

  //Notify Now Modal
  openNotifyModal() {
    console.log("--openNotifyModal called--");
    if (this.selectedOpportunityId) {
      let opp;
      this.recordList.forEach((record) => {
        if (record.Id === this.selectedOpportunityId) {
          opp = record;
        }
      });

      //Customer Email
      let ccEmails = opp.customercontactemail ? opp.customercontactemail : "";
      //Partner Email
      ccEmails = opp.partnercontactemail
        ? ccEmails + opp.partnercontactemail
        : ccEmails;
      //Owner Email
      ccEmails = opp.Owner.Email ? ccEmails + opp.Owner.Email : ccEmails;

      console.log("--ccEmails--", ccEmails);

      //Set Email template ID
      if (this.currentTab === "Upcoming Renewals") {
        this.emailTemplateId = this.futurenotificationTemplateId;
      } else if (this.currentTab === "Manage Extensions") {
        this.emailTemplateId = this.pastDueTemplateId;
      } else {
        this.emailTemplateId = "";
      }

      this.fromAdd = "0D20g000000GoxjCAC";
      this.toAdd = "";
      this.additionalTo = ccEmails;
      this.ccAdd = "";
      this.bccAdd = this.objUser.Email;
      this.relatedTmplateId = this.selectedOpportunityId;
      this.openNotifyNow = true;
    }
    console.log("--openNotifyNow--", this.openNotifyNow);
  }

  closeNotifyModal() {
    this.openNotifyNow = false;
  }

  emailSentSuccess(event) {
    console.log("-emailSentSuccess--called");
    console.log("-event--", JSON.stringify(event));
    let eventDetail = event.detail;
    if (eventDetail) {
      if (eventDetail.result === "Success") {
        this.closeNotifyModal();
      }
    }
  }

  //Refresh Data from Apex
  refreshPage() {
    console.log("-refreshPage--called");
    this.isLoaded = false;
    this.getOpportunityRecordsWithFilter();
  }

  //Show Toast Message
  showToastMsg(title, msg, variant, mode) {
    console.log(":: showToastMsg called::");
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: msg,
        variant: variant,
        mode: mode
      })
    );
  }

  gotoWebPage(urlWithParameters) {
    console.log("--urlWithParameters--", urlWithParameters);
    this[NavigationMixin.GenerateUrl]({
      type: "standard__webPage",
      attributes: {
        url: urlWithParameters
      }
    }).then((generatedUrl) => {
      window.open(generatedUrl);
    });
  }

  get isAddPartnerContact() {
    return this.addContactType === "Partner" ? true : false;
  }

  get isAddCustomerContact() {
    return this.addContactType === "Customer" ? true : false;
  }

  //For title
  get title() {
    return "View: " + this.objUser.Name;
  }

  //For Upcoming Renewals tab style
  get upcomingRenewalsTabCSS() {
    return this.currentTab === "Upcoming Renewals"
      ? "slds-tabs_default__item slds-is-active"
      : "slds-tabs_default__item";
  }
  get upcomingRenewalsItemCSS() {
    return this.currentTab === "Upcoming Renewals"
      ? "slds-tabs_default__content greyOut slds-show"
      : "slds-tabs_default__content greyOut slds-hide";
  }

  //For Manage extention tab style
  get manageExtensionsTabCSS() {
    return this.currentTab === "Manage Extensions"
      ? "slds-tabs_default__item slds-is-active"
      : "slds-tabs_default__item";
  }
  get manageExtensionsItemCSS() {
    return this.currentTab === "Manage Extensions"
      ? "slds-tabs_default__content greyOut slds-show"
      : "slds-tabs_default__content greyOut slds-hide";
  }

  get recordListUREmpty() {
    return this.recordListUR.length > 0 ? false : true;
  }
  get recordListMEEmpty() {
    return this.recordListME.length > 0 ? false : true;
  }

  get showGeoAndRepFilter() {
    return this.objUser.Show_Rep_Filter_on_Renewal_Console__c ? true : false;
  }
}