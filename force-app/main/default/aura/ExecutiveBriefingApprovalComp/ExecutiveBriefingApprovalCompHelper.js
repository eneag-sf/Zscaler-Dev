({
    
    openERRecord : function (cmp,event,helper) {
        var erID = cmp.get("v.ExecutiveBriefId");        
    	var redirectTo = '/' + erID;
        window.open(redirectTo,'_self');
        //$A.get('e.force:closeQuickAction').fire();
    }
})