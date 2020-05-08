({
    doInit : function(component, event, helper) {
        let reclst = component.get("v.listofrecords");
        if(reclst.length > 0){
            component.set("v.showcards", true);
        }
        console.log(reclst);
        let fields = component.get("v.cardbodyfields");
        fields = fields.replace(/ /g,'');
        let flst = fields.split(',');
        console.log(flst);
        component.set("v.cardbodylist",flst);

    },
    removecard: function(component, event, helper) {
        let index = event.getSource().get("v.title");
        console.log(index);
        if((index != null && index != undefined && index != '') || index == 0){
            let reclst = component.get("v.listofrecords");
            reclst.splice(index, 1);
            console.log(reclst);
            if(reclst.length < 1){
                component.set("v.showcards", false);
            }
            component.set("v.listofrecords", reclst);
        }
    }
})