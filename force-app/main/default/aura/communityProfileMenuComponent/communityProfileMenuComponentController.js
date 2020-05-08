({
    doInit: function(component, evt, helper){
        let rec = component.get("v.record");
        component.set("v.userName", rec.fields.Name.value);
        component.set("v.loadcmp", true);
    },
    handleClick : function(component, event, helper) {
        let source = event.getSource();
        let label = source.get("v.label");
        let pathArray = window.location.pathname.split('/');
        let portalname = pathArray[1];
        if(label=="My Profile"){
            // do some work ..
            let userId = $A.get("$SObjectType.CurrentUser.Id");
            window.location = '/'+portalname+'/s/profile/'+ userId;
        }else if(label == 'Logout'){
            
            console.log('label'+label);
            if(portalname == 'partners'){
                window.location = '/'+portalname + '/secur/logout.jsp?retUrl=%2Flogin';
            }else{
                window.location = '/'+portalname + '/secur/logout.jsp?retUrl=https%3A%2F%2Fwww.zscaler.com';
            }
            
        }
        
    }
})