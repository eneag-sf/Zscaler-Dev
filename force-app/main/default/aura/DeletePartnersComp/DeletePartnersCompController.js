({
	doInit : function(component, event, helper) {
		//alert('---PartnerId---'+component.get("v.PartnerId"));
        if(component.get("v.PartnerId") != undefined && component.get("v.PartnerId") != ''){
            helper.DeleteRecord(component, event, helper);
        }
	}
})