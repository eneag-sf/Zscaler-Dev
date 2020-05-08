({

    handleSaveRecord: function (component, event, helper) {
        component.find("forceRecordCmp").saveRecord($A.getCallback(function (saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    type: 'success',
                    message: "Contact Updated."
                });

                toastEvent.fire();
            } else if (saveResult.state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: "User is offline, device doesn't support drafts."
                });

                toastEvent.fire();
            } else if (saveResult.state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: 'Problem saving record, error: ' + JSON.stringify(saveResult.error)
                });

                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                    message: 'Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error)
                });

                toastEvent.fire();
            }
            $A.get('e.force:closeQuickAction').fire();
        }));
    },
    showtoast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });

        toastEvent.fire();
    },
})