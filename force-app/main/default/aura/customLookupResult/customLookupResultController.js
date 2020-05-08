({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
      var selectedRecordId = component.get("v.oRecord").Id;
      //alert('selectedRecordId --> '+selectedRecordId);
      component.set("v.selectedValue", selectedRecordId);
      //alert('selected value --> '+component.get("v.selectedValue"));
      var vx = component.get("v.change");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord });  
    // fire the event  
         compEvent.fire();
    },
})