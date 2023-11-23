({
    redirectToNewRecord: function(component, event, helper) {
        var messageData = event.getParam('messageTemplateData');
        if (!$A.util.isEmpty(messageData)) {
            var executionComponent = messageData[1].executionComponent;
            if (!$A.util.isEmpty(executionComponent)) {
                var recordId = executionComponent.attributes.recordId;
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId,
                    "slideDevName": "related"
                });
                navEvt.fire();
            }
        }
    }
})