({
	doInit : function(component) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        var output;
        console.log(record);
        console.log(field);
        try {
            output = record[field];
        } catch (err){
            console.log(err);
            output = null;
        }
        console.log(output);
        component.set("v.simpleOutput", output);
    }
})